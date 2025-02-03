import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rubbish_detection/http/dio_instance.dart';
import 'package:rubbish_detection/repository/data/news_article.dart';

class DiscoveryViewModel with ChangeNotifier {
  final newsList = <News>[];
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

      final model = NewsArticleModel.fromJson(res.data);

      if (model.data?.isEmpty == true) {
        hasMore = false;
      } else {
        newsList.addAll(model.data ?? []);
      }
    } catch (e) {
      log("Error fetching news: $e");
    } finally {
      notifyListeners();
    }
  }
}
