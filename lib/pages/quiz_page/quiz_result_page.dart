import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/route.dart';

class QuizResultPage extends StatefulWidget {
  const QuizResultPage({super.key});

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    _scoreAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getResultComment(double percentage) {
    if (percentage >= 1.0) return "完美！";
    if (percentage >= 0.8) return "真棒！";
    if (percentage >= 0.6) return "不错！";
    return "继续加油！";
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, int>;
    final correctAnswers = args["correctAnswers"] ?? 0;
    final totalQuestions = args["totalQuestions"] ?? 1;
    final percentage = correctAnswers / totalQuestions;

    return Scaffold(
      backgroundColor: const Color(0xFF00CE68),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00CE68),
        centerTitle: true,
        title: Text(
          "测验结果",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20.r,
                        spreadRadius: 5.r,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 结果图标
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00CE68).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            percentage >= 0.6
                                ? Icons.emoji_events_rounded
                                : Icons.stars_rounded,
                            size: 64.r,
                            color: const Color(0xFF00CE68),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // 结果评语
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          _getResultComment(percentage),
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00CE68),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // 分数展示
                      AnimatedBuilder(
                        animation: _scoreAnimation,
                        builder: (context, child) {
                          return Column(
                            children: [
                              Text(
                                "${(percentage * 100 * _scoreAnimation.value).toInt()}%",
                                style: TextStyle(
                                  fontSize: 48.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "答对 $correctAnswers / $totalQuestions 题",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 32.h),
                      // 进度条
                      AnimatedBuilder(
                        animation: _scoreAnimation,
                        builder: (context, child) {
                          return Container(
                            height: 8.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percentage * _scoreAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00CE68),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 32.h),
                      // 按钮区域
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildButton(
                                text: "返回发现",
                                isOutlined: true,
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: _buildButton(
                                text: "再测一次",
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    RoutePath.quizPage,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.white : const Color(0xFF00CE68),
            borderRadius: BorderRadius.circular(16.r),
            border: isOutlined
                ? Border.all(color: const Color(0xFF00CE68), width: 2)
                : null,
            boxShadow: isOutlined
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF00CE68).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isOutlined ? const Color(0xFF00CE68) : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
