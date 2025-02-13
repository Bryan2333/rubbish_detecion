import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/repository/api.dart';
import 'package:rubbish_detection/repository/data/user_bean.dart';
import 'package:rubbish_detection/utils/custom_helper.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key, required this.user});

  final UserBean user;

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  late ValueNotifier<bool> _isOldPasswordVisible;
  late ValueNotifier<bool> _isNewPasswordVisible;
  late ValueNotifier<bool> _isConfirmPasswordVisible;
  late ValueNotifier<String> _newPasswordNotifier;
  late ValueNotifier<bool> _showPasswordRequirements;

  late TextEditingController _verificationCodeController;

  late ValueNotifier<bool> _isCodeSentNotifier;
  late ValueNotifier<int> _countdownNotifier;

  late FocusNode _newPasswordFocusNode;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _isOldPasswordVisible = ValueNotifier(false);
    _isNewPasswordVisible = ValueNotifier(false);
    _isConfirmPasswordVisible = ValueNotifier(false);
    _newPasswordNotifier = ValueNotifier("");
    _showPasswordRequirements = ValueNotifier(false);

    _newPasswordFocusNode = FocusNode();
    _newPasswordFocusNode.addListener(() {
      _showPasswordRequirements.value = _newPasswordFocusNode.hasFocus;
    });

    _verificationCodeController = TextEditingController();
    _isCodeSentNotifier = ValueNotifier(false);
    _countdownNotifier = ValueNotifier(60);
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    _isOldPasswordVisible.dispose();
    _isNewPasswordVisible.dispose();
    _isConfirmPasswordVisible.dispose();
    _newPasswordNotifier.dispose();
    _showPasswordRequirements.dispose();

    _newPasswordFocusNode.dispose();

    _verificationCodeController.dispose();
    _isCodeSentNotifier.dispose();
    _countdownNotifier.dispose();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "修改密码",
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
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 40.h),
                  // 旧密码输入框
                  _buildOldPasswordField(),
                  SizedBox(height: 20.h),
                  // 验证码区域
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildVerificationCodeField()),
                      SizedBox(width: 16.w),
                      _buildSendCodeButton(),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // 新密码输入框
                  _buildNewPasswordField(),
                  SizedBox(height: 20.h),
                  // 确认密码输入框
                  _buildConfirmPasswordField(),
                  SizedBox(height: 40.h),
                  // 提交按钮
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOldPasswordField() {
    return ValueListenableBuilder(
      valueListenable: _isOldPasswordVisible,
      builder: (context, isVisible, child) {
        return _buildTextField(
          labelText: "旧密码",
          hintText: "请输入旧密码",
          prefixIcon: Icons.lock_outline,
          obscureText: !isVisible,
          controller: _oldPasswordController,
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility_off : Icons.visibility,
              size: 22.r,
              color: Colors.grey,
            ),
            onPressed: () {
              _isOldPasswordVisible.value = !_isOldPasswordVisible.value;
            },
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入旧密码';
            }

            return null;
          },
        );
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
                  backgroundColor: const Color(0xFF04C264),
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

  Widget _buildNewPasswordField() {
    bool hasValidLength(String password) {
      return password.length >= 6 && password.length <= 20;
    }

    bool isAlphaNumeric(String password) {
      return RegExp(r'^[0-9a-zA-Z]+$').hasMatch(password);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder(
          valueListenable: _isNewPasswordVisible,
          builder: (context, isVisible, child) {
            return _buildTextField(
              labelText: "新密码",
              hintText: "请输入新密码",
              prefixIcon: Icons.lock_outline,
              controller: _newPasswordController,
              obscureText: !isVisible,
              focusNode: _newPasswordFocusNode,
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility_off : Icons.visibility,
                  size: 22.r,
                  color: Colors.grey,
                ),
                onPressed: () {
                  _isNewPasswordVisible.value = !_isNewPasswordVisible.value;
                },
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入新密码';
                }

                if (hasValidLength(value) == false) {
                  return '密码长度需在6-20之间';
                }

                if (isAlphaNumeric(value) == false) {
                  return '密码只能由数字和字母构成';
                }

                return null;
              },
              onChanged: (value) {
                _newPasswordNotifier.value = value ?? "";
              },
            );
          },
        ),
        // 密码校验提示
        ValueListenableBuilder(
          valueListenable: _showPasswordRequirements,
          builder: (context, show, child) {
            return Visibility(
              visible: show,
              child: ValueListenableBuilder(
                valueListenable: _newPasswordNotifier,
                builder: (context, password, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      Text(
                        "• 长度 6 - 20",
                        style: TextStyle(
                          color: hasValidLength(password)
                              ? Colors.green
                              : Colors.red,
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        "• 仅使用数字与字母",
                        style: TextStyle(
                          color: isAlphaNumeric(password)
                              ? Colors.green
                              : Colors.red,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return ValueListenableBuilder(
      valueListenable: _isConfirmPasswordVisible,
      builder: (context, isVisible, child) {
        return _buildTextField(
          labelText: "确认密码",
          hintText: "请再次输入新密码",
          prefixIcon: Icons.lock_outline,
          controller: _confirmPasswordController,
          obscureText: !isVisible,
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility_off : Icons.visibility,
              size: 22.r,
              color: Colors.grey,
            ),
            onPressed: () {
              _isConfirmPasswordVisible.value =
                  !_isConfirmPasswordVisible.value;
            },
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请再次输入新密码';
            }

            if (value != _newPasswordController.text) {
              return '两次输入的密码不一致';
            }

            return null;
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
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF04C264),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: _handleChangePassword,
        child: Text(
          "确认修改",
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    FocusNode? focusNode,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
  }) {
    return TextFormField(
      focusNode: focusNode,
      obscureText: obscureText,
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(
          prefixIcon,
          color: const Color(0xFF04C264),
          size: 22.r,
        ),
        suffixIcon: suffixIcon,
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
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
      ),
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }

  void _getVerifyCode() async {
    await CustomHelper.executeAsyncCall(
      context: context,
      futureCall: Api.instance.getChangePasswordVerifyCode(widget.user.id!),
      successMessage: "验证码发送成功，请检查您的邮箱",
      failurePrefix: "获取验证码失败",
      onSuccess: (_) => _startCountdown(),
    );
  }

  void _handleChangePassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await CustomHelper.executeAsyncCall(
      context: context,
      futureCall: Api.instance.changePassword(
          widget.user.id!,
          _oldPasswordController.text.trim(),
          _newPasswordController.text.trim(),
          _confirmPasswordController.text.trim(),
          _verificationCodeController.text.trim()),
      successMessage: "修改密码成功",
      failurePrefix: "修改密码失败",
      onSuccess: (_) {
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _verificationCodeController.clear();
        _newPasswordNotifier.value = "";
        _showPasswordRequirements.value = false;
        _isCodeSentNotifier.value = false;
        _timer?.cancel();
      },
    );
  }
}
