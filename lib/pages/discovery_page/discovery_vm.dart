import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rubbish_detection/repository/data/news_article.dart';

class DiscoveryViewModel with ChangeNotifier {
  final newsList = <News>[];
  var hasMore = true;
  var currentPage = 1;

  Future<void> getNews({required bool loadMore}) async {
    final dio = Dio(BaseOptions(baseUrl: "http://10.133.73.147:1760"));

    if (loadMore) {
      currentPage++;
    } else {
      currentPage = 1;
      newsList.clear();
      hasMore = true;
    }

    try {
      final res = await dio.get(
        "/api/news/page",
        queryParameters: {"pageNum": currentPage},
      );

      final model = NewsArticleModel.fromJson(res.data);

      if (model.data?.list?.isEmpty == true) {
        hasMore = false;
      } else {
        newsList.addAll(model.data?.list ?? []);
      }

      notifyListeners();
    } catch (e) {
      log("Error fetching news: $e");
    }
  }
}
