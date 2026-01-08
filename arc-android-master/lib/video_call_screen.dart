import 'dart:async';
import 'dart:ui';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:arc/network/FirebaseService.dart';
import 'package:arc/provider/video_call_provider.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/utils/preference_helper.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:arc/model/video_call_model.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoCallScreen extends StatefulWidget {
  static const routeName = '/video-call-screen';
  final VideoCallModel videoCallModel;

  const VideoCallScreen({super.key, required this.videoCallModel});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final databaseRef = FirebaseDatabase.instance.ref();
  // Fill in the app ID obtained from Agora Console
  static const appId = "3b8f023cca224381b3ffd31718fb89b3";
// Fill in the temporary token generated from Agora Console
  //static const token = "<-- Insert token -->";
// Fill in the channel name you used to generate the token
  //static const channel = "<-- Insert channel name -->";

  late RtcEngine _engine; // Stores Agora RTC Engine instance
  int? _remoteUid; // Stores the remote user's UID
  bool _muted = false;
  bool _speakerOn = true;
  Duration _callDuration = Duration.zero;
  Timer? _callTimer;

  Timer? timer;
  int waitingTime = 0;
  bool _isCallEnded = false; // Flag to prevent double cleanup

  late AnimationController _avatarPulseController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  void startCountdown() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (waitingTime <= 0) {
        _stopRingtone();
        timer.cancel();
        setState(() {}); // refresh UI to show "Time's up!"
        _showWaitingTimeUpDialog();
      } else {
        setState(() {
          waitingTime--;
        });
      }
    });
  }

  void _showWaitingTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            '${widget.videoCallModel.message}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _endCall(); // End CallKit and cleanup
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Exit video call screen
              },
              child: const Text(
                'Ok',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    return "${hours.toString().padLeft(2, '0')}:"
        "${minutes.toString().padLeft(2, '0')}:"
        "${secs.toString().padLeft(2, '0')}";
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reconfigure Agora audio session when app returns
      _engine.enableAudio();
      _engine.setEnableSpeakerphone(_speakerOn);
      if (_muted) {
        _engine.muteLocalAudioStream(true);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Set current open call model when screen initializes
    FirebaseService.setCurrentOpenCallModel(widget.videoCallModel);

    waitingTime = widget.videoCallModel.waitingTime!;
    //waitingTime = 60;
    if (kDebugMode) {
      print('Channel Name: ${widget.videoCallModel.channelName}');
      print('Token: ${widget.videoCallModel.token}');
    }

    // Prevent screen from sleeping during the call
    WakelockPlus.enable();

    if(widget.videoCallModel.isIncoming == false) {
      startCountdown();
      AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playAndRecord,
            options: const {
              AVAudioSessionOptions.allowBluetooth,
              AVAudioSessionOptions.defaultToSpeaker,
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.speech,
            usageType: AndroidUsageType.voiceCommunication,
            audioFocus: AndroidAudioFocus.gain,
          ),
        ),
      );
      _playRingtone();
    }


    _avatarPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Simulate remote user connection after 3 seconds
    /*Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _remoteUid = 2456;
        _startTimer();
      });
      _stopRingtone();
    });*/

    _startVoiceCalling();
  }


  Future<void> _playRingtone() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('ringtone.mp3'));
  }

  Future<void> _stopRingtone() async {
    await _audioPlayer.stop();
  }

  void _startTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration += const Duration(seconds: 1);
      });
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  // Initializes Agora SDK
  Future<void> _startVoiceCalling() async {
    await _requestPermissions();
    await _initializeAgoraVoiceSDK();
    _setupEventHandlers();
    await _joinChannel();
  }

  // Requests microphone permission
  Future<void> _requestPermissions() async {
    await [Permission.microphone].request();
  }
  // Set up the Agora RTC engine instance
  Future<void> _initializeAgoraVoiceSDK() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
  }

  // Register an event handler for Agora RTC
  void _setupEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user ${connection.localUid} joined");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          setState(() {
            timer?.cancel();
            waitingTime = -1;
            _remoteUid = remoteUid; // Store remote user ID
            _startTimer();
          });
          if(widget.videoCallModel.isIncoming == false) {
            _stopRingtone();
          }
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("Remote user $remoteUid left");
          setState(() {
            _remoteUid = null; // Remove remote user ID
          });
          _endCall(); // End CallKit and cleanup
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // Join a channel
  Future<void> _joinChannel() async {
    await _engine.joinChannel(
      token: "${widget.videoCallModel.token}",
      //channelId: "${widget.videoCallModel.branchId}",
      channelId: "${widget.videoCallModel.channelName}",
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: 0,
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    Color? fillColor,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
              child: Container(
                decoration: BoxDecoration(
                  color: fillColor ?? Colors.white10,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                padding: const EdgeInsets.all(16),
                child: Icon(icon, color: color, size: 28),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    timer?.cancel();
    _avatarPulseController.dispose();
    if(widget.videoCallModel.isIncoming == false) {
      _audioPlayer.dispose();
    }
    
    // Clear current open call model when screen is disposed
    FirebaseService.setCurrentOpenCallModel(null);
    
    // End CallKit if not already ended (safety net - works even when app is in background)
    if (!_isCallEnded) {
      _isCallEnded = true;
      // End CallKit synchronously (critical for background state)
      FlutterCallkitIncoming.endAllCalls();
      // Cleanup async operations in background
      _cleanupAgoraEngine();
      updateCallStatus();
    } else {
      // If already ended, just ensure CallKit is ended and cleanup engine
      FlutterCallkitIncoming.endAllCalls();
      _cleanupAgoraEngine();
    }

    // Allow screen to sleep again when leaving
    WakelockPlus.disable();
    super.dispose();
  }

  // Leaves the channel and releases resources
  Future<void> _cleanupAgoraEngine() async {
    await _engine.leaveChannel();
    await _engine.release();
  }


  @override
  Widget build(BuildContext context) {
    //Color themeColor = Colors.blueAccent;
    String callerName = widget.videoCallModel.userName ?? "user $_remoteUid";

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          backgroundColor: themeColor,
          leading: IconButton(
            icon: RotationTransition(
              turns: const AlwaysStoppedAnimation(180 / 360),
              child: Image.asset(
                'assets/right_arrow.png',
                fit: BoxFit.cover,
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              await _endCall();
              Navigator.of(context).pop();
            },
          ),
          title: const Text('ARC Voice Call',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 14)),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  AnimatedBuilder(
                    animation: _avatarPulseController,
                    builder: (_, child) {
                      double scale = 1 + (_avatarPulseController.value * 0.1);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white10,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.tealAccent.withOpacity(0.6),
                                blurRadius: 25 * _avatarPulseController.value,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage('assets/user_avatar.png'),
                            backgroundColor: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Column(
                      key: ValueKey(_remoteUid != null),
                      children: [
                        Text(
                          _remoteUid != null
                              ? "Connected with $callerName"
                              : "Calling...",
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        if (_remoteUid != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _formatDuration(_callDuration),
                            style: const TextStyle(color: Colors.white54, fontSize: 14),
                          )
                        ]
                      ],
                    ),
                  ),
                ],
              ),
              widget.videoCallModel.isIncoming == false ? Text(
                waitingTime > 0
                    ? "Estimated response time is: ${formatTime(waitingTime)}"
                    : "",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ): Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: _muted ? Icons.mic_off : Icons.mic,
                    label: _muted ? "Unmute" : "Mute",
                    color: Colors.white,
                    fillColor: _muted ? Colors.redAccent.withOpacity(0.3) : Colors.white12,
                    onTap: _onToggleMute,
                  ),
                  _buildControlButton(
                    icon: Icons.call_end,
                    label: "End",
                    color: Colors.white,
                    fillColor: Colors.red,
                      onTap: () async {
                      await _endCall();
                      Navigator.of(context).pop();
                    }
                  ),
                  _buildControlButton(
                    icon: _speakerOn ? Icons.volume_up : Icons.volume_off,
                    label: _speakerOn ? "Speaker On" : "Speaker",
                    color: Colors.white,
                    fillColor: _speakerOn ? Colors.greenAccent : Colors.white12,
                    onTap: _onToggleSpeaker,
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }

  void _onToggleMute() {
    setState(() {
      _muted = !_muted;
    });
    _engine.muteLocalAudioStream(_muted);
  }

  void _onToggleSpeaker() {
    setState(() {
      _speakerOn = !_speakerOn;
    });
    _engine.setEnableSpeakerphone(_speakerOn);
  }

  Future<void> updateCallStatus()  async {
    await PreferenceHelper.clearPendingCallModel();
    databaseRef.child('calls/${widget.videoCallModel.uid}').update({
      'status': 'declined',
    });

    if (widget.videoCallModel.uid != null) {
      Provider.of<VideoCallProvider>(context, listen: false).updateVideoCallStatus(context, widget.videoCallModel.uid!);
    }
  }

  // Helper method to end call properly - ends CallKit and updates status
  Future<void> _endCall() async {
    if (_isCallEnded) return; // Prevent double cleanup
    _isCallEnded = true;
    
    try {
      // End CallKit call (works even when app is in background)
      await FlutterCallkitIncoming.endAllCalls();
      // Update call status in Firebase
      await updateCallStatus();
      // Cleanup Agora engine
      await _cleanupAgoraEngine();
    } catch (e) {
      if (kDebugMode) {
        print('Error ending call: $e');
      }
    }
  }
}
