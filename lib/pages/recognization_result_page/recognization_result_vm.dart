import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:rubbish_detection/repository/data/rubbish_data.dart';

class RecognizationResultViewModel with ChangeNotifier {
  final rubbishList = <Rubbish>[];
  bool isLoading = false;

  Future<void> getRubbishList(String rubbishName) async {
    isLoading = true;
    notifyListeners();

    final dio = Dio(BaseOptions(baseUrl: "https://apis.tianapi.com"));

    try {
      final res = await dio.get(
        "/lajifenlei/index",
        queryParameters: {
          "key": "6d8b7a663e676ae8bdb637ee8c08cf29",
          "word": rubbishName
        },
      );

      final data = RubbishDataModel.fromJson(res.data);

      if (200 != data.code) {
        rubbishList.clear();
        return;
      }

      rubbishList.clear();
      rubbishList.addAll(data.result?.list ?? []);
    } catch (e) {
      log("Error fetching recognition result: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
