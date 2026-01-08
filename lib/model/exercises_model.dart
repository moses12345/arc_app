class ExercisesModel {
  int? code;
  String? message;
  List<Data>? data;

  ExercisesModel({this.code, this.message, this.data});

  ExercisesModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
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

class Data {
  List<ExerciseData>? exerciseList;
  String? type;
  String? sId;
  String? categoryName;

  Data({this.exerciseList, this.type, this.sId, this.categoryName});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['exerciseList'] != null) {
      exerciseList = <ExerciseData>[];
      json['exerciseList'].forEach((v) {
        exerciseList!.add(ExerciseData.fromJson(v));
      });
    }
    type = json['type'];
    sId = json['_id'];
    categoryName = json['categoryName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (exerciseList != null) {
      data['exerciseList'] = exerciseList!.map((v) => v.toJson()).toList();
    }
    data['type'] = type;
    data['_id'] = sId;
    data['categoryName'] = categoryName;
    return data;
  }
}

class ExerciseData {
  String? sId;
  String? companyId;
  String? description;
  String? exerciseName;
  List<String>? imageLink;
  List<String>? videoLink;
  //List<PatientId>? patientId;
  Category? category;
  Category? subCategory;
  String? status;
  AddedBy? addedBy;
  String? addedByType;
  String? createdDate;
  String? updatedDate;
  int? iV;
  List<ExerciseSteps>? exerciseSteps;
  int? exerciseTime;
  String? id;
  String? version;

  ExerciseData(
      {this.sId,
        this.companyId,
        this.description,
        this.exerciseName,
        this.imageLink,
        this.videoLink,
        //this.patientId,
        this.category,
        this.subCategory,
        this.status,
        this.addedBy,
        this.addedByType,
        this.createdDate,
        this.updatedDate,
        this.iV,
        this.exerciseSteps,
        this.exerciseTime,
        this.id,
        this.version});

  ExerciseData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    companyId = json['companyId'];
    description = json['description'];
    exerciseName = json['exerciseName'];
    imageLink = json['imageLink'].cast<String>();
    videoLink = json['videoLink'].cast<String>();
    /*if (json['patientId'] != null) {
      patientId = <PatientId>[];
      json['patientId'].forEach((v) {
        patientId!.add(new PatientId.fromJson(v));
      });
    }*/
    category = json['category'] != null
        ? Category.fromJson(json['category'])
        : null;
    subCategory = json['subCategory'] != null
        ? Category.fromJson(json['subCategory'])
        : null;
    status = json['status'];
    addedBy =
    json['addedBy'] != null ? AddedBy.fromJson(json['addedBy']) : null;
    addedByType = json['addedByType'];
    createdDate = json['createdDate'];
    updatedDate = json['updatedDate'];
    iV = json['__v'];
    exerciseSteps = (json.containsKey('exerciseSteps') && json['exerciseSteps'] != null)
        ? (json['exerciseSteps'] as List)
        .map((v) => ExerciseSteps.fromJson(v))
        .toList()
        : [];
    exerciseTime = json['exerciseTime'];
    id = json['id'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['companyId'] = companyId;
    data['description'] = description;
    data['exerciseName'] = exerciseName;
    data['imageLink'] = imageLink;
    data['videoLink'] = videoLink;
    /*if (this.patientId != null) {
      data['patientId'] = this.patientId!.map((v) => v.toJson()).toList();
    }*/
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (subCategory != null) {
      data['subCategory'] = subCategory!.toJson();
    }
    data['status'] = status;
    if (addedBy != null) {
      data['addedBy'] = addedBy!.toJson();
    }
    data['addedByType'] = addedByType;
    data['createdDate'] = createdDate;
    data['updatedDate'] = updatedDate;
    data['__v'] = iV;
    if (exerciseSteps != null) {
      data['exerciseSteps'] =
          exerciseSteps!.map((v) => v.toJson()).toList();
    }
    data['exerciseTime'] = exerciseTime;
    data['id'] = id;
    data['version'] = version;
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

class Category {
  String? sId;
  String? categoryName;

  Category({this.sId, this.categoryName});

  Category.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    categoryName = json['categoryName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['categoryName'] = categoryName;
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

class ExerciseSteps {
  String? description;
  String? stepImage;

  ExerciseSteps({this.description, this.stepImage});

  ExerciseSteps.fromJson(Map<String, dynamic> json) {
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
