import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/app.dart';
import 'package:rubbish_detection/http/dio_instance.dart';

void main() async {
  DioInstance.instance.initDio(baseUrl: "http://192.168.1.23:1760");
  await ScreenUtil.ensureScreenSize();
  runApp(const MyApp());
}
