import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:email_validator/email_validator.dart';
import 'package:rubbish_detection/repository/api.dart';
import 'package:rubbish_detection/repository/data/user_bean.dart';
import 'package:rubbish_detection/utils/custom_helper.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key, required this.user});

  final UserBean user;

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

  void _getVerifyCode() async {
    if (!(_emailFieldKey.currentState?.validate() ?? false)) return;

    await CustomHelper.executeAsyncCall(
      context: context,
      futureCall: Api.instance.getChangeEmailVerifyCode(
          widget.user.id!, _newEmailController.text.trim()),
      successMessage: "验证码发送成功，请检查您的邮箱",
      failurePrefix: "获取验证码失败：",
      onSuccess: (_) => _startCountdown(),
    );
  }

  void _handleChangeEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await CustomHelper.executeAsyncCall(
      context: context,
      futureCall: Api.instance.changeEmail(
          widget.user.id!,
          _newEmailController.text.trim(),
          _verificationCodeController.text.trim()),
      successMessage: "修改邮箱成功",
      failurePrefix: "修改邮箱失败",
      onSuccess: (_) {
        _newEmailController.clear();
        _verificationCodeController.clear();
        _isCodeSentNotifier.value = false;
        _timer?.cancel();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "修改邮箱",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
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
        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF00CE68)),
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
            color: Color(0xFF00CE68),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      validator: (value) {
        final trimmed = value?.trim();
        if (trimmed == null || trimmed.isEmpty) {
          return '请输入邮箱地址';
        }

        if (EmailValidator.validate(trimmed) == false) {
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
        prefixIcon: const Icon(Icons.numbers, color: Color(0xFF00CE68)),
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
            color: Color(0xFF00CE68),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      validator: (value) {
        final trimmed = value?.trim();
        if (trimmed == null || trimmed.isEmpty) {
          return '请输入验证码';
        }

        if (RegExp(r'^\d{6}$').hasMatch(trimmed) == false) {
          return '验证码应为6位数字';
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
                onPressed: isSent ? null : _getVerifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00CE68),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  isSent ? "${countdown}s后重试" : "发送验证码",
                  style: TextStyle(fontSize: 15.sp, color: Colors.white),
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
          backgroundColor: const Color(0xFF00CE68),
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
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
