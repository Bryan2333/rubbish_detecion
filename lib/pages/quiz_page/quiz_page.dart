import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rubbish_detection/pages/quiz_page/quiz_result_page.dart';
import 'package:rubbish_detection/pages/quiz_page/quiz_vm.dart';
import 'package:rubbish_detection/repository/data/quiz_bean.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int correctAnswers = 0;
  final _quizViewModel = QuizViewModel();

  Timer? timer;

  late ValueNotifier<double> _progressNotifier;
  late ValueNotifier<QuizBean?> _currentQuestionNotifier;
  late ValueNotifier<int?> _selectedOptionIndexNotifier;
  late ValueNotifier<int> _currentQuestionIndexNotifier;

  @override
  void initState() {
    super.initState();
    _progressNotifier = ValueNotifier(0);
    _currentQuestionNotifier = ValueNotifier(null);
    _selectedOptionIndexNotifier = ValueNotifier(null);
    _currentQuestionIndexNotifier = ValueNotifier(0);

    _currentQuestionIndexNotifier.addListener(() {
      final currentIndex = _currentQuestionIndexNotifier.value;
      if (currentIndex < _quizViewModel.quizList.length) {
        _currentQuestionNotifier.value = _quizViewModel.quizList[currentIndex];
      }
    });

    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    await _quizViewModel.getQuiz();
    if (_quizViewModel.quizList.isNotEmpty) {
      _currentQuestionNotifier.value = _quizViewModel.quizList.first;
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _progressNotifier.dispose();
    _currentQuestionNotifier.dispose();
    _selectedOptionIndexNotifier.dispose();
    _currentQuestionIndexNotifier.dispose();
    super.dispose();
  }

  Color getOptionBackgroundColor(
      bool showResult, bool isCorrect, bool isSelected) {
    if (!showResult) return Colors.grey[100]!;
    if (isCorrect) return const Color(0xFF00CE68).withValues(alpha: 0.1);
    if (isSelected) return Colors.red[100]!;
    return Colors.grey[100]!;
  }

  Color getOptionBorderColor(bool showResult, bool isCorrect, bool isSelected) {
    if (!showResult) return Colors.transparent;
    if (isCorrect) return const Color(0xFF00CE68);
    if (isSelected) return Colors.red;
    return Colors.transparent;
  }

  void startCountdown() {
    const duration = Duration(milliseconds: 20);
    const totalTime = 2000.0;
    int elapsed = 0;

    timer?.cancel();
    timer = Timer.periodic(duration, (timer) {
      elapsed += duration.inMilliseconds;
      _progressNotifier.value = elapsed / totalTime;
      if (elapsed >= totalTime) {
        timer.cancel();
        nextQuestion();
      }
    });
  }

  void nextQuestion() {
    if (_currentQuestionIndexNotifier.value <
        _quizViewModel.quizList.length - 1) {
      _currentQuestionIndexNotifier.value++;
      _selectedOptionIndexNotifier.value = null;
      _progressNotifier.value = 0;
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) {
            return QuizResultPage(
              correctAnswers: correctAnswers,
              totalQuestions: _quizViewModel.quizList.length,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _quizViewModel,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: Consumer<QuizViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading == true) {
              return const Center(child: CircularProgressIndicator());
            } else if (vm.isLoading == false && vm.quizList.isEmpty) {
              return _buildLoadFailed();
            } else {
              return SafeArea(
                child: Column(
                  children: [_buildHeader(vm.quizList.length), _buildContent()],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        "垃圾分类测验",
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildLoadFailed() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60.r,
          ),
          SizedBox(height: 16.h),
          Text(
            "加载题目失败，请检查您的网络连接。",
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () async {
              await _loadQuizData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00CE68),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              "重试",
              style: TextStyle(fontSize: 16.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int quizLength) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "每日趣味三题",
                style: TextStyle(
                  fontSize: 26.sp,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "测试你的垃圾分类知识",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                ValueListenableBuilder(
                  valueListenable: _currentQuestionIndexNotifier,
                  builder: (context, currIdx, child) {
                    return Text(
                      "${currIdx + 1}/$quizLength",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    );
                  },
                ),
                SizedBox(width: 5.w),
                Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16.r),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20.r,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 题目编号
                    _buildQuestionNumber(),
                    // 题目内容
                    _buildQuestionContent(),
                    // 题目选项
                    _buildOptionList(),
                    // 倒计时进度条
                    _buildCountdownBar(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionNumber() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFF00CE68).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: ValueListenableBuilder(
        valueListenable: _currentQuestionIndexNotifier,
        builder: (context, currentIdx, child) {
          return Text(
            "问题 ${currentIdx + 1}",
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF00CE68),
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionContent() {
    return ValueListenableBuilder(
      valueListenable: _currentQuestionNotifier,
      builder: (context, currQuiz, child) {
        return Container(
          margin: EdgeInsets.only(bottom: 32.h),
          child: Text(
            currQuiz?.question ?? "",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionList() {
    return ValueListenableBuilder(
      valueListenable: _currentQuestionNotifier,
      builder: (context, currQuiz, child) {
        final options = [
          currQuiz?.optionA ?? "",
          currQuiz?.optionB ?? "",
          currQuiz?.optionC ?? "",
          currQuiz?.optionD ?? ""
        ];
        final correctAnswerIndex = currQuiz?.correctAnswerIndex ?? -1;
        return Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: options.length,
            itemBuilder: (context, index) {
              return _buildOption(
                option: MapEntry(index, options[index]),
                correctAnswerIndex: correctAnswerIndex,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required MapEntry<int, String> option,
    required int correctAnswerIndex,
  }) {
    return ValueListenableBuilder(
      valueListenable: _selectedOptionIndexNotifier,
      builder: (context, selectedIdx, child) {
        final optIdx = option.key;
        final optContent = option.value;
        final isSelected = optIdx == selectedIdx;
        final isCorrect = optIdx == correctAnswerIndex;
        final showResult = selectedIdx != null;

        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: getOptionBackgroundColor(showResult, isCorrect, isSelected),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: getOptionBorderColor(showResult, isCorrect, isSelected),
              width: 2.r,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: selectedIdx == null
                  ? () {
                      _selectedOptionIndexNotifier.value = optIdx;
                      if (optIdx == correctAnswerIndex) correctAnswers++;
                      startCountdown();
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
                      margin: EdgeInsets.only(right: 16.w),
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
                          String.fromCharCode(65 + optIdx), // A, B, C, D
                          style: TextStyle(
                            color: showResult
                                ? (isCorrect || isSelected
                                    ? Colors.white
                                    : Colors.black54)
                                : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        optContent,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: showResult && (isCorrect || isSelected)
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    Offstage(
                      offstage: !(showResult && (isCorrect || isSelected)),
                      child: Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? const Color(0xFF00CE68) : Colors.red,
                        size: 24.r,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountdownBar() {
    return ValueListenableBuilder(
      valueListenable: _selectedOptionIndexNotifier,
      builder: (context, selectedOptIdx, child) {
        return Offstage(
          offstage: selectedOptIdx == null,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 30.h),
            height: 8.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: ValueListenableBuilder(
                valueListenable: _progressNotifier,
                builder: (context, progress, child) {
                  return LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    color: const Color(0xFF00CE68),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
