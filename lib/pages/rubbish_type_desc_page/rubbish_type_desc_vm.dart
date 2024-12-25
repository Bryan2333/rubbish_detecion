import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rubbish_detection/repository/data/rubbish_type_desc.dart';

class RubbishTypeDescViewModel with ChangeNotifier {
  RubbishTypeDesc? desc;

  Future<void> getDesc() async {
    final dio = Dio(BaseOptions(baseUrl: "https://pastebin.com"));
    final res = await dio.get("/raw/iaThjkkC");

    final data = RubbishTypeDescModel.fromJson(json.decode(res.data));

    desc = data.data;

    notifyListeners();
  }
}
