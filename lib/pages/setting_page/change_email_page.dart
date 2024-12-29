import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:email_validator/email_validator.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailFieldKey = GlobalKey<FormFieldState>();

  late TextEditingController _newEmailController;
  late TextEditingController _verificationCodeController;

  late ValueNotifier<bool> _isCodeSentNotifier;
  late ValueNotifier<int> _countdownNotifier;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _newEmailController = TextEditingController();
    _verificationCodeController = TextEditingController();

    _isCodeSentNotifier = ValueNotifier(false);
    _countdownNotifier = ValueNotifier(60);
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    _verificationCodeController.dispose();

    _isCodeSentNotifier.dispose();
    _countdownNotifier.dispose();

    _timer?.cancel();

    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    _countdownNotifier.value = 60;
    _isCodeSentNotifier.value = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownNotifier.value > 0) {
        _countdownNotifier.value--;
      } else {
        timer.cancel();
        _isCodeSentNotifier.value = false;
        _countdownNotifier.value = 60;
      }
    });
  }

  void _sendVerificationCode() {
    if (_emailFieldKey.currentState?.validate() == true) {
      String newEmail = _newEmailController.text.trim();
      // TODO: 调用后端接口发送验证码到新的邮箱
      log("发送验证码到邮箱: $newEmail");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("验证码已发送，请检查您的邮箱")),
      );
      _startCountdown();
    }
  }

  bool _verifyCode(String email, String code) {
    // TODO: 调用后端接口验证验证码和新的邮箱地址
    return true;
  }

  void _handleChangeEmail() {
    if (_formKey.currentState?.validate() == true) {
      String newEmail = _newEmailController.text.trim();
      String code = _verificationCodeController.text.trim();

      // 验证验证码和新的邮箱地址
      if (_verifyCode(newEmail, code)) {
        // TODO: 在这里调用后端接口更新用户的邮箱
        log("邮箱已成功修改为: $newEmail");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "邮箱修改成功",
              style: TextStyle(fontSize: 16.sp),
            ),
            backgroundColor: const Color(0xFF04C264),
          ),
        );
        // 清空输入框
        _newEmailController.clear();
        _verificationCodeController.clear();
        // 重置倒计时
        _timer?.cancel();
        _isCodeSentNotifier.value = false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "验证码错误或邮箱验证失败，请重试",
              style: TextStyle(fontSize: 16.sp),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "修改邮箱",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 40.h),
                // 新邮箱输入框
                _buildNewEmailField(),
                SizedBox(height: 20.h),
                // 验证码输入区域
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildVerificationCodeField()),
                    SizedBox(width: 16.w),
                    _buildSendCodeButton(),
                  ],
                ),
                SizedBox(height: 40.h),
                // 提交按钮
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewEmailField() {
    return TextFormField(
      key: _emailFieldKey,
      controller: _newEmailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: "新邮箱",
        hintText: "请输入新的邮箱地址",
        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF04C264)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: Color(0xFF04C264),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入邮箱地址';
        }

        if (EmailValidator.validate(value.trim()) == false) {
          return '请输入有效的邮箱地址';
        }

        return null;
      },
    );
  }

  Widget _buildVerificationCodeField() {
    return TextFormField(
      controller: _verificationCodeController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "验证码",
        hintText: "请输入验证码",
        prefixIcon: const Icon(Icons.numbers, color: Color(0xFF04C264)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: Color(0xFF04C264),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入验证码';
        }

        if (value.trim().length != 6) {
          return '验证码应为6位数字';
        }

        if (RegExp(r'^\d{6}$').hasMatch(value.trim()) == false) {
          return '验证码应为数字';
        }

        return null;
      },
    );
  }

  Widget _buildSendCodeButton() {
    return ValueListenableBuilder(
      valueListenable: _isCodeSentNotifier,
      builder: (context, isSent, child) {
        return ValueListenableBuilder(
          valueListenable: _countdownNotifier,
          builder: (context, countdown, child) {
            return SizedBox(
              width: 120.w,
              height: 55.h,
              child: ElevatedButton(
                onPressed: isSent ? null : _sendVerificationCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF04C264),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  isSent ? "${countdown}s后重试" : "发送验证码",
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _handleChangeEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF04C264),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Text(
          "确认修改",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
