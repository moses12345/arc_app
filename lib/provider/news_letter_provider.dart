import 'package:arc/model/base_model.dart';
import 'package:arc/model/faq_response.dart';
import 'package:arc/model/news_letter_model.dart';
import 'package:arc/network/api.dart';
import 'package:flutter/material.dart';

class NewsLetterProvider with ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  String? message;
  final List<NewsLetterData> _newsLetterDataList = [];
  List<NewsLetterData> get newsLetterDataList => _newsLetterDataList;
  bool isLastPage = false;
  int page = 1;
  int limit = 10;

  bool _isFaqLoading = true;
  bool get isFaqLoading => _isFaqLoading;
  final List<FaqQuestion> _faqDataList = [];
  List<FaqQuestion> get faqDataList => _faqDataList;

  bool _isAnswerLoading = true;
  bool get isAnswerLoading => _isAnswerLoading;
  String? answer;

  Future<void> getNewsLetter(context) async {
    Api().newsLetter("$page", "$limit", context).then((value) async => {
      if(value.code == 200) {
        _isLoading = false,
        message = value.message,
        if(value.data == null || value.data!.isEmpty) {
          isLastPage = true
        } else {
          if(page == 1) {
            _newsLetterDataList.clear(),
            _newsLetterDataList.addAll(value.data!),
          } else {
            _newsLetterDataList.addAll(value.data!),
          },
          isLastPage = false,
          page = page + 1,
        },
        _isLoading = false,
        notifyListeners(),
      } else {
        _isLoading = true,
        message = value.message,
        notifyListeners(),
    }
    });
  }

  Future<void> getFaqQuestions(context) async {
    Api().getFaqQuestions("$page", "$limit", context).then((value) async => {
      if(value.code == 200) {
        _isFaqLoading = false,
        if(value.data != null) {
          _faqDataList.clear(),
          _faqDataList.addAll(value.data!)
        },
        notifyListeners()
      }
    });
  }

  Future<void> getFaqAnswerOfQuestions(String questionId, context) async {
    _isAnswerLoading = true;
    answer = null; // Clear previous answer
    notifyListeners();
    
    try {
      final value = await Api().getFaqAnswerOfQuestions(questionId, context);
      if(value.code == 200) {
        _isAnswerLoading = false;
        answer = value.answer;
        notifyListeners();
      } else {
        _isAnswerLoading = false;
        answer = null;
        notifyListeners();
      }
    } catch (e) {
      _isAnswerLoading = false;
      answer = null;
      notifyListeners();
    }
  }
}