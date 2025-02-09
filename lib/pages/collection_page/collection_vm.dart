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

      final list = await Api.instance
          .getCollectionByPage(userId, currentPage, defaultPageSize);

      collections.addAll(list ?? []);
    } catch (e) {
      log("Error fetching collected records: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> unCollect(RecognitionCollectionBean collection) async {
    try {
      final statusCode = await Api.instance
          .unCollectRecognition(collection.id!, collection.userId!);

      if (statusCode == 1000) {
        collections.removeWhere((test) => test.id == collection.id);
        return true;
      }

      return false;
    } finally {
      notifyListeners();
    }
  }
}
