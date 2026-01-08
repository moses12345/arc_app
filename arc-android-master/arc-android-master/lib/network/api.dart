import 'dart:convert';
import 'dart:ffi';

import 'package:arc/model/InfoLibModel.dart';
import 'package:arc/model/appointment_model.dart';
import 'package:arc/model/base_model.dart';
import 'package:arc/model/branch_model.dart';
import 'package:arc/model/exercises_model.dart';
import 'package:arc/model/faq_response.dart';
import 'package:arc/model/news_letter_model.dart';
import 'package:arc/model/notification_model.dart';
import 'package:arc/model/time_slots_model.dart';
import 'package:arc/model/user_model.dart';
import 'package:arc/model/video_call_model.dart';
import 'package:arc/model/active_claims_model.dart';
import 'package:arc/onboarding/login_screen.dart';
import 'package:arc/utils/preference_helper.dart';
import 'package:arc/utils/progress_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'logging_interceptor.dart';
import 'package:arc/configuration/config_provider.dart';

class Api {

  //final String baseUrl = "http://54.165.255.125:3001/api/v1/";
  //final String baseUrl = "https://api.arcofficepro.com/api/v1/";
  //final String baseUrl = "https://dev-api.arcofficepro.com/api/v1/";
  final String baseUrl = ConfigProvider.config.baseUrl;

  late ProgressDialog progressDialog;

