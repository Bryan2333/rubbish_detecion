import 'package:flutter/material.dart';
import 'package:rubbish_detection/common/constants.dart';
import 'package:rubbish_detection/repository/api.dart';
import 'package:rubbish_detection/utils/db_helper.dart';
import 'package:rubbish_detection/utils/sp_helper.dart';

class AuthViewModel with ChangeNotifier {
  Future<int> getUserId() async {
    return await SpUtils.getInt(Constants.spUserId) ?? -1;
  }

  Future<bool> isLogged() async {
    final userId = await SpUtils.getInt(Constants.spUserId);

    return userId != null && userId > 0;
  }

  Future<String?> login(
      {required String username,
      required password,
      required String role}) async {
    final (user, message) = await Api.instance.login(username, password, role);

    if (user != null) {
      await SpUtils.saveInt(Constants.spUserId, user.id ?? -1);

      await DbHelper.instance.insertUser(user);
    }

    return message;
  }

  Future<int?> logout() async {
    final statusCode = await Api.instance.logout();

    if (statusCode == 1000) {
      final userId = await SpUtils.getInt(Constants.spUserId) ?? -1;
      await DbHelper.instance.deleteUser(userId);
      await SpUtils.remove(Constants.spUserId);
    }

    return statusCode;
  }
}
