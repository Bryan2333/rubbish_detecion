import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rubbish_detection/pages/auth_page/auth_vm.dart';
import 'package:rubbish_detection/pages/auth_page/forgot_password_page.dart';
import 'package:rubbish_detection/pages/auth_page/register_page.dart';
import 'package:rubbish_detection/pages/tab_page/tab_page.dart';
import 'package:rubbish_detection/utils/custom_helper.dart';
import 'package:rubbish_detection/utils/route_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  late ValueNotifier<bool> _isPasswordVisibleNotifier;
  late ValueNotifier<String> _selectedRoleNotifier;

  final roleList = [
    {'value': 'user', 'label': '普通用户'},
    {'value': 'recycler', 'label': '回收员'},
  ];

  @override
  void initState() {
    super.initState();

    _usernameController = TextEditingController();
    _passwordController = TextEditingController();

    _isPasswordVisibleNotifier = ValueNotifier<bool>(false);
    _selectedRoleNotifier = ValueNotifier("user");
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();

    _isPasswordVisibleNotifier.dispose();
    _selectedRoleNotifier.dispose();

    super.dispose();
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
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 20.h),
                  // 页面标题
                  Text(
                    "欢迎回来",
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "请登录您的账号",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 40.h),
                  // 用户名输入框
                  _buildUsernameField(),
                  SizedBox(height: 20.h),
                  // 密码输入框
                  _buildPasswordField(),
                  SizedBox(height: 20.h),
                  // 用户身份栏
                  _buildRoleField(),
                  SizedBox(height: 16.h),
                  _buildForgotPasswordButton(),
                  SizedBox(height: 20.h),
                  // 登录按钮
                  _buildSubmitButton(),
                  SizedBox(height: 20.h),
                  // 注册入口
                  _buildRegisterTips(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String labelText,
      required String hintText,
      required IconData prefixIcon,
      TextInputType? keyboardType,
      TextEditingController? controller,
      String? Function(String?)? validator,
      Widget? suffixIcon,
      void Function(String?)? onChanged,
      bool obscureText = false,
      Key? key}) {
    return TextFormField(
      key: key,
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

  Widget _buildPasswordField() {
    return ValueListenableBuilder(
      valueListenable: _isPasswordVisibleNotifier,
      builder: (context, isVisible, child) {
        return _buildTextField(
          obscureText: !isVisible,
          labelText: "密码",
          hintText: "请输入密码",
          keyboardType: TextInputType.visiblePassword,
          prefixIcon: Icons.lock_outline,
          controller: _passwordController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入密码';
            }
            return null;
          },
          suffixIcon: IconButton(
            icon: Icon(
              !isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey[600],
              size: 22.r,
            ),
            onPressed: () {
              _isPasswordVisibleNotifier.value =
                  !_isPasswordVisibleNotifier.value;
            },
          ),
        );
      },
    );
  }

  Widget _buildRoleField() {
    return ValueListenableBuilder(
      valueListenable: _selectedRoleNotifier,
      builder: (context, selectedRole, child) {
        return DropdownButtonFormField(
          value: selectedRole,
          decoration: InputDecoration(
            labelText: "身份",
            prefixIcon: Icon(
              Icons.person_outline,
              color: const Color(0xFF04C264),
              size: 22.r,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: const Color(0xFF04C264),
                width: 1.w,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
          items: roleList.map((item) {
            return DropdownMenuItem(
              value: item['value'],
              child: Text(item['label']!),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              _selectedRoleNotifier.value = newValue;
            }
          },
        );
      },
    );
  }

  Widget _buildForgotPasswordButton() {
    return Container(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => RouteHelper.push(context, const ForgotPasswordPage()),
        child: Text(
          "忘记密码？",
          style: TextStyle(
            color: const Color(0xFF04C264),
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF04C264),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Text(
          "登录",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterTips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "还没有账号？",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14.sp,
          ),
        ),
        TextButton(
          onPressed: () => RouteHelper.push(context, const RegisterPage()),
          child: Text(
            "立即注册",
            style: TextStyle(
              color: const Color(0xFF04C264),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await CustomHelper.executeAsyncCall(
      context: context,
      futureCall: Provider.of<AuthViewModel>(context, listen: false).login(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRoleNotifier.value,
      ),
      onSuccess: (_) async {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        RouteHelper.pushAndRemoveUntil(context, const TabPage(), (_) => false);
      },
      successMessage: "登录成功",
      failurePrefix: "登录失败",
    );
  }
}
