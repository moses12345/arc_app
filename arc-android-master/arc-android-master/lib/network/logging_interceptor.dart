import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('REQUEST[${options.method}] => PATH: ${options.path}');
      print("Parameter ${options.queryParameters.isEmpty ? options.data : options.queryParameters}");
      print("Content type: ${options.contentType}");
      print("Headers: ${options.headers}");
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      //print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
      print('RESPONSE[${response.statusCode}] => DATA: ${response.data}');
    }
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print("<-- Error -->");
      print('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
      print(err.error);
      print(err.message);
    }
    return super.onError(err, handler);
  }
}
