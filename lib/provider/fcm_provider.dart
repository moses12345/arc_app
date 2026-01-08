
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMProvider with ChangeNotifier {
  static BuildContext? _context;
  static String notificationMsg = "";

  FCMProvider(BuildContext context) {
    _context = context;
    notifyListeners();
  }

 /* void setContext(BuildContext context) => {
    _context = context,
    notifyListeners()
  };*/

  /// when app is in the foreground
  static Future<void> onTapNotification(NotificationResponse? response) async {
    notificationMsg = "abc";
    if (_context == null || response?.payload == null) {
      //Helper.showSnackBar(context: _context!, message: "message", status: Status.success);
      if (kDebugMode) {
        print("Context Null");
        print("Payload ${response?.payload}");
      }
      return;
    }
    if (kDebugMode) {
      print("Payload ${response?.payload}");
    }
   /* var data = FCMProvider.convertPayload(response!.payload!);
    String url = data['url'];
    if(url.isNotEmpty) {
      Helper.launchURL(_context!, url);
    }*/
    /*var _data = FCMProvider.convertPayload(response!.payload!);
    if (_data.containsKey(...)){
      await Navigator.of(FCMProvider._context!).push(...);
    }*/
  }

  static Map convertPayload(String payload){
    final String payload0 = payload.substring(1, payload.length - 1);
    List<String> split = [];
    payload0.split(",").forEach((String s) => split.addAll(s.split(":")));
    var mapped = {};
    for (int i = 0; i < split.length + 1; i++) {
      if (i % 2 == 1) mapped.addAll({split[i-1].trim().toString(): split[i].trim()});
    }
    return mapped;
  }
/*  static Future<void> onMessage() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      //if (FCMProvider._refreshNotifications != null) await FCMProvider._refreshNotifications!(true);
      // if this is available when Platform.isIOS, you'll receive the notification twice
      if (Platform.isAndroid) {
        await FirebaseService.localNotificationsPlugin.show(
          0, message.notification!.title,
          message.notification!.body,
          FirebaseService.platformChannelSpecifics,
          payload: message.data.toString(),
        );
      }
    });
  }*/

  /*static Future<void> backgroundHandler(RemoteMessage message) async {
    if (Platform.isAndroid) {
      await FirebaseService.localNotificationsPlugin.show(
        0, message.notification!.title,
        message.notification!.body,
        FirebaseService.platformChannelSpecifics,
        payload: message.data.toString(),
      );
    }
  }*/
}