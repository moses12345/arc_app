class InfoLibModel {
  int? code;
  String? message;
  List<InfoLibData>? data;
  int? totalResult;
  int? limit;

  InfoLibModel({this.code, this.message, this.data, this.totalResult, this.limit});

  InfoLibModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <InfoLibData>[];
      json['data'].forEach((v) {
        data!.add(new InfoLibData.fromJson(v));
      });
    }
    totalResult = json['totalResult'];
    limit = json['limit'];
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
    return data;
  }
}

class InfoLibData {
  String? sId;
  String? companyId;
  String? name;
  String? description;
  List<String>? videoLink;
  String? manufacturer;
  List<Steps>? steps;
  String? metaData;
  AddedBy? addedBy;
  String? addedByType;
  String? status;
  String? type;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? id;

  InfoLibData(
      {this.sId,
        this.companyId,
        this.name,
        this.description,
        this.videoLink,
        this.manufacturer,
        this.steps,
        this.metaData,
        this.addedBy,
        this.addedByType,
        this.status,
        this.type,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.id});

  InfoLibData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    companyId = json['companyId'];
    name = json['name'];
    description = json['description'];
    videoLink = json['videoLink'].cast<String>();
    manufacturer = json['manufacturer'];
    if (json['steps'] != null) {
      steps = <Steps>[];
      json['steps'].forEach((v) {
        steps!.add(new Steps.fromJson(v));
      });
    }
    metaData = json['metaData'];
    addedBy =
    json['addedBy'] != null ? new AddedBy.fromJson(json['addedBy']) : null;
    addedByType = json['addedByType'];
    status = json['status'];
    type = json['type'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['companyId'] = companyId;
    data['name'] = name;
    data['description'] = description;
    data['videoLink'] = videoLink;
    data['manufacturer'] = manufacturer;
    if (steps != null) {
      data['steps'] = steps!.map((v) => v.toJson()).toList();
    }
    data['metaData'] = metaData;
    if (addedBy != null) {
      data['addedBy'] = addedBy!.toJson();
    }
    data['addedByType'] = addedByType;
    data['status'] = status;
    data['type'] = type;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['id'] = id;
    return data;
  }
}

class PatientId {
  String? sId;
  String? firstName;
  String? middleName;
  String? lastName;

  PatientId({this.sId, this.firstName, this.middleName, this.lastName});

  PatientId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firstName = json['firstName'];
    middleName = json['middleName'];
    lastName = json['lastName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['firstName'] = firstName;
    data['middleName'] = middleName;
    data['lastName'] = lastName;
    return data;
  }
}

class Steps {
  String? description;
  String? stepImage;

  Steps({this.description, this.stepImage});

  Steps.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    stepImage = json['stepImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['stepImage'] = stepImage;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['addedBy'] = addedBy;
    return data;
  }
}