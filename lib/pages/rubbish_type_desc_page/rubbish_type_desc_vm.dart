import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rubbish_detection/repository/api.dart';
import 'package:rubbish_detection/repository/data/rubbish_type_desc_bean.dart';

class RubbishTypeDescViewModel with ChangeNotifier {
  RubbishTypeDescBean? desc;

  Future<void> getDesc(int type) async {
    try {
      final response = await Api.instance.getRubbishTypeDesc(type);

      desc = response!.$3!;
    } catch (e) {
      log("Error fetching rubbish type description: $e");
    } finally {
      notifyListeners();
    }
  }
}
