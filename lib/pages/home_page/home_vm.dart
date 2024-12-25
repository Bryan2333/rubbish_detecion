import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rubbish_detection/repository/data/home_banner_data.dart';

class HomeViewModel with ChangeNotifier {
  final bannerList = <HomeBanner>[];

  Future<void> getBannerData() async {
    // final dio = Dio(BaseOptions(baseUrl: "https://pastebin.com"));

    // final res = await dio.get("/raw/hxnGnRsA");

    const res = '''
                {
                  "data": [
                    {
                      "id": 1,
                      "imagePath": "https://pic.imgdb.cn/item/67506c16d0e0a243d4dd92b7.png"
                    }
                  ],
                  "errorCode": 0,
                  "errorMsg": ""
                }
                ''';

    final resToString = json.decode(res);

    if (bannerList.isNotEmpty) {
      bannerList.clear();
    }

    final data = HomeBannerDataModel.fromJson(resToString);

    bannerList.addAll(data.data ?? []);

    notifyListeners();
  }
}
