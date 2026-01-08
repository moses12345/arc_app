import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:arc/utils/notification_services.dart';
import 'enums.dart';

class Helper {

  static CircularProgressIndicator circularProgress() {
    return const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
    );
  }

  static TextButton retryButton(Function fetch) {
    return TextButton(
      child: const Text(
        "No Internet Connection.\nPlease Retry",
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.normal),
      ),
      onPressed: () => fetch(),
    );
  }

  static loginCheck({required BuildContext context, required Widget screenName}) {
    /*PreferenceHelper.getToken().then((value) => {
      print('Token: $value'),
      print('Screen Name: $screenName'),
      if(value == null || value == 'null') {
        //Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()))
      } else if(screenName != null){
        Navigator.push(context, MaterialPageRoute(builder: (context) => screenName))
      }
    });*/
  }

  static showNotification({required String title, required String message, required String payload}) {
      NotificationServices.sendInstantNotification(
        title: title,
        body: message,
        payload: payload,
      );
  }

  static showSnackBar({required BuildContext context, required String? message, required Status status}) {
    final snackBar = SnackBar(duration: const Duration(seconds: 1), content: Text(message!, style: const TextStyle(color: Colors.white, fontSize: 16)), backgroundColor: Status.success == status ? Colors.green : Colors.red,);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static bool isValidEmail(String em) {
    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(p);
    return regExp.hasMatch(em);
  }

  static bool isPasswordValid(String password) {
    final letterReg = RegExp(r'[a-zA-Z]');
    final numberReg = RegExp(r'[0-9]');

    return password.length >= 6 &&
        letterReg.hasMatch(password) &&
        numberReg.hasMatch(password);
  }

  static double getHoursDiffFromNow({
    required int appointmentDateMillis,
    required int bookedFromMinutes,
  }) {
    // Base date at midnight
    final baseDate = DateTime.fromMillisecondsSinceEpoch(appointmentDateMillis);
    final newDate = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
    );
    // Appointment start DateTime
    final appointmentStart = newDate.add(Duration(minutes: bookedFromMinutes));

    // Current time
    final now = DateTime.now();

    // Difference in hours (can be negative if in past)
    return appointmentStart.difference(now).inMinutes / 60.0;
  }


  // static String convertMillisecondsSinceEpoch(int? timeInMillisecond) {
  //   var dt = DateTime.fromMillisecondsSinceEpoch(timeInMillisecond!, isUtc: true);
  //   var date = DateFormat('EEEE, MMMM d, yyyy').format(dt);
  //   return date;
  // }

  static String convertMillisecondsSinceEpoch(int? ms) {
  if (ms == null) return '';

  // Step 1: Read as UTC
  final utc = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

  // Step 2: Rebuild as DATE-ONLY (no timezone shift)
  final dateOnly = DateTime.utc(utc.year, utc.month, utc.day);

  // Step 3: Format
  return DateFormat('EEEE, MMMM d, yyyy').format(dateOnly);
}


  static String convertMillisecondsToDate(int? timeInMillisecond) {
    var dt = DateTime.fromMillisecondsSinceEpoch(timeInMillisecond!);
    var date = DateFormat('yyyy-MM-dd').format(dt);
    return date;
  }

  static String convertDate(String inputDate) {
    // Define the input format
    DateFormat inputFormat = DateFormat('EEEE, MMMM d, yyyy');

    // Parse the input date string to a DateTime object
    DateTime dateTime = inputFormat.parse(inputDate);

    // Define the output format
    DateFormat outputFormat = DateFormat('yyyy-MM-dd');

    // Format the DateTime object to a string in the desired format
    String formattedDate = outputFormat.format(dateTime);

    return formattedDate;
  }
  static String getTimeSlot(int value) {
    double hours = value/60;
    double minutes = value%60;
    //print("$hours \$minutes");

    String mHour = hours.toString();
    mHour = mHour.split('.')[0];

    String mMinute = minutes.toString();
    mMinute = mMinute.split('.')[0];
    if(mMinute.length == 1) {
      mMinute = "${mMinute}0";
    }

    if(int.parse(mHour) > 12) {
      var mReminderHour = int.parse(mHour) % 12;
      mHour = mReminderHour.toString();
    }


    String period = hours >= 12 ? 'PM' : 'AM';
    String visibleTime = "$mHour:$mMinute $period";

    //double time = value/60;
    //String parsedValue = time.toString().replaceAll(".", ":");
    return visibleTime;
  }

}
