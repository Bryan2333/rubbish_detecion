import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:email_validator/email_validator.dart';

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

  void _submitFeedback() {
    if (_formKey.currentState?.validate() == true) {
      // TODO: 在这里添加提交反馈的逻辑，如调用后端API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "感谢您的反馈！",
            style: TextStyle(fontSize: 16.sp),
          ),
          backgroundColor: const Color(0xFF04C264),
        ),
      );

      // 清空输入框
      _nameController.clear();
      _emailController.clear();
      _feedbackController.clear();
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
        if (value == null || value.trim().isEmpty) {
          return '邮箱不能为空';
        }

        if (EmailValidator.validate(value.trim()) == false) {
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
        if (value == null || value.trim().isEmpty) {
          return '反馈内容不能为空';
        }

        if (value.trim().length < 10) {
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
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
