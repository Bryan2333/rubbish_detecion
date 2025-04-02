import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rubbish_detection/common/constants.dart';
import 'package:rubbish_detection/http/dio_instance.dart';
import 'package:rubbish_detection/repository/api.dart';
import 'package:rubbish_detection/repository/data/user_bean.dart';
import 'package:rubbish_detection/utils/db_helper.dart';
import 'package:rubbish_detection/utils/event_bus_helper.dart';
import 'package:rubbish_detection/utils/sp_helper.dart';
import 'package:rubbish_detection/utils/stomp_helper.dart';

class AuthViewModel with ChangeNotifier {
  Future<int> getUserId() async {
    return await SpUtils.getInt(Constants.spUserId) ?? -1;
  }

  Future<bool> isLogged() async {
    return (await getUserId()) > 0;
  }

  AuthViewModel() {
    isLogged().then((isLogged) {
      if (isLogged) {
        _initializeWebSocket();
      }
    });
  }

  Future<(int?, String?, UserBean?)> login(
      {required String username,
      required password,
      required String role}) async {
    final (statusCode, statusMsg, user) =
        await Api.instance.login(username, password, role);

    if (user != null) {
      await SpUtils.saveInt(Constants.spUserId, user.id ?? -1);

      await DbHelper.instance.insertUser(user);
      await _initializeWebSocket();
    }

    return (statusCode, statusMsg, user);
  }

  Future<(int?, String?, Object?)> logout(String role) async {
    final (statusCode, statusMsg, _) = await Api.instance.logout(role);

    if (statusCode == 1000) {
      final userId = await SpUtils.getInt(Constants.spUserId) ?? -1;
      await DbHelper.instance.deleteUser(userId);
      await SpUtils.remove(Constants.spUserId);

      StompHelper.dispose();
    }

    return (statusCode, statusMsg, null);
  }

  Future<void> _initializeWebSocket() async {
    await StompHelper.initStompClient(
      url: "${DioInstance.instance.baseURL}/ws",
    );

    Future.delayed(const Duration(seconds: 3)).then((_) {
      StompHelper.subscribe("/topic/user", (frame) {
        final message = frame.body;
        if (message != null) {
          final user = UserBean.fromJson(jsonDecode(message));

          DbHelper.instance.updateUser(user).then((_) {
            EventBusHelper.eventBus.fire(UserInfoUpdateEvent());
          });
        }
      });
    });
  }
}
