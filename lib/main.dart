import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/app.dart';
import 'package:rubbish_detection/http/dio_instance.dart';
import 'package:rubbish_detection/utils/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DioInstance.instance.initDio(baseUrl: "http://192.168.1.23:1760");
  await DbHelper.instance.initDb();
  await ScreenUtil.ensureScreenSize();
  runApp(const MyApp());
}
