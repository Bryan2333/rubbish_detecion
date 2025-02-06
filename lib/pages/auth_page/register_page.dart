import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/http/dio_instance.dart';
import 'package:rubbish_detection/pages/auth_page/auth_vm.dart';
import 'package:rubbish_detection/pages/auth_page/login_page.dart';
import 'package:rubbish_detection/utils/image_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();

  final _authViewModel = AuthViewModel();

  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _ageController;
  late TextEditingController _emailController;
  late TextEditingController _signatureController;

  late FocusNode _passwordFocusNode;

  late ValueNotifier<String> _selectedGenderNotifier;
  late ValueNotifier<File?> _avatarImageNotifier;
  late ValueNotifier<String> _passwordNotifier;
  late ValueNotifier<bool> _isPasswordVisibleNotifier;
  late ValueNotifier<bool> _showPasswordRequirementsNotifier;

  late TextEditingController _codeController;
  late ValueNotifier<int> _countdownNotifier;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _selectedGenderNotifier = ValueNotifier("男");
    _avatarImageNotifier = ValueNotifier(null);
    _passwordNotifier = ValueNotifier("");
    _isPasswordVisibleNotifier = ValueNotifier(false);
    _showPasswordRequirementsNotifier = ValueNotifier(false);
    _countdownNotifier = ValueNotifier(60);

    _usernameController = TextEditingController();
    _ageController = TextEditingController();
    _emailController = TextEditingController();
    _signatureController = TextEditingController();
    _codeController = TextEditingController();

    _passwordController = TextEditingController()
      ..addListener(() => _passwordNotifier.value = _passwordController.text);

    _passwordFocusNode = FocusNode();
    _passwordFocusNode.addListener(() {
      _showPasswordRequirementsNotifier.value = _passwordFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _signatureController.dispose();

    _selectedGenderNotifier.dispose();
    _avatarImageNotifier.dispose();
    _passwordNotifier.dispose();
    _isPasswordVisibleNotifier.dispose();
    _showPasswordRequirementsNotifier.dispose();

    _passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                // 返回按钮
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, size: 20.r),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(height: 20.h),
                // 标题
                Text(
                  "创建账号",
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "请完善您的个人信息",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 32.h),
                // 头像选择
                _buildAvatarField(),
                SizedBox(height: 32.h),
                // 注册表单
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // 用户名输入框
                      _buildUsernameField(),
                      SizedBox(height: 16.h),
                      // 邮箱输入框
                      _buildEmailField(),
                      SizedBox(height: 16.h),
                      // 验证码输入区域
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildCodeField(),
                          SizedBox(width: 16.w),
                          _buildCodeButton(),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      // 密码输入框
                      _buildPasswordField(),
                      SizedBox(height: 16.h),
                      // 年龄输入框
                      _buildAgeField(),
                      SizedBox(height: 16.h),
                      // 个人简介输入框
                      _buildSignatureField(),
                      SizedBox(height: 16.h),
                      // 性别选择
                      _buildGenderField(),
                      SizedBox(height: 32.h),
                      // 注册按钮
                      _buildSubmitButton(),
                      SizedBox(height: 16.h),
                      // 登录提示
                      _buildLoginTips(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarField() {
    return Center(
      child: GestureDetector(
        onTap: () async {
          final imageSource = await ImageHelper.showPickerDialog(context);

          if (imageSource == null) {
            return;
          }

          final image = await ImageHelper.pickImage(
            source: imageSource,
            maxWidth: 512.r,
            maxHeight: 512.r,
          );

          if (image != null) {
            _avatarImageNotifier.value = image;
          }
        },
        child: Stack(
          children: [
            ValueListenableBuilder(
              valueListenable: _avatarImageNotifier,
              builder: (context, avatarImage, child) {
                return Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF04C264),
                      width: 2.r,
                    ),
                    image: avatarImage != null
                        ? DecorationImage(
                            image: FileImage(avatarImage),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: avatarImage == null
                      ? Icon(
                          Icons.add_a_photo,
                          size: 40.r,
                          color: const Color(0xFF04C264),
                        )
                      : null,
                );
              },
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                  color: Color(0xFF04C264),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  size: 16.r,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String labelText,
      required String hintText,
      required IconData prefixIcon,
      Key? key,
      TextInputType? keyboardType,
      TextEditingController? controller,
      FocusNode? focusNode,
      String? Function(String?)? validator,
      Widget? suffixIcon,
      void Function(String?)? onChanged,
      bool obscureText = false}) {
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
      onChanged: onChanged,
      validator: validator,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }

  Widget _buildUsernameField() {
    return _buildTextField(
      labelText: "用户名",
      hintText: "请输入用户名",
      prefixIcon: Icons.person_outline,
      keyboardType: TextInputType.name,
      controller: _usernameController,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入用户名';
        }

        if (value.length < 3 || value.length > 20) {
          return '用户名长度为3-20个字符';
        }

        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      key: _emailFieldKey,
      labelText: "邮箱",
      hintText: "请输入邮箱",
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      controller: _emailController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入邮箱';
        }
        // 添加邮箱格式验证
        if (EmailValidator.validate(value) == false) {
          return '请输入有效的邮箱地址';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
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
          valueListenable: _isPasswordVisibleNotifier,
          builder: (context, isVisible, child) {
            return _buildTextField(
              controller: _passwordController,
              labelText: "密码",
              hintText: "请输入密码",
              keyboardType: TextInputType.visiblePassword,
              prefixIcon: Icons.lock_outline,
              focusNode: _passwordFocusNode, // 绑定焦点节点
              obscureText: !isVisible,
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
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility_off : Icons.visibility,
                  size: 22.r,
                  color: Colors.grey,
                ),
                onPressed: () {
                  _isPasswordVisibleNotifier.value =
                      !_isPasswordVisibleNotifier.value;
                },
              ),
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: _showPasswordRequirementsNotifier,
          builder: (context, showRequirements, child) {
            return Visibility(
              visible: showRequirements,
              child: ValueListenableBuilder(
                valueListenable: _passwordNotifier,
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

  Widget _buildCodeField() {
    return Expanded(
      child: _buildTextField(
        labelText: "验证码",
        hintText: "请输入验证码",
        keyboardType: TextInputType.number,
        prefixIcon: Icons.numbers,
        controller: _codeController,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
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

  Widget _buildAgeField() {
    return _buildTextField(
      labelText: "年龄",
      hintText: "请输入年龄",
      prefixIcon: Icons.cake_outlined,
      keyboardType: TextInputType.number,
      controller: _ageController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入年龄';
        }

        final age = int.tryParse(value);
        if (age == null || age < 0 || age > 150) {
          return '请输入有效的年龄';
        }

        return null;
      },
    );
  }

  Widget _buildSignatureField() {
    return _buildTextField(
      labelText: "签名 (选填)",
      hintText: "请输入个人签名",
      prefixIcon: Icons.description_outlined,
      controller: _signatureController,
    );
  }

  Widget _buildGenderField() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "性别",
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _selectedGenderNotifier,
            builder: (context, selectedGender, child) {
              return Row(
                children: [
                  Radio(
                    value: '男',
                    groupValue: selectedGender,
                    activeColor: const Color(0xFF04C264),
                    onChanged: (value) {
                      if (value != null) {
                        _selectedGenderNotifier.value = value;
                      }
                    },
                  ),
                  const Text('男'),
                  const Spacer(),
                  Radio(
                    value: '女',
                    groupValue: selectedGender,
                    activeColor: const Color(0xFF04C264),
                    onChanged: (value) {
                      if (value != null) {
                        _selectedGenderNotifier.value = value;
                      }
                    },
                  ),
                  const Text('女'),
                  const Spacer(),
                  Radio(
                    value: '保密',
                    groupValue: selectedGender,
                    activeColor: const Color(0xFF04C264),
                    onChanged: (value) {
                      if (value != null) {
                        _selectedGenderNotifier.value = value;
                      }
                    },
                  ),
                  const Text('保密'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF04C264),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          "注册",
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "已有账号？",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const LoginPage();
                },
              ),
              (route) => route.isFirst,
            );
          },
          child: Text(
            "立即登录",
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF04C264),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
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
    if (_emailFieldKey.currentState?.validate() == false) {
      return;
    }

    try {
      final response = await DioInstance.instance.post(
        "/api/captcha/register",
        data: {"email": _emailController.text.trim()},
      );

      if (response.data["code"] == "0000") {
        _showSnackBar("验证码发送成功，请检查您的邮箱", success: true);
        _startCountdown();
      } else {
        _showSnackBar("获取验证码失败：${response.data["message"]}", success: false);
      }
    } catch (e) {
      _showSnackBar("网络异常，请稍后重试", success: false);
    }
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() == false) {
      return;
    }

    try {
      final res = await _authViewModel.register({
        "username": _usernameController.text.trim(),
        "password": _passwordController.text.trim(),
        "email": _emailController.text.trim(),
        "verifyCode": _codeController.text.trim(),
        "age": int.parse(_ageController.text),
        "signature": _signatureController.text.trim(),
        "gender": _selectedGenderNotifier.value.trim(),
        "avatar": _avatarImageNotifier.value != null
            ? base64Encode(_avatarImageNotifier.value!.readAsBytesSync())
            : null,
      });

      if (res["code"] == "0000") {
        _showSnackBar("注册成功");

        _usernameController.clear();
        _passwordController.clear();
        _emailController.clear();
        _codeController.clear();
        _ageController.clear();
        _signatureController.clear();

        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) {
                return const LoginPage();
              },
            ),
            (route) => route.isFirst,
          );
        }
      } else {
        _showSnackBar("注册失败：${res["message"]}", success: false);
      }
    } catch (e) {
      _showSnackBar("网络异常，请稍后重试", success: false);
    }
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
