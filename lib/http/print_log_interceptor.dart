import 'dart:developer';

import 'package:dio/dio.dart';

class PrintLogInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log("onRequest--------------------->");
    log("path: ${options.path}");
    log("data: ${options.data}");
    log("method: ${options.method}");
    options.headers.forEach((key, value) {
      log("请求头参数: key=$key, value=${value.toString()}");
    });
    log("<----------------------onRequest");

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log("onRepsonse------------------------>");
    log("path: ${response.realUri}");
    log("headers: ${response.headers}");
    log("statusCode: ${response.statusCode}");
    log("statusMessage: ${response.statusMessage}");
    log("data: ${response.data.toString()}");
    log("<--------------------------onRepsonse");
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log("onError------------------------->");
    log("$err");
    log("<-------------------------onError");
    super.onError(err, handler);
  }
}
