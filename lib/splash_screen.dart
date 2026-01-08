import 'dart:async';
import 'package:arc/home_screen.dart';
import 'package:arc/model/user_model.dart';
import 'package:arc/network/FirebaseService.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/utils/enums.dart';
import 'package:arc/utils/helper.dart';
import 'package:arc/utils/preference_helper.dart';
import 'package:arc/video_call_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'onboarding/login_screen.dart';
import 'package:arc/ChatScreen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash-screen';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String version='';
  String buildNumber='';
  Timer? _navigationTimer;
  Timer? _pendingCallCheckTimer;

  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((value) => {
      setState((){
        version = value.version;
        buildNumber = value.buildNumber;
      })
    });

    _setupApplication();
  }

  Future<void> _setupApplication() async {
    if (FirebaseService.pendingCallModel != null) {
      _setupApplicationState();
    } else {
      _navigationTimer = Timer(const Duration(seconds: 3), () async {
        _setupApplicationState();
      });
    }
  }

  void _setupApplicationState() async {
    UserData userData = await PreferenceHelper.getUserProfile();
    if (!mounted) return;
    if(userData.authToken == null || userData.authToken == '') {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const LoginScreen()));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const HomeScreen()));
      _checkForNotificationDuringAppInitialization();
    }
  }

  void _checkForNotificationDuringAppInitialization() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from terminated state by notification: ${initialMessage.data}');

      _handleNotificationNavigations(initialMessage);
    }
  }

  void _handleNotificationNavigations(messgae) {

    FirebaseService.handleNotificationNavigations(messgae);

    // if (messgae.data['type'] == 'CHAT') {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       settings: const RouteSettings(name: ChatScreen.routeName),
    //       builder: (context) => const ChatScreen(faqModel: null,),
    //     ),
    //   );
    //
    // } else if (messgae.data['type'] == '') { //HANDLE MORE NAVIGATIONS HERE
    //
    // }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _pendingCallCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, //.withOpacity(0.8),
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset("assets/logo.png", scale: 1.7,),
            const SizedBox(height: 20,),
            const Text('Acupunture & Physical Therepy Specialists Inc', style: TextStyle(color: black, fontWeight: FontWeight.w500, fontSize: 14,)),
          ],
        ),
      )
    );
  }
}
