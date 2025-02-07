import 'package:dio/dio.dart';
import 'package:rubbish_detection/http/base_model.dart';

class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestOptions = response.requestOptions;

    if (response.statusCode == 200) {
      try {
        final res = BaseModel.fromJson(response.data);

        handler.next(Response(
            requestOptions: requestOptions,
            data: res.data,
            statusMessage: res.message,
            statusCode: int.parse(res.code!)));
      } catch (e) {
        handler.reject(DioException(
            requestOptions: requestOptions, message: "解析数据失败: $e"));
      }
    } else {
      handler.reject(DioException(
        requestOptions: requestOptions,
        message: "请求失败: ${response.statusCode}",
      ));
    }
  }
}
