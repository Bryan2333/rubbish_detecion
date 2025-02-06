import 'package:rubbish_detection/constants.dart';
import 'package:rubbish_detection/http/dio_instance.dart';
import 'package:rubbish_detection/repository/data/user.dart';
import 'package:rubbish_detection/utils/sp_utils.dart';

class AuthViewModel {
  Future<dynamic> register(Map<String, dynamic> payload) async {
    final response =
        await DioInstance.instance.post("/api/register", data: payload);

    return response.data;
  }

  Future<dynamic> login(Map<String, dynamic> payload) async {
    final response =
        await DioInstance.instance.post("/api/login", data: payload);

    if (response.data["code"] == "0000") {
      final model = UserDataModel.fromJson(response.data);

      await SpUtils.saveString(
          Constants.spUserId, model.data?.id.toString() ?? "-1");
    }

    return response.data;
  }

  Future<dynamic> resetPassword(Map<String, dynamic> payload) async {
    final response = await DioInstance.instance
        .post("/api/users/resetPassword", data: payload);

    return response.data;
  }
}
