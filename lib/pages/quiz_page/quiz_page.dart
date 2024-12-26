import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rubbish_detection/pages/quiz_page/quiz_vm.dart';
import 'package:rubbish_detection/route.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage>
    with SingleTickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int? selectedOptionIndex;
  int correctAnswers = 0;
  double progress = 0;
  Timer? timer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late QuizViewModel _quizViewModel;

  @override
  void initState() {
    super.initState();
    _quizViewModel = QuizViewModel();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    await _quizViewModel.getQuiz();
  }

  @override
  void dispose() {
    timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void startCountdown() {
    const duration = Duration(milliseconds: 20); // 每 10ms 更新一次
    const totalTime = 2000.0; // 总时间 2 秒
    int elapsed = 0;

    timer?.cancel(); // 确保之前的计时器被清除
    timer = Timer.periodic(duration, (timer) {
      setState(() {
        elapsed += duration.inMilliseconds;
        progress = elapsed / totalTime; // 从 0 增加到 1
        if (elapsed >= totalTime) {
          timer.cancel();
          nextQuestion();
        }
      });
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < _quizViewModel.quizList.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOptionIndex = null;
        progress = 1.0; // 重置进度条
      });
    } else {
      // 如果是最后一题，跳转到结果页面
      Navigator.pushReplacementNamed(
        context,
        RoutePath.quizResultPage,
        arguments: {
          "correctAnswers": correctAnswers,
          "totalQuestions": _quizViewModel.quizList.length
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _quizViewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFF00CE68),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF00CE68),
          centerTitle: true,
          title: Text(
            "垃圾分类测验",
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 20.r, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<QuizViewModel>(
          builder: (context, vm, child) {
            if (vm.quizList.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final currentQuestion = vm.quizList[currentQuestionIndex];
            final question = currentQuestion.question ?? "";
            final options = [
              currentQuestion.optionA!,
              currentQuestion.optionB!,
              currentQuestion.optionC!,
              currentQuestion.optionD!
            ];
            final correctAnswerIndex = currentQuestion.correctAnswerIndex ?? 0;

            return SafeArea(
              child: Column(
                children: [
                  // 顶部信息区域
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "每日趣味三题",
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "测试你的垃圾分类知识",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "${currentQuestionIndex + 1}/${vm.quizList.length}",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16.r,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 主要内容区域
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20.r,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(24.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 题目序号
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00CE68)
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                      ),
                                      child: Text(
                                        "问题 ${currentQuestionIndex + 1}",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: const Color(0xFF00CE68),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    // 题目内容
                                    Text(
                                      question,
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 32.h),

                                    // 选项列表
                                    Expanded(
                                      child: ListView(
                                        children: _buildOptions(
                                          options: options,
                                          correctAnswerIndex:
                                              correctAnswerIndex,
                                        ),
                                      ),
                                    ),

                                    // 倒计时进度条
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: _buildCountdownBar(),
                                    ),
                                    SizedBox(height: 30.h)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCountdownBar() {
    return SizedBox(
      height: 8.h,
      child: selectedOptionIndex != null
          ? LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF00CE68),
              ),
            )
          : const SizedBox(),
    );
  }

  List<Widget> _buildOptions({
    required List<String> options,
    required int correctAnswerIndex,
  }) {
    return options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      final bool isSelected = selectedOptionIndex == index;
      final bool isCorrect = index == correctAnswerIndex;
      final bool showResult = selectedOptionIndex != null;

      Color getBackgroundColor() {
        if (!showResult) return Colors.grey[100]!;
        if (isCorrect) return const Color(0xFF00CE68).withOpacity(0.1);
        if (isSelected) return Colors.red[100]!;
        return Colors.grey[100]!;
      }

      Color getBorderColor() {
        if (!showResult) return Colors.transparent;
        if (isCorrect) return const Color(0xFF00CE68);
        if (isSelected) return Colors.red;
        return Colors.transparent;
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: getBackgroundColor(),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: getBorderColor(),
            width: 2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: selectedOptionIndex == null
                ? () {
                    setState(() {
                      selectedOptionIndex = index;
                      if (index == correctAnswerIndex) correctAnswers++;
                      startCountdown();
                    });
                  }
                : null,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: showResult
                          ? (isCorrect
                              ? const Color(0xFF00CE68)
                              : isSelected
                                  ? Colors.red
                                  : Colors.grey[300])
                          : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D...
                        style: TextStyle(
                          color: showResult
                              ? (isCorrect || isSelected
                                  ? Colors.white
                                  : Colors.black54)
                              : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black87,
                        fontWeight: showResult && (isCorrect || isSelected)
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (showResult && (isCorrect || isSelected))
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? const Color(0xFF00CE68) : Colors.red,
                      size: 24.r,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}
