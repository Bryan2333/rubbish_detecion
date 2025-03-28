import 'package:rubbish_detection/http/dio_instance.dart';
import 'package:rubbish_detection/repository/data/order_bean.dart';
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

  Future<(int?, String?, UserBean?)> login(
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

    return (
      response.statusCode,
      response.statusMessage,
      response.statusCode == 1000 ? UserBean.fromJson(response.data) : null
    );
  }

  Future<(int?, String?, Object?)> logout(String role) async {
    final response = await DioInstance.instance
        .post("/api/logout", queryParameters: {"role": role});

    return (response.statusCode, response.statusMessage, response.data);
  }

  Future<(int?, String?, Object?)> register(
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

    return (response.statusCode, response.statusMessage, response.data);
  }

  Future<(int?, String?, Object?)> resetPassword(
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

    return (response.statusCode, response.statusMessage, response.data);
  }

  Future<(int?, String?, Object?)> getRegisterVerifyCode(String email) async {
    final response = await DioInstance.instance
        .post("/api/captcha/register", data: {"email": email});

    return (response.statusCode, response.statusMessage, response.data);
  }

  Future<(int?, String?, Object?)> getResetPasswordVerifyCode(
      String username, String email) async {
    final response = await DioInstance.instance.post(
      "/api/captcha/resetPassword",
      data: {"username": username, "email": email},
    );

    return (response.statusCode, response.statusMessage, response.data);
  }

  Future<(int?, String?, Object?)> getChangeEmailVerifyCode(
      int userId, String newEmail) async {
    final response = await DioInstance.instance.post(
      "/api/captcha/changeEmail",
      data: {"userId": userId, "newEmail": newEmail},
    );

    return (response.statusCode, response.statusMessage, response.data);
  }

  Future<(int?, String?, Object?)> getChangePasswordVerifyCode(
      int userId) async {
    final response = await DioInstance.instance.post(
      "/api/captcha/changePassword",
      data: {"userId": userId},
    );

    return (response.statusCode, response.statusMessage, response.data);
  }

  Future<(int?, String?, Object?)> changeEmail(
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

    return (response.statusCode, response.statusMessage, response.data);
  }

  Future<(int?, String?, Object?)> changePassword(
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

    return (response.statusCode, response.statusMessage, response.data);
  }

  Future<(int?, String?, UserBean?)> changeUserInfo(
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

    return (
      response.statusCode,
      response.statusMessage,
      response.statusCode == 1000 ? UserBean.fromJson(response.data) : null
    );
  }

  Future<(int?, String?, List<QuizBean>?)?> getQuizList() async {
    final response = await DioInstance.instance.get("/api/quiz/random");

    if (response.data is! List) {
      return null;
    }

    final quizJsonList = response.data as List;

    final quizzes = quizJsonList
        .map((json) => QuizBean.fromJson(json as Map<String, dynamic>))
        .toList();

    return (response.statusCode, response.statusMessage, quizzes);
  }

  Future<(int?, String?, RubbishTypeDescBean?)?> getRubbishTypeDesc(
      int rubbishType) async {
    final response = await DioInstance.instance.get(
      "/api/rubbish-type/getDesc",
      params: {"type": rubbishType},
    );

    if (response.statusCode == 1000) {
      final desc = RubbishTypeDescBean.fromJson(response.data);

      desc.commonThings = desc.commonThings
          ?.map((item) => item["thing"])
          .toList()
          .cast<String>();

      desc.disposalAdvice = desc.disposalAdvice
          ?.map((item) => item["advice"])
          .toList()
          .cast<String>();

      desc.handleMethods = desc.handleMethods
          ?.map((item) => item["method"])
          .toList()
          .cast<String>();

      return (response.statusCode, response.statusMessage, desc);
    }

    return null;
  }

  Future<(int?, String?, Object?)> sendFeedback(
      String name, String email, String content) async {
    final response = await DioInstance.instance.post(
      "/api/feedback/add",
      data: {
        "name": name,
        "email": email,
        "content": content,
      },
    );

    return (response.statusCode, response.statusMessage, response.data);
  }

  Future<(int?, String?, Object?)> addCollection(
    int userId,
    String rubbishName,
    int rubbishType,
    String createdAt,
    String? image,
  ) async {
    final response = await DioInstance.instance.post(
      "/api/collection/add",
      data: {
        "userId": userId,
        "rubbishName": rubbishName,
        "rubbishType": rubbishType,
        "image": image,
        "createdAt": createdAt
      },
    );

    return (response.statusCode, response.statusMessage, response.data);
  }

  Future<(int?, String?, List<RecognitionCollectionBean>?)?>
      getCollectionByPage(
    int userId, [
    int pageNum = 1,
    int pageSize = 5,
  ]) async {
    final response = await DioInstance.instance.post(
      "/api/collection/findByPage",
      queryParameters: {
        "userId": userId,
        "pageNum": pageNum,
        "pageSize": pageSize,
      },
    );

    if (response.data is! List) {
      return null;
    }

    final collectionJsonList = response.data as List;
    final collections = collectionJsonList.map((json) {
      final collection =
          RecognitionCollectionBean.fromJson(json as Map<String, dynamic>);
      if (collection.image?.isNotEmpty ?? false) {
        collection.image = DioInstance.instance.baseURL + collection.image!;
      }
      return collection;
    }).toList();

    return (response.statusCode, response.statusMessage, collections);
  }

  Future<(int?, String?, Object?)> unCollectRecognition(
      int collectionId, int userId) async {
    final response = await DioInstance.instance.post(
      "/api/collection/unCollect",
      queryParameters: {
        "id": collectionId,
        "userId": userId,
      },
    );

    return (response.statusCode, response.statusMessage, response.data);
  }

  Future<(int?, String?, OrderBean?)> addOrder(OrderBean order) async {
    final response = await DioInstance.instance.post(
      "/api/order/add",
      data: order.toJson(),
    );

    return (
      response.statusCode,
      response.statusMessage,
      response.statusCode == 1000 ? OrderBean.fromJson(response.data) : null
    );
  }

  Future<(int?, String?, List<OrderBean>?)?> getRecentOrder(int userId) async {
    final response = await DioInstance.instance.get(
      "/api/order/getRecent?userId=$userId",
    );

    if (response.data is! List) {
      return null;
    }

    final orderJsonList = response.data as List;
    final orders = orderJsonList
        .map((json) => OrderBean.fromJson(json as Map<String, dynamic>))
        .toList();

    return (response.statusCode, response.statusMessage, orders);
  }

  Future<(int?, String?, List<OrderBean>?)?> getOrderByPage(
    int userId, {
    int? orderStatus,
    int pageNum = 1,
    int pageSize = 10,
  }) async {
    final response = await DioInstance.instance.get(
      "/api/order/findByPage",
      params: {
        "userId": userId,
        "pageNum": pageNum,
        "pageSize": pageSize,
        "orderStatus": orderStatus,
      },
    );

    if (response.data is! List) {
      return null;
    }

    final orderJsonList = response.data as List;
    final orders = orderJsonList
        .map((json) => OrderBean.fromJson(json as Map<String, dynamic>))
        .toList();

    return (response.statusCode, response.statusMessage, orders);
  }

  Future<(int?, String?, Object?)> cancelOrder(int userId, int orderId) async {
    final response = await DioInstance.instance.post(
      "/api/order/cancel",
      queryParameters: {"userId": userId, "orderId": orderId},
    );

    return (response.statusCode, response.statusMessage, response.data);
  }

  Future<(int?, String?, Object?)> submitOrderReview(
      {required int userId,
      required int orderId,
      required int reviewRate,
      required String reviewMessage}) async {
    final response = await DioInstance.instance.post(
      "/api/order/addReview",
      queryParameters: {
        "userId": userId,
        "orderId": orderId,
        "reviewRate": reviewRate,
        "reviewMessage": reviewMessage
      },
    );

    return (response.statusCode, response.statusMessage, response.data);
  }
}
