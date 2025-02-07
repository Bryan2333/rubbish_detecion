import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rubbish_detection/http/dio_instance.dart';
import 'package:rubbish_detection/repository/data/quiz_bean.dart';

class QuizViewModel with ChangeNotifier {
  bool isLoading = true;
  final quizList = <QuizBean>[];

  Future<void> getQuiz() async {
    isLoading = true;
    notifyListeners();

    try {
      quizList.clear();

      final res = await DioInstance.instance.get("/api/quiz/random");

      if (res.data is List) {
        final quizJsonList = res.data as List<dynamic>;

        final quizzes = quizJsonList
            .map((json) => QuizBean.fromJson(json as Map<String, dynamic>))
            .toList();

        quizList.addAll(quizzes);
      }
    } catch (e) {
      log("Error fetching quiz: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
