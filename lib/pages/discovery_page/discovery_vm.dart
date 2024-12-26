import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rubbish_detection/repository/data/news_article.dart';

class DiscoveryViewModel with ChangeNotifier {
  final newsList = <News>[];

  Future<void> getNews() async {
    final dio = Dio(BaseOptions(baseUrl: "http://10.133.73.147:1760"));

    final res = await dio.get("/api/news/page");

    final model = NewsArticleModel.fromJson(res.data);

    if (newsList.isNotEmpty) {
      newsList.clear();
    }

    newsList.addAll(model.data?.list! ?? []);

    notifyListeners();
  }
}
