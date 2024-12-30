import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rubbish_detection/repository/data/rubbish_type_desc.dart';

class RubbishTypeDescViewModel with ChangeNotifier {
  RubbishTypeDesc? desc;

  Future<void> getDesc(int type) async {
    final dio = Dio(BaseOptions(baseUrl: "http://10.133.73.147:1760"));

    try {
      final res = await dio.get("/api/rubbish-type/$type");

      final data = RubbishTypeDescModel.fromJson(res.data);

      desc = data.data;
    } catch (e) {
      log("Error fetching rubbish type description: $e");
    } finally {
      notifyListeners();
    }
  }
}
