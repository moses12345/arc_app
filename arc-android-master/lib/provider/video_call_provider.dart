import 'package:arc/model/video_call_model.dart';
import 'package:arc/network/api.dart';
import 'package:flutter/material.dart';

class VideoCallProvider with ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  VideoCallModel? data;

  Future<void> initiateVideoCall(context, Map<String, String> body,) async {
    Api().initiateVideoCall(body, context).then((value) async => {
      if(value.code == 200) {
        _isLoading = false,
        data = value,
        notifyListeners(),
        _isLoading = true,
      } else {
        _isLoading = false,
        notifyListeners(),
    }
    });
  }

  Future<void> updateVideoCallStatus(context, String callID) async {
    Api().updateVideoCallStatus(callID, context).then((value) async => {
      if(value.code == 200) {
        notifyListeners(),
      } else {
        notifyListeners(),
      }
    });
  }
}