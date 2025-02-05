import 'dart:async';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/http/dio_instance.dart';
import 'package:rubbish_detection/pages/auth_page/auth_vm.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameFieldKey = GlobalKey<FormFieldState>();
  final _emailFieldKey = GlobalKey<FormFieldState>();

  final _authViewModel = AuthViewModel();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _codeController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _newPasswordController;

  late ValueNotifier<String> _newPasswordNotifier;
  late ValueNotifier<bool> _isNewPasswordVisibleNotifier;
  late ValueNotifier<bool> _isConfirmPasswordVisibleNotifier;
  late ValueNotifier<bool> _showPasswordRequirementsNotifier;
  late ValueNotifier<int> _countdownNotifier;

  late FocusNode _newPasswordFocusNode;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _codeController = TextEditingController();
    _newPasswordController = TextEditingController()
      ..addListener(() {
        _newPasswordNotifier.value = _newPasswordController.text;
      });
    _confirmPasswordController = TextEditingController();

    _newPasswordNotifier = ValueNotifier("");
    _isNewPasswordVisibleNotifier = ValueNotifier(false);
    _isConfirmPasswordVisibleNotifier = ValueNotifier(false);
    _showPasswordRequirementsNotifier = ValueNotifier(false);
    _countdownNotifier = ValueNotifier(60);

    _newPasswordFocusNode = FocusNode();
    _newPasswordFocusNode.addListener(() {
      _showPasswordRequirementsNotifier.value = _newPasswordFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    _confirmPasswordController.dispose();

    _newPasswordNotifier.dispose();
    _isNewPasswordVisibleNotifier.dispose();
    _isConfirmPasswordVisibleNotifier.dispose();
    _showPasswordRequirementsNotifier.dispose();
    _countdownNotifier.dispose();

    _newPasswordFocusNode.dispose();

    _timer?.cancel();

    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    _countdownNotifier.value = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownNotifier.value > 0) {
        _countdownNotifier.value--;
      } else {
        timer.cancel();
        _countdownNotifier.value = 60;
      }
    });
  }

  void _getVerifyCode() async {
    final isUsernameValid = _usernameFieldKey.currentState?.validate() ?? false;
    final isEmailValid = _emailFieldKey.currentState?.validate() ?? false;

    if (!isUsernameValid || !isEmailValid) {
      return;
    }

    try {
      final response = await DioInstance.instance.post(
        "/api/captcha/resetPassword",
        data: {
          "username": _usernameController.text.trim(),
          "email": _emailController.text.trim(),
        },
      );

      if (response.data["code"] == "0000") {
        _showSnackBar("验证码发送成功，请注意查收", success: true);
        _startCountdown();
      } else {
        _showSnackBar("获取验证码失败：${response.data["message"]}", success: false);
      }
    } catch (e) {
      _showSnackBar("网络异常，请稍后重试", success: false);
    }
  }

  void _handleResetPassword() async {
    if (_formKey.currentState?.validate() == false) {
      return;
    }

    try {
      final response = await _authViewModel.resetPassword({
        "username": _usernameController.text.trim(),
        "email": _emailController.text.trim(),
        "newPassword": _newPasswordNotifier.value.trim(),
        "confirmPassword": _confirmPasswordController.text.trim(),
        "verifyCode": _codeController.text.trim(),
      });

      if (response["code"] == "0000") {
        _showSnackBar("密码重置成功", success: true);
        _usernameController.clear();
        _emailController.clear();
        _codeController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _showSnackBar("密码重置失败：${response["message"]}", success: false);
      }
    } catch (e) {
      _showSnackBar("网络异常，请稍后重试", success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),
                  // 返回按钮
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, size: 20.r),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(height: 20.h),
                  // 页面标题
                  Text(
                    "找回密码",
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "请填写您的用户名和注册邮箱以重置密码",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 40.h),
                  // 用户名输入框
                  _buildUsernameField(),
                  SizedBox(height: 20.h),
                  // 邮箱输入框
                  _buildEmailField(),
                  SizedBox(height: 20.h),
                  // 验证码输入区域
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildCodeField(),
                      SizedBox(width: 16.w),
                      _buildCodeButton(),
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

  Widget _buildTextField({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    TextEditingController? controller,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    void Function(String?)? onChanged,
    bool obscureText = false,
    FocusNode? focusNode,
    Key? key,
  }) {
    return TextFormField(
      key: key,
      focusNode: focusNode,
      obscureText: obscureText,
      controller: controller,
      keyboardType: keyboardType,
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
          borderSide: BorderSide(color: Colors.grey[300]!),
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
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildUsernameField() {
    return _buildTextField(
      key: _usernameFieldKey,
      labelText: "用户名",
      hintText: "请输入用户名",
      keyboardType: TextInputType.name,
      prefixIcon: Icons.person_outline,
      controller: _usernameController,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入用户名';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      key: _emailFieldKey,
      labelText: "邮箱",
      hintText: "请输入注册邮箱",
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
      controller: _emailController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入邮箱';
        }
        if (EmailValidator.validate(value) == false) {
          return '请输入有效的邮箱地址';
        }
        return null;
      },
    );
  }

  Widget _buildCodeField() {
    return Expanded(
      child: _buildTextField(
        labelText: "验证码",
        hintText: "请输入验证码",
        keyboardType: TextInputType.number,
        prefixIcon: Icons.numbers,
        controller: _codeController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '请输入验证码';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCodeButton() {
    return SizedBox(
      width: 120.w,
      height: 56.h,
      child: ValueListenableBuilder(
        valueListenable: _countdownNotifier,
        builder: (context, countdown, child) {
          return ElevatedButton(
            onPressed: countdown == 60 ? _getVerifyCode : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF04C264),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
              padding: EdgeInsets.zero,
            ),
            child: Text(
              countdown == 60 ? "获取验证码" : "${countdown}s",
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
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
          valueListenable: _isNewPasswordVisibleNotifier,
          builder: (context, isVisible, child) {
            return _buildTextField(
              controller: _newPasswordController,
              labelText: "新密码",
              hintText: "请输入新密码",
              keyboardType: TextInputType.visiblePassword,
              prefixIcon: Icons.lock_outline,
              focusNode: _newPasswordFocusNode,
              obscureText: !isVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isNewPasswordVisibleNotifier.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  size: 22.r,
                  color: Colors.grey,
                ),
                onPressed: () {
                  _isNewPasswordVisibleNotifier.value =
                      !_isNewPasswordVisibleNotifier.value;
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入密码';
                }
                if (hasValidLength(value) == false) {
                  return '密码长度为6-20个字符';
                }
                if (isAlphaNumeric(value) == false) {
                  return '密码只能由数字和字母构成';
                }
                return null;
              },
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: _showPasswordRequirementsNotifier,
          builder: (context, showRequirements, child) {
            return Visibility(
              visible: showRequirements,
              child: ValueListenableBuilder(
                valueListenable: _newPasswordNotifier,
                builder: (context, currentPassword, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      Text(
                        "• 长度 6 - 20",
                        style: TextStyle(
                          color: hasValidLength(currentPassword)
                              ? Colors.green
                              : Colors.red,
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        "• 仅使用数字与字母",
                        style: TextStyle(
                          color: isAlphaNumeric(currentPassword)
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
      valueListenable: _isConfirmPasswordVisibleNotifier,
      builder: (context, isVisible, child) {
        return _buildTextField(
          obscureText: !isVisible,
          labelText: "确认密码",
          hintText: "请再次输入新密码",
          keyboardType: TextInputType.visiblePassword,
          prefixIcon: Icons.lock_outline,
          controller: _confirmPasswordController,
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility_off : Icons.visibility,
              size: 22.r,
              color: Colors.grey,
            ),
            onPressed: () {
              _isConfirmPasswordVisibleNotifier.value =
                  !_isConfirmPasswordVisibleNotifier.value;
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请再次输入新密码';
            }
            if (value != _newPasswordNotifier.value) {
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
        onPressed: _handleResetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF04C264),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Text(
          "重置密码",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool success = true}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: success ? const Color(0xFF00CE68) : Colors.red,
          content: Text(
            message,
            style: TextStyle(fontSize: 16.sp, color: Colors.white),
          ),
          duration: Duration(seconds: success ? 2 : 5),
        ),
      );
    }
  }
}
