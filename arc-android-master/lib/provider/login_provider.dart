import 'package:arc/model/base_model.dart';
import 'package:arc/network/api.dart';
import 'package:arc/utils/preference_helper.dart';
import 'package:flutter/material.dart';

class LoginProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String? _authMessage = '';
  String? get authMessage => _authMessage;

  BaseModel? _baseModelForgot;
  BaseModel? get baseModelForgot => _baseModelForgot;

  BaseModel? _baseModelReset;
  BaseModel? get baseModelReset => _baseModelReset;

  BaseModel? _baseModelChange;
  BaseModel? get baseModelChange => _baseModelChange;


  void clearMessage() {
    _authMessage = '';
    _baseModelForgot = null;
    _baseModelReset = null;
    _baseModelChange = null;
  }

  Future<void> login(body, context) async {
    final value = await Api().login(body, context);
    _handleAuthInfo(value);
  }

  Future<void> signup(body, context) async {
    final value = await Api().signup(body, context);
    _handleAuthInfo(value);
  }

  void _handleAuthInfo(value) async {
    if(value.code == 200) {
      await PreferenceHelper.saveProfileData(value);
      _isAuthenticated = true;
    } else {
      _isAuthenticated = false;
    }
    _authMessage = value.message;
    notifyListeners();
    clearMessage();
  }

  Future<void> forgotPassword(body, context) async {
    final value = await Api().forgotPassword(body, context);
    _baseModelForgot = value;
    notifyListeners();
  }

  Future<void> resetPassword(body, context) async {
    final value = await Api().resetPassword(body, context);
    _baseModelReset = value;
    notifyListeners();
  }

  Future<void> changePassword(body, context) async {
    final value = await Api().changePassword(body, context);
    _baseModelChange = value;
    notifyListeners();
  }


  Future<void> updateFCMToken(body, context) async {
    Api().updateFCMToken(body, context);
  }
}