  Future<UserModel> signup(Map<String, String> body, BuildContext context) async {
    progressDialog = ProgressDialog(context, ProgressDialogType.normal);
    progressDialog.show();
    try {
      var auth = 'Basic ${base64Encode(utf8.encode('arcApp:arcApp@4321'))}';
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      dio.options.headers["authorization"] = auth;
      Response response = await dio.post("${baseUrl}patients/sign-up/", data: jsonEncode(body));
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      progressDialog.hide();
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      progressDialog.hide();
      if (e.response != null) {
        if (kDebugMode) {
          print(e.response?.data);
          print(e.response?.headers);
          print(e.response?.requestOptions);
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      UserModel baseModel = UserModel();
      Map<String, dynamic> data = e.response?.data;
      baseModel.code = data['code'] as int;
      baseModel.message = data['message'] as String;
      return baseModel;
    }
  }

  Future<UserModel> login(Map<String, String> body, BuildContext context) async {
    progressDialog = ProgressDialog(context, ProgressDialogType.normal);
    progressDialog.show();
    try {
      var auth = 'Basic ${base64Encode(utf8.encode('arcApp:arcApp@4321'))}';
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      dio.options.headers["authorization"] = auth;
      Response response = await dio.post("${baseUrl}patients/login/", data: jsonEncode(body));
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      progressDialog.hide();
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      progressDialog.hide();
      if (e.response != null) {
        if (kDebugMode) {
          print('Data: ${e.response?.data}');
          print('Headers: ${e.response?.headers}');
          print('Request Options: ${e.response?.requestOptions}');
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      UserModel userModel = UserModel();
      Map<String, dynamic> data = e.response?.data;
      userModel.code = data['code'] as int;
      userModel.message = data['message'] as String;
      return userModel;
    }
  }

  Future<NewsLetterModel> newsLetter(String page, String limit, BuildContext context) async {
    //progressDialog = ProgressDialog(context, ProgressDialogType.normal);
    //progressDialog.show();
    try {
      var auth = 'Basic ${base64Encode(utf8.encode('arcApp:arcApp@4321'))}';
      String? token = await PreferenceHelper.getToken();
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      //dio.options.headers["authorization"] = auth;
      dio.options.headers["Authorization"] = '$token';
      //Response response = await dio.get("${baseUrl}patients/news-letter?page=$page&limit=$limit");
      Response response = await dio.get("${baseUrl}news-letter-app?page=$page&limit=$limit");
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      //progressDialog.hide();
      return NewsLetterModel.fromJson(response.data);
    } on DioException catch (e) {
      //progressDialog.hide();
      if (e.response != null) {
        if (kDebugMode) {
          print('Data: ${e.response?.data}');
          print('Headers: ${e.response?.headers}');
          print('Request Options: ${e.response?.requestOptions}');
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      NewsLetterModel newsLetterModel = NewsLetterModel();
      return newsLetterModel;
    }
  }

  Future<ExercisesModel> exercises(String page, String limit, BuildContext context) async {
    try {
      String? token = await PreferenceHelper.getToken();
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      var auth = 'Basic ${base64Encode(utf8.encode('arcApp:arcApp@4321'))}';
      //dio.options.headers["Authorization"] = auth;
      dio.options.headers["Authorization"] = '$token';
      //Response response = await dio.get("${baseUrl}exercise-admin?page=$page&limit=$limit");
      Response response = await dio.get("${baseUrl}patients/exercise?page=$page&limit=$limit");
      //Response response = await dio.get("${baseUrl}patients/exercise?page=$page&limit=$limit");
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      return ExercisesModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        if (kDebugMode) {
          print('Data: ${e.response?.data}');
          print('Headers: ${e.response?.headers}');
          print('Request Options: ${e.response?.requestOptions}');
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      ExercisesModel model = ExercisesModel();
      return model;
    }
  }

  Future<BranchModel> getBranchList(String page, String limit, BuildContext context) async {
    try {
      String? token = await PreferenceHelper.getToken();
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      dio.options.headers["Authorization"] = '$token';
      Response response = await dio.get("${baseUrl}patients/branches?page=$page&limit=$limit");
      if (kDebugMode) {
        print('Branch Response: ${response.data}');
      }
      return BranchModel.fromJson(response.data);
    } on DioException catch (e) {
      if(e.response?.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const LoginScreen()));
      }
      if (e.response != null) {
        if (kDebugMode) {
          print('Data: ${e.response?.data}');
          print('Headers: ${e.response?.headers}');
          print('Request Options: ${e.response?.requestOptions}');
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      BranchModel model = BranchModel();
      return model;
    }
  }

  Future<TimeSlotsModel> getBranchesSlot(String bookingDate, String branchId, BuildContext context) async {
    progressDialog = ProgressDialog(context, ProgressDialogType.normal);
    progressDialog.show();
    try {
      String? token = await PreferenceHelper.getToken();
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      dio.options.headers["Authorization"] = '$token';
      Response response = await dio.get("${baseUrl}patients/branches-slot?bookingDate=$bookingDate&branchId=$branchId");
      /*if (kDebugMode) {
        print('Response: ${response.data}');
      }*/
      progressDialog.hide();
      return TimeSlotsModel.fromJson(response.data);
    } on DioException catch (e) {
      if(e.response?.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const LoginScreen()));
      }
      progressDialog.hide();
      if (e.response != null) {
        if (kDebugMode) {
          print('Data: ${e.response?.data}');
          print('Headers: ${e.response?.headers}');
          print('Request Options: ${e.response?.requestOptions}');
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      TimeSlotsModel model = TimeSlotsModel();
      return model;
    }
  }

  Future<BaseModel> bookAppointment(Map<String, dynamic> body, BuildContext context) async {
    progressDialog = ProgressDialog(context, ProgressDialogType.normal);
    progressDialog.show();
    try {
      String? token = await PreferenceHelper.getToken();
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      dio.options.headers["Authorization"] = '$token';
      Response response = await dio.post("${baseUrl}patients/book-appointment", data: jsonEncode(body));
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      progressDialog.hide();
      return BaseModel.fromJson(response.data);
    } on DioException catch (e) {
      progressDialog.hide();
      if (e.response != null) {
        if (kDebugMode) {
          print('Data: ${e.response?.data}');
          print('Headers: ${e.response?.headers}');
          print('Request Options: ${e.response?.requestOptions}');
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      BaseModel model = BaseModel();
      Map<String, dynamic> data = e.response?.data;
      model.code = 400;
      model.message = data['message'] as String;
      model.response = e.response?.data;
      return model;
    }
  }

  Future<BaseModel> rescheduleAppointment(Map<String, dynamic> body, BuildContext context) async {
    progressDialog = ProgressDialog(context, ProgressDialogType.normal);
    progressDialog.show();
    try {
      String? token = await PreferenceHelper.getToken();
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      dio.options.headers["Authorization"] = '$token';
      Response response = await dio.post("${baseUrl}patients/reschedule-appointment", data: jsonEncode(body));
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      try {
        progressDialog.hide();
      } catch(e) {
        if (kDebugMode) {
          print('Exception');
        }
      }
      return BaseModel.fromJson(response.data);
    } on DioException catch (e) {
      progressDialog.hide();
      if (e.response != null) {
        if (kDebugMode) {
          print('Data: ${e.response?.data}');
          print('Headers: ${e.response?.headers}');
          print('Request Options: ${e.response?.requestOptions}');
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      BaseModel model = BaseModel();
      Map<String, dynamic> data = e.response?.data;
      model.code = 400;
      model.message = data['message'] as String;
      model.response = e.response?.data;
      return model;
    }
  }

  Future<AppointmentModel> getAppointmentList(String appointmentDate, String page, String limit, BuildContext context) async {
    try {
      String? token = await PreferenceHelper.getToken();
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      dio.options.headers["Authorization"] = '$token';
      Response response = await dio.get("${baseUrl}patients/appointment-list?appointmentDate=$appointmentDate&page=$page&limit=$limit");
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      return AppointmentModel.fromJson(response.data);
    } on DioException catch (e) {
      if(e.response?.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const LoginScreen()));
      }
      if (e.response != null) {
        if (kDebugMode) {
          print('Data: ${e.response?.data}');
          print('Headers: ${e.response?.headers}');
          print('Request Options: ${e.response?.requestOptions}');
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      AppointmentModel model = AppointmentModel();
      return model;
    }
  }

  Future<BaseModel> cancelAppointment(String appointmentId, BuildContext context) async {
    progressDialog = ProgressDialog(context, ProgressDialogType.normal);
    progressDialog.show();
    try {
      String? token = await PreferenceHelper.getToken();
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      dio.options.headers["Authorization"] = '$token';
      Response response = await dio.put("${baseUrl}patients/cancel-appointment/$appointmentId");
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      progressDialog.hide();
      return BaseModel.fromJson(response.data);
    } on DioException catch (e) {
      progressDialog.hide();
      if (e.response != null) {
        if (kDebugMode) {
          print('Data: ${e.response?.data}');
          print('Headers: ${e.response?.headers}');
          print('Request Options: ${e.response?.requestOptions}');
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      BaseModel model = BaseModel();
      return model;
    }
  }

  Future<VideoCallModel> initiateVideoCall(Map<String, String> body, BuildContext context) async {
    try {
      progressDialog = ProgressDialog(context, ProgressDialogType.normal);
      progressDialog.show();
      String? token = await PreferenceHelper.getToken();
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      dio.options.headers["Authorization"] = '$token';
      //Response response = await dio.post("${baseUrl}patients/token", data: jsonEncode(body));
      Response response = await dio.post("${baseUrl}intiate/token", data: jsonEncode(body));
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      progressDialog.hide();
      return VideoCallModel.fromJson(response.data);
    } on DioException catch (e) {
      progressDialog.hide();
      if (e.response != null) {
        if (kDebugMode) {
          print('Data: ${e.response?.data}');
          print('Headers: ${e.response?.headers}');
          print('Request Options: ${e.response?.requestOptions}');
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      VideoCallModel model = VideoCallModel();
      return model;
    }
  }

  Future<VideoCallModel> updateVideoCallStatus(String callID, BuildContext context) async {
    try {
      String? token = await PreferenceHelper.getToken();
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      dio.options.headers["Authorization"] = '$token';
      Response response = await dio.get("${baseUrl}intiate/db/$callID/decline");
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      return VideoCallModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        if (kDebugMode) {
          print('Data: ${e.response?.data}');
          print('Headers: ${e.response?.headers}');
          print('Request Options: ${e.response?.requestOptions}');
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      VideoCallModel model = VideoCallModel();
      return model;
    }
  }

  Future<InfoLibModel> infoLib(String page, String limit, String type, BuildContext context) async {
    //progressDialog = ProgressDialog(context, ProgressDialogType.normal);
    //progressDialog.show();
    try {
      var auth = 'Basic ${base64Encode(utf8.encode('arcApp:arcApp@4321'))}';
      String? token = await PreferenceHelper.getToken();
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      //dio.options.headers["authorization"] = auth;
      dio.options.headers["Authorization"] = '$token';
      //Response response = await dio.get("${baseUrl}patients/news-letter?page=$page&limit=$limit");
      Response response = await dio.get("${baseUrl}patients/info-library-app?page=$page&limit=$limit&type=$type");
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      //progressDialog.hide();
      return InfoLibModel.fromJson(response.data);
    } on DioException catch (e) {
      //progressDialog.hide();
      if (e.response != null) {
        if (kDebugMode) {
          print('Data: ${e.response?.data}');
          print('Headers: ${e.response?.headers}');
          print('Request Options: ${e.response?.requestOptions}');
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      InfoLibModel infoLibModel = InfoLibModel();
      return infoLibModel;
    }
  }

  Future<BaseModel> forgotPassword(Map<String, String> body, BuildContext context) async {
    progressDialog = ProgressDialog(context, ProgressDialogType.normal);
    progressDialog.show();
    try {
      var auth = 'Basic ${base64Encode(utf8.encode('arcApp:arcApp@4321'))}';
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      dio.options.headers["authorization"] = auth;
      Response response = await dio.post("${baseUrl}patients/forgot-password", data: jsonEncode(body));
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      progressDialog.hide();
      return BaseModel.fromJson(response.data);
    } on DioException catch (e) {
      progressDialog.hide();
      if (e.response != null) {
        if (kDebugMode) {
          print(e.response?.data);
          print(e.response?.headers);
          print(e.response?.requestOptions);
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      BaseModel baseModel = BaseModel();
      Map<String, dynamic> data = e.response?.data;
      baseModel.code = data['code'] as int;
      baseModel.message = data['message'] as String;
      return baseModel;
    }
  }

  Future<BaseModel> resetPassword(Map<String, String> body, BuildContext context) async {
    progressDialog = ProgressDialog(context, ProgressDialogType.normal);
    progressDialog.show();
    try {
      var auth = 'Basic ${base64Encode(utf8.encode('arcApp:arcApp@4321'))}';
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      dio.options.headers["authorization"] = auth;
      Response response = await dio.post("${baseUrl}patients/reset-password", data: jsonEncode(body));
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      progressDialog.hide();
      return BaseModel.fromJson(response.data);
    } on DioException catch (e) {
      progressDialog.hide();
      if (e.response != null) {
        if (kDebugMode) {
          print(e.response?.data);
          print(e.response?.headers);
          print(e.response?.requestOptions);
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      BaseModel baseModel = BaseModel();
      Map<String, dynamic> data = e.response?.data;
      baseModel.code = data['code'] as int;
      baseModel.message = data['message'] as String;
      return baseModel;
    }
  }

  Future<BaseModel> changePassword(Map<String, String> body, BuildContext context) async {
    progressDialog = ProgressDialog(context, ProgressDialogType.normal);
    progressDialog.show();
    try {
      String? token = await PreferenceHelper.getToken();
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      dio.options.headers["Authorization"] = '$token';
      Response response = await dio.post("${baseUrl}patients/change-password", data: jsonEncode(body));
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      progressDialog.hide();
      return BaseModel.fromJson(response.data);
    } on DioException catch (e) {
      progressDialog.hide();
      if (e.response != null) {
        if (kDebugMode) {
          print(e.response?.data);
          print(e.response?.headers);
          print(e.response?.requestOptions);
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      BaseModel baseModel = BaseModel();
      Map<String, dynamic> data = e.response?.data;
      baseModel.code = data['code'] as int;
      baseModel.message = data['message'] as String;
      return baseModel;
    }
  }

  Future<NotificationModel> notification(String page, String limit, String userId, BuildContext context) async {
    //progressDialog = ProgressDialog(context, ProgressDialogType.normal);
    //progressDialog.show();
    try {
      var auth = 'Basic ${base64Encode(utf8.encode('arcApp:arcApp@4321'))}';
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      dio.options.headers["authorization"] = auth;
      Response response = await dio.get("${baseUrl}notifications?page=$page&limit=$limit&id=$userId");
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      //progressDialog.hide();
      return NotificationModel.fromJson(response.data);
    } on DioException catch (e) {
      //progressDialog.hide();
      if (e.response != null) {
        if (kDebugMode) {
          print(e.response?.data);
          print(e.response?.headers);
          print(e.response?.requestOptions);
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      NotificationModel baseModel = NotificationModel();
      Map<String, dynamic> data = e.response?.data;
      baseModel.code = data['code'] as int;
      baseModel.message = data['message'] as String;
      return baseModel;
    }
  }


  Future<FaqResponse> getFaqQuestions(String page, String limit, BuildContext context) async {
    //progressDialog = ProgressDialog(context, ProgressDialogType.normal);
    //progressDialog.show();
    try {
      String? token = await PreferenceHelper.getToken();
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      //dio.options.headers["authorization"] = auth;
      dio.options.headers["Authorization"] = '$token';
      Response response = await dio.get("${baseUrl}patients/question_answers/updated");
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      //progressDialog.hide();
      return FaqResponse.fromJson(response.data);
    } on DioException catch (e) {
      //progressDialog.hide();
      if (e.response != null) {
        if (kDebugMode) {
          print('Data: ${e.response?.data}');
          print('Headers: ${e.response?.headers}');
          print('Request Options: ${e.response?.requestOptions}');
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      FaqResponse baseModel = FaqResponse();
      return baseModel;
    }
  }

  Future<BaseModel> getFaqAnswerOfQuestions(String questionId, BuildContext context) async {
    //progressDialog = ProgressDialog(context, ProgressDialogType.normal);
    //progressDialog.show();
    try {
      String? token = await PreferenceHelper.getToken();
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      //dio.options.headers["authorization"] = auth;
      dio.options.headers["Authorization"] = '$token';
      Response response = await dio.get("${baseUrl}patients/question_answers/$questionId");
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      //progressDialog.hide();
      return BaseModel.fromJson(response.data);
    } on DioException catch (e) {
      //progressDialog.hide();
      if (e.response != null) {
        if (kDebugMode) {
          print('Data: ${e.response?.data}');
          print('Headers: ${e.response?.headers}');
          print('Request Options: ${e.response?.requestOptions}');
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      BaseModel baseModel = BaseModel();
      return baseModel;
    }
  }

  Future<ActiveClaimsModel> getActiveClaims(BuildContext context) async {
    try {
      String? token = await PreferenceHelper.getToken();
      String? userID = await PreferenceHelper.getUserID();

      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      dio.options.headers["Authorization"] = '$token';
      Response response = await dio.get("${baseUrl}patients/active-claims/$userID");
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      return ActiveClaimsModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        if (kDebugMode) {
          print('Data: ${e.response?.data}');
          print('Headers: ${e.response?.headers}');
          print('Request Options: ${e.response?.requestOptions}');
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      ActiveClaimsModel model = ActiveClaimsModel();
      return model;
    }
  }

  Future<BaseModel> logUnfinishedAppointments(Map<String, dynamic> body, BuildContext context) async {
    try {
      String? token = await PreferenceHelper.getToken();
      String? userID = await PreferenceHelper.getUserID();

      body['patient_id'] = userID!;

      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      dio.options.headers["Authorization"] = '$token';
      Response response = await dio.post("${baseUrl}patients/appointment-cancel-notifications", data: jsonEncode(body));
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      return BaseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        if (kDebugMode) {
          print('Data: ${e.response?.data}');
          print('Headers: ${e.response?.headers}');
          print('Request Options: ${e.response?.requestOptions}');
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      BaseModel baseModel = BaseModel();
      return baseModel;
    }
  }

  Future<BaseModel> sendNotification(Map<String, String> body, BuildContext context) async {
    try {
      String? token = await PreferenceHelper.getToken();
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      dio.options.headers["Authorization"] = '$token';
      Response response = await dio.post("${baseUrl}patient-chat-notification", data: jsonEncode(body));
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      //progressDialog.hide();
      return BaseModel.fromJson(response.data);
    } on DioException catch (e) {
      if(e.response?.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const LoginScreen()));
      }
      //progressDialog.hide();
      if (e.response != null) {
        if (kDebugMode) {
          print(e.response?.data);
          print(e.response?.headers);
          print(e.response?.requestOptions);
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      BaseModel baseModel = BaseModel();
      return baseModel;
    }
  }

  Future<BaseModel> updateFCMToken(Map<String, String> body, BuildContext context) async {

    try {
      String? token = await PreferenceHelper.getToken();
      Dio dio = Dio();
      dio.interceptors.add(LoggingInterceptor());
      dio.options.headers["Authorization"] = '$token';
      Response response = await dio.post("${baseUrl}patients/fcm-update", data: jsonEncode(body));
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
      //progressDialog.hide();
      return BaseModel.fromJson(response.data);
    } on DioException catch (e) {
      //progressDialog.hide();
      if (e.response != null) {
        if (kDebugMode) {
          print(e.response?.data);
          print(e.response?.headers);
          print(e.response?.requestOptions);
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      BaseModel baseModel = BaseModel();
      return baseModel;
    }
  }

}
