
class UserModel {
  int? code;
  String? message;
  UserData? data;

  UserModel({this.code, this.message, this.data});

  UserModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? UserData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class UserData {
  String? id;
  String? companyId;
  String? arcsId;
  String? fullName;
  String? phone;
  String? email;
  String? authToken;
  String? sex;

  UserData({this.id, this.companyId, this.arcsId, this.fullName, this.phone, this.email, this.authToken, this.sex});

  UserData.fromJson(Map map) {
    id = map['_id'];
    companyId = map['companyId'];
    arcsId = map['arcsId'];
    fullName = map['fullName'];
    phone = map['phone'];
    email = map['email'];
    authToken = map['authToken'];
    sex = map['sex'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['companyId'] = companyId;
    data['arcsId'] = arcsId;
    data['fullName'] = fullName;
    data['phone'] = phone;
    data['email'] = email;
    data['authToken'] = authToken;
    data['sex'] = sex;
    return data;
  }
}
