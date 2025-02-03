import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:rubbish_detection/constants.dart';
import 'package:rubbish_detection/utils/sp_utils.dart';

class CookieInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // 取出本地存储的cookie
      final cookies = await SpUtils.getStringList(Constants.spCookieList);

      // 添加到请求头中
      options.headers[HttpHeaders.cookieHeader] = cookies;

      handler.next(options);
    } catch (e) {
      log("$e");
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.path.contains("/api/login")) {
      // 取出cookie信息
      final cookies = response.headers[HttpHeaders.setCookieHeader];

      final cookieToSave = <String>[];

      cookies?.forEach((cookie) {
        cookieToSave.add(cookie);
      });

      SpUtils.saveStringList(Constants.spCookieList, cookieToSave);
    }

    super.onResponse(response, handler);
  }
}
