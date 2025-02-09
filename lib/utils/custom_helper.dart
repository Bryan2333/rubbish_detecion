import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomHelper {
  static void showSnackBar(
    BuildContext context,
    message, {
    bool defaultStyle = false,
    bool success = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: defaultStyle
            ? null
            : (success ? const Color(0xFF00CE68) : Colors.red),
        content: Text(
          message,
          style: TextStyle(fontSize: 16.sp, color: Colors.white),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
