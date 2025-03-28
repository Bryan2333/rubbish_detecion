import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:rubbish_detection/repository/api.dart';
import 'package:rubbish_detection/repository/data/recognition_collection_bean.dart';

class CollectionViewModel with ChangeNotifier {
  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 1;
  final defaultPageSize = 10;

  final collections = <RecognitionCollectionBean>[];

  Future<void> getCollections(
      {required int userId, required bool loadMore}) async {
    isLoading = true;
    notifyListeners();

    try {
      if (loadMore) {
        currentPage++;
      } else {
        currentPage = 1;
        collections.clear();
        hasMore = true;
      }

      final result = await Api.instance
          .getCollectionByPage(userId, currentPage, defaultPageSize);

      collections.addAll(result?.$3 ?? []);
    } catch (e) {
      log("Error fetching collected records: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<(int?, String?, Object?)> unCollect(
      RecognitionCollectionBean collection) async {
    try {
      final result = await Api.instance
          .unCollectRecognition(collection.id!, collection.userId!);

      if (result.$1 == 1000) {
        collections.removeWhere((test) => test.id == collection.id);
      }

      return result;
    } finally {
      notifyListeners();
    }
  }
}
