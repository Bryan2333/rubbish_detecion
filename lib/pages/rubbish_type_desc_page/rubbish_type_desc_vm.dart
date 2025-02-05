import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rubbish_detection/http/dio_instance.dart';
import 'package:rubbish_detection/repository/data/rubbish_type_desc.dart';

class RubbishTypeDescViewModel with ChangeNotifier {
  RubbishTypeDesc? desc;

  Future<void> getDesc(int type) async {
    try {
      final res = await DioInstance.instance.get("/api/rubbish-type/$type");

      final data = RubbishTypeDescModel.fromJson(res.data);

      desc = data.data;
    } catch (e) {
      log("Error fetching rubbish type description: $e");
    } finally {
      notifyListeners();
    }
  }
}
