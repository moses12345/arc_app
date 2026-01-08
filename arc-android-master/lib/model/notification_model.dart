class NotificationModel {
  int? code;
  String? message;
  List<NotificationData>? data;
  int? totalResult;
  int? limit;
  int? page;
  int? totalPages;

  NotificationModel(
      {this.code,
        this.message,
        this.data,
        this.totalResult,
        this.limit,
        this.page,
        this.totalPages});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <NotificationData>[];
      json['data'].forEach((v) {
        data!.add(NotificationData.fromJson(v));
      });
    }
    totalResult = json['totalResult'];
    limit = json['limit'];
    page = json['page'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalResult'] = totalResult;
    data['limit'] = limit;
    data['page'] = page;
    data['totalPages'] = totalPages;
    return data;
  }
}

class NotificationData {
  String? sId;
  String? title;
  String? content;
  String? image;
  String? type;
  String? sendTo;
  String? createdDate;
  String? id;

  NotificationData(
      {this.sId,
        this.title,
        this.image,
        this.type,
        this.sendTo,
        this.createdDate,
        this.id});

  NotificationData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    content = json['content'];
    image = json['image'];
    type = json['type'];
    sendTo = json['sendTo'];
    createdDate = json['createdDate'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['content'] = content;
    data['image'] = image;
    data['type'] = type;
    data['sendTo'] = sendTo;
    data['createdDate'] = createdDate;
    data['id'] = id;
    return data;
  }
}
