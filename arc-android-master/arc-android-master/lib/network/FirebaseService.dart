import 'dart:async';
import 'dart:io';
import 'package:arc/ChatScreen.dart';
import 'package:arc/appointment/appointment_detail_screen.dart';
import 'package:arc/model/appointment_model.dart';
import 'package:arc/model/video_call_model.dart';
import 'package:arc/utils/preference_helper.dart';
import 'package:arc/utils/notification_services.dart';
import 'package:arc/video_call_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';
import 'package:arc/utils/helper.dart';

class FirebaseService {
  static FirebaseMessaging? _firebaseMessaging;
  static GlobalKey<NavigatorState>? navigatorKey;
  static VideoCallModel? pendingCallModel;
  static VideoCallModel? _currentOpenCallModel; // Track currently open call

  static FirebaseMessaging get firebaseMessaging => _firebaseMessaging ?? FirebaseMessaging.instance;

  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  // Check if VideoCallScreen is already open with the same call model
  static bool isSameCallAlreadyOpen(VideoCallModel newModel) {
    if (_currentOpenCallModel == null) {
      return false; // No call is open
    }
    
    // Compare channelName and token to determine if it's the same call
    final currentChannel = _currentOpenCallModel!.channelName;
    final currentToken = _currentOpenCallModel!.token;
    final newChannel = newModel.channelName;
    final newToken = newModel.token;
    
    if (kDebugMode) {
      print("FirebaseService: Comparing calls - Current: channel=$currentChannel, token=$currentToken");
      print("FirebaseService: Comparing calls - New: channel=$newChannel, token=$newToken");
    }
    
    // Same call if channel and token match
    return currentChannel != null && 
           currentChannel.isNotEmpty &&
           currentChannel == newChannel &&
           currentToken != null &&
           currentToken.isNotEmpty &&
           currentToken == newToken;
  }

  // Set the currently open call model
  static void setCurrentOpenCallModel(VideoCallModel? model) {
    _currentOpenCallModel = model;
    if (kDebugMode) {
      if (model != null) {
        print("FirebaseService: Set current open call - channel=${model.channelName}, token=${model.token}");
      } else {
        print("FirebaseService: Cleared current open call");
      }
    }
  }

