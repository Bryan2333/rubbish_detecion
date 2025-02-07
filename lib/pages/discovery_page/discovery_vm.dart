import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rubbish_detection/http/dio_instance.dart';
import 'package:rubbish_detection/repository/data/news_bean.dart';

class DiscoveryViewModel with ChangeNotifier {
  final newsList = <NewsBean>[];
  var hasMore = true;
  var currentPage = 1;

  Future<void> getNews({required bool loadMore}) async {
    if (loadMore) {
      currentPage++;
    } else {
      currentPage = 1;
      newsList.clear();
      hasMore = true;
    }

    try {
      final res = await DioInstance.instance.get(
        "/api/news/page",
        params: {"pageNum": currentPage},
      );

      if (res.data is List) {
        final newsJsonList = res.data as List;

        if (newsJsonList.isNotEmpty) {
          final news = newsJsonList
              .map((json) => NewsBean.fromJson(json as Map<String, dynamic>))
              .toList();

          newsList.addAll(news);
        } else {
          hasMore = false;
        }
      }
    } catch (e) {
      log("Error fetching news: $e");
    } finally {
      notifyListeners();
    }
  }
}
