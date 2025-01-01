import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:rubbish_detection/pages/collection_page/collection_page.dart';

class CollectionViewModel with ChangeNotifier {
  bool isLoading = false;
  final List<RecognitionCollection> _mockData = [
    RecognitionCollection(
      id: 1,
      rubbishName: '塑料瓶',
      rubbishType: 2,
      createdTime: DateTime.now(),
      imagePath: null,
      isDeleted: true,
    ),
    RecognitionCollection(
      id: 2,
      rubbishName: '玻璃',
      rubbishType: 0,
      createdTime: DateTime.now(),
      imagePath: null,
      isDeleted: true,
    ),
    RecognitionCollection(
      id: 3,
      rubbishName: '凉鞋',
      rubbishType: 0,
      createdTime: DateTime.now(),
      imagePath: null,
      isDeleted: true,
    ),
    RecognitionCollection(
      id: 4,
      rubbishName: '蓄电池',
      rubbishType: 3,
      createdTime: DateTime.now(),
      imagePath: null,
      isDeleted: true,
    ),
    RecognitionCollection(
      id: 5,
      rubbishName: '苹果皮',
      rubbishType: 1,
      createdTime: DateTime.now(),
      imagePath: null,
      isDeleted: true,
    ),
  ];

  final collections = <RecognitionCollection>[];

  Future<void> getCollections() async {
    try {
      isLoading = true;
      // Simulate network request
      await Future.delayed(const Duration(milliseconds: 200));
      collections.addAll(_mockData);
    } catch (e) {
      log("Error fetching collected records: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> unCollect(RecognitionCollection collection) async {
    try {
      // Simulate network request
      await Future.delayed(const Duration(milliseconds: 200));
      return collections.remove(collection);
    } catch (e) {
      log("Error uncollecting record: $e");
      return false;
    } finally {
      notifyListeners();
    }
  }
}
