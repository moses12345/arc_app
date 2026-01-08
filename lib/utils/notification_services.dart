
import 'package:app_settings/app_settings.dart';
import 'package:arc/model/appointment_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'display_payload.dart';
import 'helper.dart';

class NotificationServices {
  // Initialize FlutterLocalNotificationsPlugin
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // GlobalKey for navigation
  static GlobalKey<NavigatorState> globalKey = GlobalKey<NavigatorState>();

  static int idGenerator() {
    final now = DateTime.now();
    return now.microsecondsSinceEpoch;
  }

  // Notification details
  static NotificationDetails notificationDetails = const NotificationDetails(
    android: AndroidNotificationDetails(
      "channelId",
      "channelName",
      priority: Priority.high,
      importance: Importance.high,
      icon: "@mipmap/ic_launcher",
    ),
  );

  // Initialize method
  static Future<void> init() async {
    tz.initializeTimeZones();

    AndroidInitializationSettings androidInitializationSettings = const AndroidInitializationSettings("@mipmap/ic_launcher");
    const DarwinInitializationSettings iOSInitializationSettings = DarwinInitializationSettings();

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings, // Required for iOS
    );
    /*InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );*/
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
      onDidReceiveBackgroundNotificationResponse,
    );
  }

  // Method to request notification permission
  static void askForNotificationPermission() {
    Permission.notification.request().then((permissionStatus) {
      if (permissionStatus != PermissionStatus.granted) {
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      }
    });
  }

  // Method to send instant notification
  static void sendInstantNotification(
      {required String title, required String body, required String payload}) {
    flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Method to send periodic notification
  static void sendPeriodicNotification({required String title, required String body, required String payload}) {
    flutterLocalNotificationsPlugin.periodicallyShow(
      1,
      title,
      body,
      RepeatInterval.everyMinute,
      notificationDetails,
      payload: payload, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
  tz.TZDateTime _mConvertTime(int hour, int minutes) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minutes,
    );
    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }
    return scheduleDate;
  }

  static tz.TZDateTime _convertTime(int appointmentDate, int bookedTime) {
    String mDate = Helper.convertMillisecondsToDate(appointmentDate);
    String mBookedTime = Helper.getTimeSlot(bookedTime);
    List<String> mBookedTimeList = mBookedTime.split(":");
    List<String> mDateList = mDate.split("-");
    String year = mDateList[0];
    String month = mDateList[1];
    String date = mDateList[2];
    print("Appointment Date: $year $month $date");
    print("Appointment Time: ${mBookedTimeList[0]} ${mBookedTimeList[1].split(" ")[0]}");
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    print("Local Date: ${now.year} ${now.month} ${now.day}");

    tz.TZDateTime scheduleDate = tz.TZDateTime(
      tz.local,
      int.parse(year),
      int.parse(month),
      int.parse(date),
      int.parse(mBookedTimeList[0]),
      int.parse(mBookedTimeList[1].split(" ")[0]),
    );
    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(seconds: 60));
    }
    return scheduleDate;
  }

  static void sendScheduleNotification({
    required AppointmentData appointmentData,
    required String title,
    required String body,
    required String payload,
  }) {
    // Initialize the timezone package
    tz.initializeTimeZones();

    // Schedule a notification at the specific time and date
    flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      _convertTime(appointmentData.appointmentDate!, appointmentData.bookedFrom!),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          channelDescription: 'Channel for appointment notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Match both date and time
    );
  }


  static tz.TZDateTime _getNotificationTime({required int appointmentDate, required int bookedTime, required Duration offset,}) {
    // Convert appointment date and time from milliseconds
    String formattedDate = Helper.convertMillisecondsToDate(appointmentDate);
    String formattedTime = Helper.getTimeSlot(bookedTime);
    List<String> dateParts = formattedDate.split("-");
    List<String> timeParts = formattedTime.split(":");

    // Parse year, month, and day
    int year = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[2]);

    // Parse hours and minutes
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1].split(" ")[0]);

    tz.Location location = tz.getLocation('Asia/Kolkata'); // Change as needed
    // Create the appointment time in the local timezone
    tz.TZDateTime appointmentDateTime = tz.TZDateTime(
      location,
      year,
      month,
      day,
      hour,
      minute,
    );
    if (kDebugMode) {
      print("Appointment Time: $appointmentDateTime");
    }
    // Return the appointment time adjusted by the specified offset
    return appointmentDateTime.subtract(offset);
  }

  static void sendScheduledNotification({
    required AppointmentData appointmentData,
    required String title,
    required String body,
    required String payload,
  }) {
    // Initialize the timezone package
    tz.initializeTimeZones();

    // Schedule 30 minutes before the appointment
    tz.TZDateTime scheduledTime30MinutesBefore = _getNotificationTime(appointmentDate: appointmentData.appointmentDate!, bookedTime: appointmentData.bookedFrom!, offset: const Duration(minutes: 30),);

    // Schedule 1 day before the appointment
    tz.TZDateTime scheduledTime1DayBefore = _getNotificationTime(appointmentDate: appointmentData.appointmentDate!, bookedTime: appointmentData.bookedFrom!, offset: const Duration(days: 1),);

    tz.Location location = tz.getLocation('Asia/Kolkata'); // Change as needed
    var localTime = tz.TZDateTime.now(location);
    if (kDebugMode) {
      print(('object $scheduledTime30MinutesBefore'));
      print(('object1 $localTime'));
    }

    // Schedule the notification 30 minutes before, if in the future
    if (scheduledTime30MinutesBefore.isAfter(localTime)) {
      flutterLocalNotificationsPlugin.zonedSchedule(
        idGenerator(), // Unique ID for this notification
        title,
        "Reminder: $body",
        scheduledTime30MinutesBefore,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id',
            'channel_name',
            channelDescription: 'Channel for appointment notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);

      if (kDebugMode) {
        print("Notification scheduled 30 minutes before the appointment.");
      }
    } else {
      if (kDebugMode) {
        print("Scheduled time 30 minutes before is in the past.");
      }

      // Schedule the notification 1 day before, if in the future
      if (scheduledTime1DayBefore.isAfter(localTime)) {
        flutterLocalNotificationsPlugin.zonedSchedule(
          //1, // Unique ID for this notification
            idGenerator(),
          title,
          "Reminder: $body",
          scheduledTime1DayBefore,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'channel_id',
              'channel_name',
              channelDescription: 'Channel for appointment notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dateAndTime, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
        );

        if (kDebugMode) {
          print("Notification scheduled 1 day before the appointment.");
        }
      } else {
        if (kDebugMode) {
          print("Scheduled time 1 day before is in the past.");
        }
      }
    }
  }


  // Method to cancel periodic notification
  static Future<void> cancelPeriodicNotification() async {
    //await flutterLocalNotificationsPlugin.cancel(1);
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  // Method to handle notification response
  static void onDidReceiveNotificationResponse(
      NotificationResponse response) {
    debugPrint("onDidReceiveNotificationResponse");
    globalKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (context) => DisplayPayload(
          payloadData: response.payload,
        ),
      ),
    );
  }

  // Method to handle background notification response
  static void onDidReceiveBackgroundNotificationResponse(
      NotificationResponse response) {
    debugPrint("onDidReceiveBackgroundNotificationResponse");
    globalKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (context) => DisplayPayload(
          payloadData: response.payload,
        ),
      ),
    );
  }
}