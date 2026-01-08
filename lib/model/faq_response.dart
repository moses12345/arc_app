class FaqResponse {
  final int? code;
  final String? message;
  final List<FaqQuestion>? data;
  final int? totalResult;
  final int? limit;

  FaqResponse({
     this.code,
     this.message,
     this.data,
     this.totalResult,
     this.limit,
  });

  factory FaqResponse.fromJson(Map<String, dynamic> json) {
    return FaqResponse(
      code: json['code'],
      message: json['message'],
      data: (json['data'] as List).map((e) => FaqQuestion.fromJson(e)).toList(),
      totalResult: json['totalResult'],
      limit: json['limit'],
    );
  }
}

class FaqQuestion {
  String? name;
  List<FaqModel>? questions;

  FaqQuestion({this.name, this.questions});

  FaqQuestion.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['questions'] != null) {
      questions = <FaqModel>[];
      json['questions'].forEach((v) {
        questions!.add(new FaqModel.fromJson(v));
      });
    }
  }
}


class FaqModel {
  final String id;
  final String qid;
  final String question;
  final List<String> points;
  final String type; // STATIC | DYNAMIC | CONDITIONAL
  final Map<String, List<String>> conditionalPoint;
  final String status;
  bool isExpanded; // for UI expand/collapse state

  FaqModel({
    required this.id,
    required this.qid,
    required this.question,
    required this.points,
    required this.type,
    required this.conditionalPoint,
    required this.status,
    this.isExpanded = false,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> condPoints = {};

    if (json['conditionalPoint'] != null) {
      json['conditionalPoint'].forEach((key, value) {
        condPoints[key] = List<String>.from(value);
      });
    }

    return FaqModel(
      id: json['_id'] ?? json['id'],
      qid: json['qid'] ?? json['qid'],
      question: json['question'] ?? '',
      points: List<String>.from(json['points'] ?? []),
      type: json['type'] ?? '',
      conditionalPoint: condPoints,
      status: json['status'] ?? '',
    );
  }
}
