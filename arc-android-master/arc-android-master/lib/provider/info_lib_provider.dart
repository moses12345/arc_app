import 'package:arc/model/InfoLibModel.dart';
import 'package:arc/model/news_letter_model.dart';
import 'package:arc/network/api.dart';
import 'package:flutter/material.dart';

class InfoLibProvider with ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  String? message;
  final List<InfoLibData> _infoLibDataList = [];
  List<InfoLibData> get infoLibDataList => _infoLibDataList;
  bool isLastPage = false;
  int page = 1;
  int limit = 20;

  void setLoading(bool value) {
    _isLoading = value;
    //notifyListeners(); // If using Provider/ChangeNotifier
  }

  Future<void> getInfoLib(String type, context) async {
    Api().infoLib("$page", "$limit", type, context).then((value) async => {
      if(value.code == 200) {
        _isLoading = false,
        message = value.message,
        if(value.data == null || value.data!.isEmpty) {
          isLastPage = true
        } else {
          if(page == 1) {
            infoLibDataList.clear(),
            infoLibDataList.addAll(value.data!),
          } else {
            infoLibDataList.addAll(value.data!),
          },
          isLastPage = false,
          page = page + 1,
        },
        notifyListeners(),
      } else {
        _isLoading = true,
        message = value.message,
        notifyListeners(),
    }
    });
  }
}