import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rubbish_detection/http/dio_instance.dart';
import 'package:rubbish_detection/repository/data/rubbish_type_desc_bean.dart';

class RubbishTypeDescViewModel with ChangeNotifier {
  RubbishTypeDescBean? desc;

  Future<void> getDesc(int type) async {
    try {
      final res = await DioInstance.instance.get("/api/rubbish-type/$type");

      final data = RubbishTypeDescBean.fromJson(res.data);

      desc = data;
    } catch (e) {
      log("Error fetching rubbish type description: $e");
    } finally {
      notifyListeners();
    }
  }
}
