import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rubbish_detection/repository/data/rubbish_data.dart';
import 'package:rubbish_detection/widget/loading_page.dart';

class RecognizationResultViewModel with ChangeNotifier {
  final rubbishList = <Rubbish>[];

  Future<void> getRubbishList(String rubbishName) async {
    final dio = Dio(BaseOptions(baseUrl: "https://apis.tianapi.com"));

    final res = await dio.get(
        "/lajifenlei/index?key=6d8b7a663e676ae8bdb637ee8c08cf29&word=$rubbishName");

    final data = RubbishDataModel.fromJson(res.data);

    if (200 != data.code) {
      LoadingPage.hideLoading();
      rubbishList.clear();
      showToast("识别失败");
      return;
    }

    if (rubbishList.isNotEmpty) {
      rubbishList.clear();
    }

    rubbishList.addAll(data.result?.list ?? []);

    notifyListeners();
  }
}
