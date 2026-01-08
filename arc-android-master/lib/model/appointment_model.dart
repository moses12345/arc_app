
import 'package:arc/model/branch_model.dart';
import 'package:arc/model/user_model.dart';

class AppointmentModel {
  int? code;
  String? message;
  List<AppointmentData>? data;

  AppointmentModel({this.code, this.message, this.data});

  AppointmentModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <AppointmentData>[];
      json['data'].forEach((v) {
        data!.add(AppointmentData.fromJson(v));
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

class AppointmentData {
  String? id;
  String? appointmentId;
  UserData? patientId;
  BranchData? branchId;
  String? serviceType;
  int? appointmentDate;
  int? bookedFrom;
  int? bookedTo;
  String? status;
  String? addedBy;
  String? addedByType;
  String? createdDate;
  String? updatedDate;
  String? appointmentStatus;

  AppointmentData({this.id, this.appointmentId, this.patientId, this.branchId,  this.serviceType, this.appointmentDate, this.bookedFrom, this.bookedTo, this.status, this.addedBy, this.addedByType, this.createdDate, this.updatedDate, this.appointmentStatus});

  AppointmentData.fromJson(Map map) {
    id = map['_id'];
    appointmentId = map['appointmentId'];
    patientId = map['patientId'] != null ? UserData.fromJson(map['patientId']) : null;
    branchId = map['branchId'] != null ? BranchData.fromJson(map['branchId']) : null;
    serviceType = map['serviceType'];
    appointmentDate = map['appointmentDate'];
    bookedFrom = map['bookedFrom'];
    bookedTo = map['bookedTo'];
    status = map['status'];
    addedBy = map['addedBy'];
    addedByType = map['addedByType'];
    createdDate = map['createdDate'];
    updatedDate = map['updatedDate'];
    appointmentStatus = map['appointmentStatus'];
  }

  AppointmentData.fromNotification(Map map) {
    id = map['_id'];
    branchId = BranchData(id: map["branchID"], name: map["branchName"]);
    serviceType = map['serviceType'];
    appointmentDate = int.parse(map['appointmentDate']);
    bookedFrom = int.parse(map['bookedFrom']);
    bookedTo = int.parse(map['bookedTo']);
    appointmentStatus = map['appointmentStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['appointmentId'] = appointmentId;
    data['branchId'] = branchId;
    data['serviceType'] = serviceType;
    data['appointmentDate'] = appointmentDate;
    data['bookedFrom'] = bookedFrom;
    data['bookedTo'] = bookedTo;
    data['status'] = status;
    data['addedBy'] = addedBy;
    data['addedByType'] = addedByType;
    data['createdDate'] = createdDate;
    data['updatedDate'] = updatedDate;
    data['appointmentStatus'] = appointmentStatus;
    return data;
  }
}
