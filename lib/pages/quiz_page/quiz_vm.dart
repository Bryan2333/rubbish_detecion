import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rubbish_detection/repository/data/quiz.dart';

class QuizViewModel with ChangeNotifier {
  final quizList = <Quiz>[];

  Future<void> getQuiz() async {
    final dio = Dio(BaseOptions(baseUrl: "http://10.133.73.147:1760"));

    try {
      final res = await dio.get("/api/quiz/random");

      final model = QuizModel.fromJson(res.data);

      if (quizList.isNotEmpty) {
        quizList.clear();
      }

      quizList.addAll(model.data ?? []);
    } catch (e) {
      log("Error fetching quiz: $e");
    } finally {
      notifyListeners();
    }
  }
}
