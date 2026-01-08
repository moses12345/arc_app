import 'dart:convert';
import 'package:arc/model/user_model.dart';
import 'package:arc/model/video_call_model.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper {

  static saveProfileData(UserModel userModel) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(KeyValue.authToken.name, userModel.data?.authToken ?? "");
    await prefs.setString(KeyValue.id.name, userModel.data?.id ?? "");
    await prefs.setString(KeyValue.companyId.name, userModel.data?.companyId ?? "");
    await prefs.setString(KeyValue.arcsId.name, userModel.data?.arcsId ?? "");
    await prefs.setString(KeyValue.fullName.name, userModel.data?.fullName ?? "");
    await prefs.setString(KeyValue.phone.name, userModel.data?.arcsId ?? "");
    await prefs.setString(KeyValue.email.name, userModel.data?.email ?? "");
    await prefs.setString(KeyValue.sex.name, userModel.data?.sex ?? "");
  }

  static Future<UserData> getUserProfile() async {
    var userData = UserData();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userData.authToken = prefs.getString(KeyValue.authToken.name);
    userData.id = prefs.getString(KeyValue.id.name);
    userData.companyId = prefs.getString(KeyValue.companyId.name);
    userData.arcsId = prefs.getString(KeyValue.arcsId.name);
    userData.fullName = prefs.getString(KeyValue.fullName.name);
    userData.phone = prefs.getString(KeyValue.phone.name);
    userData.email = prefs.getString(KeyValue.email.name);
    userData.sex = prefs.getString(KeyValue.sex.name);
    return userData;
  }

  static Future<String?> getUserID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? value = prefs.getString(KeyValue.id.name);

    if (kDebugMode) {
      print(value);
    }
    return value;
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? value = prefs.getString(KeyValue.authToken.name);

    if (kDebugMode) {
      print(value);
    }
    /*if (value != null) {
      bool isTokenExpired = JwtDecoder.isExpired(value.toString());
      if(isTokenExpired) {
        clearPreference();
      }
    }*/
    return value;
  }

  static Future<bool> getPasswordWarning() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(KeyValue.isPasswordWarning.name) ?? false;
  }

  static setPasswordWarning(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KeyValue.isPasswordWarning.name, value);
  }

  static clearPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  // Save pending call model for killed state recovery
  static Future<void> savePendingCallModel(VideoCallModel model) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final json = jsonEncode({
        'token': model.token,
        'channelName': model.channelName,
        'uid': model.uid,
        'waitingTime': model.waitingTime,
        'message': model.message,
        'isIncoming': model.isIncoming,
      });
      await prefs.setString(KeyValue.pendingCallModel.name, json);
      if (kDebugMode) {
        print("PreferenceHelper: Saved pending call model");
        print("PreferenceHelper: Channel: ${model.channelName}, Token: ${model.token}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("PreferenceHelper: Error saving pending call model: $e");
      }
    }
  }

  // Get pending call model for killed state recovery
  static Future<VideoCallModel?> getPendingCallModel() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(KeyValue.pendingCallModel.name);
      if (jsonString == null || jsonString.isEmpty) {
        if (kDebugMode) {
          print("PreferenceHelper: No persisted pending call model found");
        }
        return null;
      }
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final model = VideoCallModel(
        token: json['token'],
        channelName: json['channelName'],
        uid: json['uid'],
        waitingTime: json['waitingTime'],
        message: json['message'],
        userName: json['nameCaller']
      );
      model.isIncoming = json['isIncoming'] ?? false;
      if (kDebugMode) {
        print("PreferenceHelper: Retrieved pending call model");
        print("PreferenceHelper: Channel: ${model.channelName}, Token: ${model.token}, isIncoming: ${model.isIncoming}");
      }
      return model;
    } catch (e) {
      if (kDebugMode) {
        print("PreferenceHelper: Error parsing pending call model: $e");
      }
      return null;
    }
  }

  // Clear pending call model
  static Future<void> clearPendingCallModel() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(KeyValue.pendingCallModel.name);
    if (kDebugMode) {
      print("PreferenceHelper: Cleared pending call model");
    }
  }
}

enum KeyValue {
  authToken,
  id,
  companyId,
  arcsId,
  fullName,
  phone,
  email,
  sex,
  isPasswordWarning,
  pendingCallModel,
}
