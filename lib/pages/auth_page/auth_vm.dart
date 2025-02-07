import 'package:dio/dio.dart';
import 'package:rubbish_detection/constants.dart';
import 'package:rubbish_detection/http/dio_instance.dart';
import 'package:rubbish_detection/repository/data/user_bean.dart';
import 'package:rubbish_detection/utils/db_helper.dart';
import 'package:rubbish_detection/utils/sp_helper.dart';

class AuthViewModel {
  Future<Response> register(Map<String, dynamic> payload) async {
    final response =
        await DioInstance.instance.post("/api/register", data: payload);

    return response.data;
  }

  Future<Response> login(Map<String, dynamic> payload) async {
    final response =
        await DioInstance.instance.post("/api/login", data: payload);

    if (response.statusCode == 1000) {
      final user = UserBean.fromJson(response.data);

      await SpUtils.saveInt(Constants.spUserId, user.id ?? -1);

      await DbHelper.instance.insertUser(user);
    }

    return response.data;
  }

  Future<Response> resetPassword(Map<String, dynamic> payload) async {
    final response = await DioInstance.instance
        .post("/api/users/resetPassword", data: payload);

    return response.data;
  }
}
