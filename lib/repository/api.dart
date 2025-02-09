import 'package:rubbish_detection/http/dio_instance.dart';
import 'package:rubbish_detection/repository/data/banner_bean.dart';
import 'package:rubbish_detection/repository/data/quiz_bean.dart';
import 'package:rubbish_detection/repository/data/recognition_collection_bean.dart';
import 'package:rubbish_detection/repository/data/rubbish_type_desc_bean.dart';
import 'package:rubbish_detection/repository/data/user_bean.dart';

class Api {
  static Api? _instance;

  Api._internal();

  static Api get instance {
    _instance ??= Api._internal();
    return _instance!;
  }

  Future<(UserBean?, String?)> login(
    String username,
    String password,
    String role,
  ) async {
    final response = await DioInstance.instance.post(
      "/api/login",
      data: {
        "username": username,
        "password": password,
        "role": role,
      },
    );

    if (response.statusCode == 1000) {
      final user = UserBean.fromJson(response.data);

      return (user, null);
    }

    return (null, response.statusMessage);
  }

  Future<int?> logout() async {
    final response = await DioInstance.instance.post("/api/logout");

    return response.statusCode;
  }

  Future<String?> register(
    String username,
    String password,
    String email,
    String verifyCode,
    int age,
    String gender, [
    String? signature,
    String? avatar,
  ]) async {
    final response = await DioInstance.instance.post(
      "/api/register",
      data: {
        "username": username,
        "password": password,
        "email": email,
        "verifyCode": verifyCode,
        "age": age,
        "gender": gender,
        "signature": signature,
        "avatar": avatar,
      },
    );

    return response.statusCode == 1000 ? null : response.statusMessage;
  }

  Future<String?> resetPassword(
    String username,
    String email,
    String newPassword,
    String confirmPassword,
    String verifyCode,
  ) async {
    final response = await DioInstance.instance.post(
      "/api/users/resetPassword",
      data: {
        "username": username,
        "email": email,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
        "verifyCode": verifyCode,
      },
    );

    return response.statusCode == 1000 ? null : response.statusMessage;
  }

  Future<String?> getRegisterVerifyCode(String email) async {
    final response = await DioInstance.instance
        .post("/api/captcha/register", data: {"email": email});

    return response.statusCode == 1000 ? null : response.statusMessage;
  }

  Future<String?> getResetPasswordVerifyCode(
      String username, String email) async {
    final response = await DioInstance.instance.post(
      "/api/captcha/resetPassword",
      data: {"username": username, "email": email},
    );

    return response.statusCode == 1000 ? null : response.statusMessage;
  }

  Future<String?> getChangeEmailVerifyCode(int userId, String newEmail) async {
    final response = await DioInstance.instance.post(
      "/api/captcha/changeEmail",
      data: {"userId": userId, "newEmail": newEmail},
    );

    return response.statusCode == 1000 ? null : response.statusMessage;
  }

  Future<String?> getChangePasswordVerifyCode(int userId) async {
    final response = await DioInstance.instance.post(
      "/api/captcha/changePassword",
      data: {"userId": userId},
    );

    return response.statusCode == 1000 ? null : response.statusMessage;
  }

  Future<String?> changeEmail(
    int userId,
    String newEmail,
    String verifyCode,
  ) async {
    final response = await DioInstance.instance.post(
      "/api/users/changeEmail",
      data: {
        "userId": userId,
        "newEmail": newEmail,
        "verifyCode": verifyCode,
      },
    );

    return response.statusCode == 1000 ? null : response.statusMessage;
  }

  Future<String?> changePassword(
    int userId,
    String oldPassword,
    String newPassword,
    String confirmPassword,
    String verifyCode,
  ) async {
    final response = await DioInstance.instance.post(
      "/api/users/changePassword",
      data: {
        "userId": userId,
        "oldPassword": oldPassword,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
        "verifyCode": verifyCode,
      },
    );

    return response.statusCode == 1000 ? null : response.statusMessage;
  }

  Future<(UserBean?, String?)> changeUserInfo(
    int userId,
    String username,
    int age,
    String gender,
    String? signature,
    String? avatar,
  ) async {
    final response = await DioInstance.instance.post(
      "/api/users/updateInfo",
      data: {
        "id": userId,
        "username": username,
        "age": age,
        "gender": gender,
        "signature": signature,
        "avatar": avatar,
      },
    );

    if (response.statusCode == 1000) {
      final user = UserBean.fromJson(response.data);

      return (user, null);
    }

    return (null, response.statusMessage);
  }

  Future<List<BannerBean>?> getBannerList() async {
    final response = await DioInstance.instance.get("/api/banner/getBanner");

    if (response.data is! List) {
      return null;
    }

    final bannerJsonList = response.data as List;

    final banners = bannerJsonList
        .map((json) => BannerBean.fromJson(json as Map<String, dynamic>))
        .toList();

    return banners;
  }

  Future<List<QuizBean>?> getQuizList() async {
    final response = await DioInstance.instance.get("/api/quiz/random");

    if (response.data is! List) {
      return null;
    }

    final quizJsonList = response.data as List;

    final quizzes = quizJsonList
        .map((json) => QuizBean.fromJson(json as Map<String, dynamic>))
        .toList();

    return quizzes;
  }

  Future<RubbishTypeDescBean?> getRubbishTypeDesc(int rubbishType) async {
    final response = await DioInstance.instance.get(
      "/api/rubbish-type/getDesc",
      params: {"type": rubbishType},
    );

    if (response.statusCode == 1000) {
      return RubbishTypeDescBean.fromJson(response.data);
    }

    return null;
  }

  Future<int?> sendFeedback(String name, String email, String content) async {
    final response = await DioInstance.instance.post(
      "/api/feedback/add",
      data: {
        "name": name,
        "email": email,
        "content": content,
      },
    );

    return response.statusCode;
  }
}
