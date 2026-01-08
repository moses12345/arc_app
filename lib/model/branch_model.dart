
class BranchModel {
  int? code;
  String? message;
  List<BranchData>? data;

  BranchModel({this.code, this.message, this.data});

  BranchModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <BranchData>[];
      json['data'].forEach((v) {
        data!.add(BranchData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BranchData {
  String? id;
  String? companyId;
  String? name;
  String? abbreviation;
  String? email;

  BranchData({this.id, this.companyId, this.name, this.abbreviation, this.email,});

  BranchData.fromJson(Map map) {
    id = map['_id'];
    companyId = map['companyId'];
    name = map['name'];
    abbreviation = map['abbreviation'];
    email = map['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['companyId'] = companyId;
    data['name'] = name;
    data['abbreviation'] = abbreviation;
    data['email'] = email;
    return data;
  }
}
