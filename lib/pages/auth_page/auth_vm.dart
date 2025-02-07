import 'package:rubbish_detection/constants.dart';
import 'package:rubbish_detection/repository/api.dart';
import 'package:rubbish_detection/utils/db_helper.dart';
import 'package:rubbish_detection/utils/sp_helper.dart';

class AuthViewModel {
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
}