  // 🚀 Firebase initialization
  static Future<void> initializeFirebase() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await Firebase.initializeApp();
    } else {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyAOhcYlKWkTZjCXoNthQTarqUXTiDxakoQ',
          appId: '1:906654836170:android:7183474ea5dd00d74c5b33',
          messagingSenderId: '906654836170',
          projectId: 'arc-app-2024',
        ),
      );
    }

    _firebaseMessaging = FirebaseMessaging.instance;
    await _firebaseMessaging?.requestPermission();

    // DO NOT use getInitialMessage here (killed state handled in main)
    // ❌ removed — this was blocking navigation when app was killed.

    await setupCallKitListeners();

    FirebaseMessaging.onMessage.listen((message) async {
      print(message.notification);
      // For incoming_call type, handle with CallKit and prevent default notification
      if (message.data['type'] == 'incoming_call') {
        final uuid = const Uuid().v4();
        final callerName = message.data['callerName'] ?? "Unknown Caller";
        final channel = message.data['channelName'] ?? "default_channel";
        final token = message.data['token'] ?? '';
        final uid = message.data['uid'] ?? '';
        final waitingTime = int.tryParse(message.data['waitingTime'] ?? '60') ?? 60;
        final msg = message.data['message'] ?? '';

        await showIncomingCall(uuid, callerName, channel,
            token: token, uid: uid, waitingTime: waitingTime, message: msg);
        // Return early to prevent default notification from showing
        return;

      } else if (message.data['type'] == 'CHAT') {
        // final top = getTopRouteName();
        // final title = message.notification?.title ?? 'Notification';
        // final body = message.notification?.body ?? '';
        // if ((title.isNotEmpty || body.isNotEmpty) && top != ChatScreen.routeName) {
          //Show custom in app notifications if needed
          // Helper.showNotification(title: title, message: body, payload: message.data.toString());
        // }
      }
      
      // For all other message types, show default notification
      // Firebase automatically shows notification if notification payload exists
      // We show manually only if notification payload doesn't exist (data-only message)
      if (message.notification == null) {
        final title = message.data['title'] ?? 'Notification';
        final body = message.data['body'] ?? message.data['message'] ?? '';
        
        if (title.isNotEmpty || body.isNotEmpty) {
          Helper.showNotification(title: title, message: body, payload: message.data.toString());
        }
      }
      // If notification payload exists, Firebase will show it automatically
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked (app resumed): ${message.data}');
      // Navigate using navigatorKey or handle message.data
        handleNotificationNavigations(message);
    });
  }

  // 🚀 Show CallKit incoming call UI
  static Future<void> showIncomingCall(
      String uuid,
      String callerName,
      String channel, {
        String? token,
        String? uid,
        int? waitingTime,
        String? message,
      }) async {
    final params = CallKitParams(
      id: uuid,
      nameCaller: callerName, // 👈 Caller title inside UI
      appName: 'ARC Voice Call', // 👈 Title on CallKit screen + notification
      type: 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      extra: {
        'channel': channel,
        'token': token ?? '',
        'uid': uid ?? '',
        'waitingTime': waitingTime?.toString() ?? '60',
        'message': message ?? '',
      },
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: true,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  // 🚀 CallKit accept/decline events
  static Future<void> setupCallKitListeners() async {
    if (kDebugMode) {
      print("FirebaseService: Setting up CallKit listeners");
    }
    
    // First check for any persisted calls before setting up listener
    final persistedModel = await PreferenceHelper.getPendingCallModel();
    if (persistedModel != null && 
        persistedModel.channelName != null && 
        persistedModel.channelName!.isNotEmpty) {
      if (kDebugMode) {
        print("FirebaseService: Found persisted call before setting up listener");
      }
      pendingCallModel = persistedModel;
    }
    
    FlutterCallkitIncoming.onEvent.listen((event) async {
      if (event == null) return;

      if (kDebugMode) {
        print("FirebaseService: CallKit event received: ${event.event}");
        print("FirebaseService: Event body: ${event.body}");
      }

      switch (event.event) {
        case Event.actionCallAccept:
          final extra = event.body['extra'] ?? {};

          if (kDebugMode) {
            print("FirebaseService: Call accepted, extra data: $extra");
          }

          final model = VideoCallModel(
            token: extra['token'],
            channelName: extra['channel'],
            uid: extra['uid'],
            waitingTime: int.tryParse(extra['waitingTime'] ?? '60'),
            message: extra['message'],
            userName: event.body['nameCaller']
          );
          model.isIncoming = true;

          pendingCallModel = model;
          // Persist to SharedPreferences for killed state recovery
          await PreferenceHelper.savePendingCallModel(model);
          
          if (kDebugMode) {
            print("FirebaseService: Pending call model set. Navigator context available: ${navigatorKey?.currentContext != null}");
          }
          
          // App running - try to navigate immediately
          if (navigatorKey?.currentContext != null) {
            // Check if same call is already open
            if (isSameCallAlreadyOpen(model)) {
              if (kDebugMode) {
                print("FirebaseService: Same call already open, skipping navigation");
              }
              // Clear pending call model since screen is already open with this call
              pendingCallModel = null;
              await PreferenceHelper.clearPendingCallModel();
              return;
            }
            
            if (kDebugMode) {
              print("FirebaseService: Navigating to VideoCallScreen immediately");
            }
            // Set current open call model before navigation
            setCurrentOpenCallModel(model);
            // Clear pending call model since we're navigating now
            pendingCallModel = null;
            await PreferenceHelper.clearPendingCallModel();
            Navigator.of(navigatorKey!.currentContext!).push(
              MaterialPageRoute(
                builder: (_) => VideoCallScreen(videoCallModel: model),
              ),
            );
          } else {
            if (kDebugMode) {
              print("FirebaseService: Navigator context not available, pendingCallModel will be checked by SplashScreen");
            }
            // If app is killed/terminated, pendingCallModel will be checked by SplashScreen
          }
          break;

        case Event.actionCallDecline:
          if (kDebugMode) {
            print("FirebaseService: Call declined");
          }
          setCurrentOpenCallModel(null); // Clear current call
          pendingCallModel = null;
          await PreferenceHelper.clearPendingCallModel();
          await FlutterCallkitIncoming.endAllCalls();
          break;

        case Event.actionCallEnded:
          setCurrentOpenCallModel(null); // Clear current call
          await PreferenceHelper.clearPendingCallModel();
          await FlutterCallkitIncoming.endAllCalls();
          break;

        default:
          break;
      }
    });
    
    // Check for active calls when app starts (in case event was missed)
    _checkActiveCalls();
  }
  
  // Check for active calls that might have been accepted before listener was ready
  static Future<void> _checkActiveCalls() async {
    try {
      // Wait a bit for the app to initialize
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Check for persisted pending call model (from killed state)
      final persistedModel = await PreferenceHelper.getPendingCallModel();
      if (persistedModel != null && 
          persistedModel.channelName != null && 
          persistedModel.channelName!.isNotEmpty) {
        if (kDebugMode) {
          print("FirebaseService: Found persisted pending call model");
        }
        pendingCallModel = persistedModel;
      }
      
      if (kDebugMode) {
        print("FirebaseService: Checking for active calls after initialization");
      }
    } catch (e) {
      if (kDebugMode) {
        print("FirebaseService: Error checking active calls: $e");
      }
    }
  }

  static void handleNotificationNavigations(messgae) {
    if (navigatorKey?.currentContext == null) { return; }
    final top = getTopRouteName();

    if (messgae.data['type'] == 'CHAT') {
      if (top == ChatScreen.routeName) { return; }

      Navigator.push(
        navigatorKey!.currentContext!,
        MaterialPageRoute(
          settings: const RouteSettings(name: ChatScreen.routeName),
          builder: (context) => const ChatScreen(faqModel: null,),
        ),
      );

    } else if (messgae.data['type'] == 'APPOINTMENT_NOTIFICATION') {

      var appointmentData = AppointmentData.fromNotification(messgae.data);

      Navigator.push(
          navigatorKey!.currentContext!,
          MaterialPageRoute(builder: (context) => AppointmentDetailScreen(appointmentData: appointmentData))
      );

    }
  }


  static String? getTopRouteName() {
    if (navigatorKey?.currentState == null) return null;
    String? top;
    navigatorKey!.currentState!.popUntil((route) {
      top = route.settings.name;
      return true; // stop immediately without popping anything
    });
    return top;
  }
}

/// 🌙 Background / Killed-state handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Use platform-specific initialization; iOS must use the default config.
  print(message.notification);
  if (Platform.isIOS || Platform.isMacOS) {
    await Firebase.initializeApp();
  } else {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAOhcYlKWkTZjCXoNthQTarqUXTiDxakoQ',
        appId: '1:906654836170:android:7183474ea5dd00d74c5b33',
        messagingSenderId: '906654836170',
        projectId: 'arc-app-2024',
      ),
    );
  }

  // For incoming_call type, handle with CallKit and prevent default notification
  if (message.data['type'] == 'incoming_call') {
    final uuid = const Uuid().v4();
    final callerName = message.data['callerName'] ?? "Unknown Caller";
    final channel = message.data['channelName'] ?? "default_channel";
    final token = message.data['token'] ?? '';
    final uid = message.data['uid'] ?? '';
    final waitingTime = int.tryParse(message.data['waitingTime'] ?? '60') ?? 60;
    final msg = message.data['message'] ?? '';

    final model = VideoCallModel(
      token: token,
      channelName: channel,
      uid: uid,
      waitingTime: waitingTime,
      message: msg,
      userName: callerName
    );
    model.isIncoming = true;
    await PreferenceHelper.savePendingCallModel(model);
    await FirebaseService.showIncomingCall(uuid, callerName, channel,
        token: token, uid: uid, waitingTime: waitingTime, message: msg);
    // Return early to prevent default notification from showing
    return;
  }
  
  // For all other message types, show default notification
  // Firebase automatically shows notification if notification payload exists
  // We show manually only if notification payload doesn't exist (data-only message)
  if (message.notification == null) {
    final title = message.data['title'] ?? 'Notification';
    final body = message.data['body'] ?? message.data['message'] ?? '';
    
    if (title.isNotEmpty || body.isNotEmpty) {
      Helper.showNotification(title: title, message: body, payload: message.data.toString());
    }
  }
  // If notification payload exists, Firebase will show it automatically
}


/*
* Simulation for notification
          Map<String, dynamic> body = {
              "type": "APPOINTMENT_NOTIFICATION",
              "appointmentStatus": "approved",
              "appointmentDate": "1766966400000",
              "bookedFrom": "765",
              "bookedTo": "780",
              "serviceType": "ACU",
              "_id": "695019946d3fedf0fb41da30",
              "branchName": "Mt.Dora",
              "branchID": "66061861727832d5107d38a9"
            };

            FirebaseService.handleNotificationNavigations(RemoteMessage(data: body));

*/