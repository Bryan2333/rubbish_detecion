import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rubbish_detection/http/dio_instance.dart';
import 'package:rubbish_detection/repository/data/quiz.dart';

class QuizViewModel with ChangeNotifier {
  bool isLoading = true;
  final quizList = <Quiz>[];

  Future<void> getQuiz() async {
    isLoading = true;
    notifyListeners();

    try {
      quizList.clear();

      final res = await DioInstance.instance.get("/api/quiz/random");

      final model = QuizModel.fromJson(res.data);

      quizList.addAll(model.data ?? []);
    } catch (e) {
      log("Error fetching quiz: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
