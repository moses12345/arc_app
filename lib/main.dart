import 'package:arc/provider/appointments_provider.dart';
import 'package:arc/provider/exercises_provider.dart';
import 'package:arc/provider/fcm_provider.dart';
import 'package:arc/provider/info_lib_provider.dart';
import 'package:arc/provider/login_provider.dart';
import 'package:arc/provider/news_letter_provider.dart';
import 'package:arc/provider/notification_provider.dart';
import 'package:arc/provider/video_call_provider.dart';
import 'package:arc/splash_screen.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/utils/enums.dart';
import 'package:arc/utils/helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'network/FirebaseService.dart' show FirebaseService, firebaseMessagingBackgroundHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final navigatorKey = GlobalKey<NavigatorState>();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseService.setNavigatorKey(navigatorKey);

  await FirebaseService.initializeFirebase();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: themeColor,
      statusBarBrightness: Brightness.light,
    ));
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FCMProvider(context)),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => NewsLetterProvider()),
        ChangeNotifierProvider(create: (_) => ExercisesProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentsProvider()),
        ChangeNotifierProvider(create: (_) => VideoCallProvider()),
        ChangeNotifierProvider(create: (_) => InfoLibProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'ARC',
        theme: ThemeData(fontFamily: 'Inter', useMaterial3: true),
        home: const SplashScreen(),
      ),
    );
  }
}
