import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomHelper {
  static Widget get progressIndicator =>
      const Center(child: CircularProgressIndicator(color: Color(0xFF00CE68)));

  static void showSnackBar(
    BuildContext context,
    String message, {
    bool defaultStyle = false,
    bool success = true,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: defaultStyle
            ? null
            : (success ? const Color(0xFF00CE68) : Colors.red),
        content: Text(
          message,
          style: TextStyle(fontSize: 16.sp, color: Colors.white),
        ),
        duration: duration,
      ),
    );
  }

  /// - [futureCall] 后端调用（返回 null 表示操作成功，否则返回错误消息）
  /// - [onSuccess] 操作成功后的回调
  /// - [successMessage] 成功时显示的信息
  /// - [failurePrefix] 错误前缀
  /// - [successCondition] 成功条件（默认为 null，即返回 null 为成功）
  static Future<void> executeAsyncCall<T>(
      {required BuildContext context,
      required Future<(int?, String?, T?)?> futureCall,
      void Function((int?, String?, T?)? result)? onSuccess,
      String successMessage = '',
      String failurePrefix = '',
      bool Function((int?, String?, T?)?)? successCondition}) async {
    try {
      final (int?, String?, T?)? result = await futureCall;
      if (!context.mounted) return;

      // 如果 successCondition 不为 null，则使用 successCondition 判断是否成功，否则，返回 null 为成功
      final bool isSuccess = successCondition != null
          ? successCondition(result)
          : result?.$1 == 1000;

      if (isSuccess) {
        showSnackBar(context, successMessage, success: true);
        onSuccess?.call(result);
      } else {
        // 如果后端返回具体的错误消息，则显示错误消息，否则，只显示 failurePrefix
        final errorMessage = result?.$2;
        showSnackBar(context,
            "$failurePrefix${errorMessage == null ? "" : ": $errorMessage"}",
            success: false);
      }
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, "网络异常，请稍后再试", success: false);
    }
  }
}
