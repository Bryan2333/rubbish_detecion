import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:email_validator/email_validator.dart';
import 'package:rubbish_detection/http/dio_instance.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _feedbackController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _feedbackController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _feedbackController.dispose();

    super.dispose();
  }

  void _submitFeedback() async {
    if (_formKey.currentState?.validate() == false) {
      return;
    }

    try {
      final response = await DioInstance.instance.post(
        "/api/feedback/add",
        data: {
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "content": _feedbackController.text.trim()
        },
      );

      if (response.data["code"] == "0000") {
        _showSnackBar("提交成功，感谢您的反馈");
        // 清空输入框
        _nameController.clear();
        _emailController.clear();
        _feedbackController.clear();
      } else {
        _showSnackBar("提交失败，请稍后再试", success: false);
      }
    } catch (e) {
      _showSnackBar("网络异常，请稍后再试", success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "意见反馈",
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
                // 姓名输入框
                _buildNameField(),
                SizedBox(height: 20.h),
                // 邮箱输入框
                _buildEmailField(),
                SizedBox(height: 20.h),
                // 反馈内容输入框
                _buildFeedbackField(),
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

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      required String hint,
      required IconData icon,
      String? Function(String?)? validator,
      int? maxLines}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF04C264)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF04C264)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      validator: validator,
    );
  }

  Widget _buildNameField() {
    return _buildTextField(
      controller: _nameController,
      label: "姓名",
      hint: "请输入您的姓名",
      icon: Icons.person_outline,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '姓名不能为空';
        }

        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      controller: _emailController,
      label: "邮箱",
      hint: "请输入您的邮箱地址",
      icon: Icons.email_outlined,
      validator: (value) {
        final trimmed = value?.trim();
        if (trimmed == null || trimmed.isEmpty) {
          return '邮箱不能为空';
        }

        if (EmailValidator.validate(trimmed) == false) {
          return '请输入有效的邮箱地址';
        }

        return null;
      },
    );
  }

  Widget _buildFeedbackField() {
    return _buildTextField(
      controller: _feedbackController,
      label: "反馈内容",
      hint: "请详细描述您的反馈",
      icon: Icons.feedback_outlined,
      maxLines: 5,
      validator: (value) {
        final trimmed = value?.trim();
        if (trimmed == null || trimmed.isEmpty) {
          return '反馈内容不能为空';
        }

        if (trimmed.length < 10) {
          return '反馈内容至少需要10个字符';
        }

        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _submitFeedback,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF04C264),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Text(
          "提交反馈",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
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
