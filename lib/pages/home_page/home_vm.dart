import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rubbish_detection/repository/api.dart';
import 'package:rubbish_detection/repository/data/banner_bean.dart';

class HomeViewModel with ChangeNotifier {
  final bannerList = <BannerBean>[];

  Future<void> getBannerData() async {
    try {
      final list = await Api.instance.getBannerList();

      if (bannerList.isNotEmpty) {
        bannerList.clear();
      }

      bannerList.addAll(list ?? []);
    } catch (e) {
      log("Fetch banner data error: $e");
    } finally {
      notifyListeners();
    }
  }
}
