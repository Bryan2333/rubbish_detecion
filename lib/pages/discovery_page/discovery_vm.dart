import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rubbish_detection/repository/data/news_data.dart';

class DiscoveryViewModel with ChangeNotifier {
  final newsList = <News>[];

  Future<void> getNews() async {
    final dio = Dio(BaseOptions(baseUrl: "https://pastebin.com"));

    final res = await dio.get("/raw/SHFg151L");

    final model = NewsDataModel.fromJson(json.decode(res.data));

    if (newsList.isNotEmpty) {
      newsList.clear();
    }

    newsList.addAll(model.data ?? []);

    notifyListeners();
  }
}
