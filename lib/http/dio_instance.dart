import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rubbish_detection/http/response_interceptor.dart';

/// 封装Dio
class DioInstance {
  static DioInstance? _instance;

  DioInstance._();

  static DioInstance get instance => _instance ??= DioInstance._();

  final _dio = Dio();
  final _defaultDuration = const Duration(seconds: 30);

  Future<void> initDio(
      {required String baseUrl,
      Duration? connectTimeout,
      Duration? receiveTimeout,
      Duration? sendTimeout,
      ResponseType? responseType = ResponseType.json,
      String? contentType}) async {
    _dio.options = BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout ?? _defaultDuration,
        receiveTimeout: receiveTimeout ?? _defaultDuration,
        sendTimeout: sendTimeout ?? _defaultDuration,
        responseType: responseType,
        contentType: contentType);

    await _initCookieManager();
    _dio.interceptors.add(LogInterceptor(
        requestBody: true, responseBody: true, requestHeader: true));
    _dio.interceptors.add(ResponseInterceptor());
  }

  Future<void> _initCookieManager() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;
    final jar = PersistCookieJar(storage: FileStorage("$appDocPath/.cookies/"));
    _dio.interceptors.add(CookieManager(jar));
  }

  void changeBaseURL({required String baseurl}) {
    _dio.options.baseUrl = baseurl;
  }

  String get baseURL => _dio.options.baseUrl;

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
