class ExistingAppointmentData {
  int? code;
  String? message;
  Data? data;

  ExistingAppointmentData({this.code, this.message, this.data});

  ExistingAppointmentData.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  ExistingAppointment? existingAppointment;

  Data({this.existingAppointment});

  Data.fromJson(Map<String, dynamic> json) {
    existingAppointment = json['exsitingAppointmentData'] != null
        ? ExistingAppointment.fromJson(json['exsitingAppointmentData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.existingAppointment != null) {
      data['exsitingAppointmentData'] = this.existingAppointment!.toJson();
    }
    return data;
  }
}

class ExistingAppointment {
  String? sId;
  String? appointmentId;
  int? appointmentDate;
  int? bookedFrom;
  int? bookedTo;

  ExistingAppointment(
      {this.sId,
        this.appointmentId,
        this.appointmentDate,
        this.bookedFrom,
        this.bookedTo});

  ExistingAppointment.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    appointmentId = json['appointmentId'];
    appointmentDate = json['appointmentDate'];
    bookedFrom = json['bookedFrom'];
    bookedTo = json['bookedTo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['appointmentId'] = this.appointmentId;
    data['appointmentDate'] = this.appointmentDate;
    data['bookedFrom'] = this.bookedFrom;
    data['bookedTo'] = this.bookedTo;
    return data;
  }
}
