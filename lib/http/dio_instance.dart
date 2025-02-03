import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:rubbish_detection/http/cookie_interceptor.dart';
import 'package:rubbish_detection/http/print_log_interceptor.dart';

/// 封装Dio
class DioInstance {
  static DioInstance? _instance;

  DioInstance._();

  static DioInstance get instance => _instance ??= DioInstance._();

  final _dio = Dio();
  final _defaultDuration = const Duration(seconds: 30);

  void initDio(
      {required String baseUrl,
      Duration? connectTimeout,
      Duration? receiveTimeout,
      Duration? sendTimeout,
      ResponseType? responseType = ResponseType.json,
      String? contentType}) {
    log("initDio被调用");
    _dio.options = BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout ?? _defaultDuration,
        receiveTimeout: receiveTimeout ?? _defaultDuration,
        sendTimeout: sendTimeout ?? _defaultDuration,
        responseType: responseType,
        contentType: contentType);

    _dio.interceptors.add(CookieInterceptor()); // cookie拦截
    _dio.interceptors.add(PrintLogInterceptor()); // 打印请求信息
  }

  void changeBaseURL({required String baseurl}) {
    _dio.options.baseUrl = baseurl;
  }

  // 封装GET请求
  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    return await _dio.get(path, queryParameters: params);
  }

  // 封装POST请求
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post(path, queryParameters: queryParameters, data: data);
  }
}
