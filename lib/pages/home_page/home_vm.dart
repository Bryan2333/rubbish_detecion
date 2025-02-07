import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rubbish_detection/http/dio_instance.dart';
import 'package:rubbish_detection/repository/data/banner_bean.dart';

class HomeViewModel with ChangeNotifier {
  final bannerList = <BannerBean>[];

  Future<void> getBannerData() async {
    try {
      final res = await DioInstance.instance.get("/api/banner/getBanner");

      if (res.data is List) {
        final bannerJsonList = res.data as List;

        final banners = bannerJsonList
            .map((json) => BannerBean.fromJson(json as Map<String, dynamic>))
            .toList();

        bannerList.clear();
        bannerList.addAll(banners);
      }
    } catch (e) {
      log("Fetch banner data error: $e");
    } finally {
      notifyListeners();
    }
  }
}
