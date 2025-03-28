import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rubbish_detection/repository/api.dart';
import 'package:rubbish_detection/repository/data/quiz_bean.dart';

class QuizViewModel with ChangeNotifier {
  bool isLoading = true;
  final quizList = <QuizBean>[];

  Future<void> getQuiz() async {
    isLoading = true;
    notifyListeners();

    try {
      quizList.clear();

      final response = await Api.instance.getQuizList();

      quizList.addAll(response?.$3 ?? []);
    } catch (e) {
      log("Error fetching quiz: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
