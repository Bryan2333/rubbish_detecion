import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';

class LoadingPage {
  LoadingPage._();

  static Future<void> showLoading(
      {Duration duration = const Duration(days: 1)}) async {
    showToastWidget(
      Container(
        color: Colors.transparent,
        constraints: const BoxConstraints.expand(),
        child: Align(
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Colors.black54,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 2.r,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              
            ),
          ),
        ),
      ),
      duration: duration, // 持续时间
      handleTouch: true, // 手动结束
    );
  }

  static void hideLoading() {
    dismissAllToast();
  }
}
