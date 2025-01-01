import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rubbish_detection/repository/data/quiz.dart';

class QuizViewModel with ChangeNotifier {
  bool isLoading = true;
  final quizList = <Quiz>[];

  Future<void> getQuiz() async {
    isLoading = true;
    notifyListeners();

    final dio = Dio(BaseOptions(baseUrl: "http://10.133.73.147:1760"));

    try {
      quizList.clear();

      final res = await dio.get("/api/quiz/random");

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
