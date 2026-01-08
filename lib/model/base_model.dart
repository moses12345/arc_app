class BaseModel {
  int? code;
  String? message;
  String? answer;
  String? token;
  int? resetOtp;
  Map<String, dynamic>? response;

  BaseModel({this.code, this.message, this.answer, this.token});

  BaseModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    answer = json['answer'];
    resetOtp = json['resetOtp'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['message'] = message;
    data['answer'] = answer;
    data['resetOtp'] = resetOtp;
    data['token'] = token;
    return data;
  }
}