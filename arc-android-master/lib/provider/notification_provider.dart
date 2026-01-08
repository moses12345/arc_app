import 'package:arc/model/exercises_model.dart';
import 'package:arc/model/notification_model.dart';
import 'package:arc/network/api.dart';
import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? message;
  List<NotificationData> notificationDataList = [];
  int page = 1;
  int limit = 20;
  bool isLastPage = false;

  Future<void> getNotification(context, String userId) async {
    Api().notification("$page", "$limit", userId, context).then((value) async => {
      if(value.code == 200) {
        _isLoading = true,
        message = value.message,
        if(value.data == null || value.data!.isEmpty) {
          isLastPage = true
        } else {
          if(page == 1) {
            notificationDataList.clear(),
            notificationDataList.addAll(value.data!)
          } else {
            notificationDataList.addAll(value.data!),
          },
          isLastPage = false,
          page = page + 1,
        },
        _isLoading = false,
        notifyListeners(),
      } else {
        _isLoading = false,
        message = value.message,
        notifyListeners(),
    }
    });
  }

  Future<void> sendNotification(body, context) async {
    Api().sendNotification(body, context).then((value) async => {
     
    });
  }
}