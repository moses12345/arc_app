class ActiveClaimsModel {
  int? code;
  String? message;
  ActiveClaimsData? data;

  ActiveClaimsModel({this.code, this.message, this.data});

  factory ActiveClaimsModel.fromJson(Map<String, dynamic> json) {
    return ActiveClaimsModel(
      code: json['code'] as int?,
      message: json['message'] as String?,
      data: json['data'] != null ? ActiveClaimsData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'data': data?.toJson(),
      };
}

class ActiveClaimsData {
  bool? showNewToARCsPopup;
  bool? showConditionPopup;
  List<Claim>? claims;

  ActiveClaimsData({this.showNewToARCsPopup, this.showConditionPopup, this.claims});

  factory ActiveClaimsData.fromJson(Map<String, dynamic> json) {
    return ActiveClaimsData(
      showNewToARCsPopup: json['showNewToARCsPopup'] as bool?,
      showConditionPopup: json['showConditionPopup'] as bool?,
      claims: json['claims'] != null
          ? List<Claim>.from((json['claims'] as List).map((x) => Claim.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'showNewToARCsPopup': showNewToARCsPopup,
        'showConditionPopup': showConditionPopup,
        'claims': claims?.map((c) => c.toJson()).toList(),
      };
}

class Claim {
  String? id;
  String? serviceType;
  String? ctId;
  String? claimStatus;
  dynamic privatePay; // can be empty string or number
  List<String>? warnings;
  List<String>? errors;

  Claim({this.id, this.serviceType, this.ctId, this.claimStatus, this.privatePay, this.warnings, this.errors});

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      id: json['_id'] as String?,
      serviceType: json['serviceType'] as String?,
      ctId: json['ctId'] as String?,
      claimStatus: json['claimStatus'] as String?,
      privatePay: json['privatePay'],
      warnings: json['warnings'] != null ? List<String>.from((json['warnings'] as List).map((e) => e.toString())) : null,
      errors: json['errors'] != null ? List<String>.from((json['errors'] as List).map((e) => e.toString())) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'serviceType': serviceType,
        'ctId': ctId,
        'claimStatus': claimStatus,
        'privatePay': privatePay,
        'warnings': warnings,
        'errors': errors,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Claim && (other.ctId == ctId) && (other.serviceType == serviceType) && (other.id == id);
  }

  @override
  int get hashCode => (ctId ?? '').hashCode ^ (serviceType ?? '').hashCode ^ (id ?? '').hashCode;
}
