import 'package:flutter/material.dart';
import 'package:rubbish_detection/constants.dart';
import 'package:rubbish_detection/repository/data/user.dart';
import 'package:rubbish_detection/utils/db_helper.dart';
import 'package:rubbish_detection/utils/sp_helper.dart';

class PersonalViewModel with ChangeNotifier {
  bool needLogin = true;
  User? user;

  Future<void> initData() async {
    final userId = await SpUtils.getInt(Constants.spUserId) ?? -1;
    needLogin = userId == -1;

    try {
      if (needLogin == false) {
        final userFromDB = await DbHelper.instance.getUser(userId);

        if (userFromDB?.avatar?.isEmpty == false) {
          userFromDB?.avatar = "http://192.168.1.23:1760${userFromDB.avatar!}";
        }

        user = userFromDB;
      }
    } finally {
      notifyListeners();
    }
  }
}
