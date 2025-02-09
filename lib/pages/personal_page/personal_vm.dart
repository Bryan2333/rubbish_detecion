import 'package:flutter/material.dart';
import 'package:rubbish_detection/repository/data/user_bean.dart';
import 'package:rubbish_detection/utils/db_helper.dart';

class PersonalViewModel with ChangeNotifier {
  UserBean? user;

  Future<void> initData(int userId) async {
    try {
      final userFromDB = await DbHelper.instance.getUser(userId);

      if (userFromDB?.avatar?.isEmpty == false) {
        userFromDB?.avatar = "http://192.168.1.23:1760${userFromDB.avatar!}";
      }

      user = userFromDB;
    } finally {
      notifyListeners();
    }
  }
}
