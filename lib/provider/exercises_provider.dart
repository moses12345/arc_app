import 'package:arc/model/exercises_model.dart';
import 'package:arc/network/api.dart';
import 'package:flutter/material.dart';

class ExercisesProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? message;
  List<Data> exercisesData = [];
  int page = 1;
  int limit = 20;
  bool isLastPage = false;

  Future<void> getExercises(context) async {
    Api().exercises("$page", "$limit", context).then((value) async => {
      if(value.code == 200) {
        _isLoading = true,
        message = value.message,
        if(value.data == null || value.data!.isEmpty) {
          isLastPage = true
        } else {
          if(page == 1) {
            exercisesData.clear(),
            exercisesData.addAll(value.data!)
          } else {
            exercisesData.addAll(value.data!),
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
}