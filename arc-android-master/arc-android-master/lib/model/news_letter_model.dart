class NewsLetterModel {
  int? code;
  String? message;
  List<NewsLetterData>? data;
  int? totalResult;
  int? limit;

  NewsLetterModel(
      {this.code, this.message, this.data, this.totalResult, this.limit});

  NewsLetterModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <NewsLetterData>[];
      json['data'].forEach((v) {
        data!.add(new NewsLetterData.fromJson(v));
      });
    }
    totalResult = json['totalResult'];
    limit = json['limit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalResult'] = this.totalResult;
    data['limit'] = this.limit;
    return data;
  }
}

class NewsLetterData {
  String? sId;
  String? description;
  String? newsLetter;
  List<String>? pdfLinks;
  String? status;
  AddedBy? addedBy;
  String? addedByType;
  String? id;

  NewsLetterData(
      {this.sId,
        this.description,
        this.newsLetter,
        this.pdfLinks,
        this.status,
        this.addedBy,
        this.addedByType,
        this.id});

  NewsLetterData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    description = json['description'];
    newsLetter = json['newsLetter'];
    pdfLinks = json['pdfLinks'] != null ? List<String>.from(json['pdfLinks']) : [];
    status = json['status'];
    addedBy =
    json['addedBy'] != null ? new AddedBy.fromJson(json['addedBy']) : null;
    addedByType = json['addedByType'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['description'] = this.description;
    data['newsLetter'] = this.newsLetter;
    data['pdfLinks'] = this.pdfLinks;
    data['status'] = this.status;
    if (addedBy != null) {
      data['addedBy'] = this.addedBy!.toJson();
    }
    data['addedByType'] = this.addedByType;
    data['id'] = this.id;
    return data;
  }
}

class AddedBy {
  String? name;
  String? addedBy;

  AddedBy({this.name, this.addedBy});

  AddedBy.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    addedBy = json['addedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['addedBy'] = this.addedBy;
    return data;
  }
}
