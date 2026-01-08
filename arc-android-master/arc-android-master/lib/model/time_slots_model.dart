
class TimeSlotsModel {
  int? code;
  String? message;
  List<TimeSlotsData>? data;

  TimeSlotsModel({this.code, this.message, this.data});

  TimeSlotsModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <TimeSlotsData>[];
      json['data'].forEach((v) {
        data!.add(TimeSlotsData.fromJson(v));
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

class TimeSlotsData {
  int? from;
  int? to;
  int? booked;
  int? maxBooked;

  TimeSlotsData({this.from, this.to, this.booked, this.maxBooked,});

  TimeSlotsData.fromJson(Map map) {
    from = map['from'];
    to = map['to'];
    booked = map['booked'];
    maxBooked = map['maxBooked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['from'] = from;
    data['to'] = to;
    data['booked'] = booked;
    data['maxBooked'] = maxBooked;
    return data;
  }
}
