class VideoCallModel {
  int? code;
  String? message;
  String? token;
  String? channelName;
  String? uid;
  String? branchId;
  String? branchName;
  String? userId;
  String? userName;
  int? waitingTime;
  bool isIncoming = false;

  VideoCallModel({this.code, this.message, this.token, this.channelName, this.uid, this.waitingTime, this.userName});

  VideoCallModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    token = json['token'];
    uid = json['uid'];
    waitingTime = json['waitingTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['message'] = message;
    data['token'] = token;
    data['uid'] = uid;
    data['waitingTime'] = waitingTime;
    data['nameCaller'] = userName;
    return data;
  }
}