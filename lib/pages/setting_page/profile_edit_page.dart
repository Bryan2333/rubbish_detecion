import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _ageController;
  late TextEditingController _signatureController;

  final String _storedUsername = "已存用户名";
  final String _storedAge = "20";
  final String _storedSignature = "这个人很懒，什么也没留下";

  late ValueNotifier<String> _selectedGenderNotifier;

  @override
  void initState() {
    super.initState();
    _selectedGenderNotifier = ValueNotifier("男");

    _usernameController = TextEditingController(text: _storedUsername);
    _ageController = TextEditingController(text: _storedAge);
    _signatureController = TextEditingController(text: _storedSignature);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    _signatureController.dispose();
    _selectedGenderNotifier.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() == true) {
      // TODO: 向后端发送数据更新用户信息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("个人信息已保存", style: TextStyle(fontSize: 16.sp)),
          backgroundColor: const Color(0xFF04C264),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "编辑个人信息",
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
                // 用户名
                _buildTextField(
                  labelText: "用户名",
                  controller: _usernameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "请输入用户名";
                    }

                    if (value.length < 3 || value.length > 20) {
                      return "用户名长度需在3-20之间";
                    }

                    return null;
                  },
                  prefixIcon: Icons.person_outline,
                ),
                SizedBox(height: 16.h),
                // 年龄
                _buildTextField(
                  labelText: "年龄",
                  controller: _ageController,
                  prefixIcon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "请输入年龄";
                    }

                    final age = int.tryParse(value);
                    if (age == null || age < 0 || age > 150) {
                      return "请输入合理的年龄";
                    }

                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                // 个人签名
                _buildTextField(
                  labelText: "个人签名",
                  controller: _signatureController,
                  prefixIcon: Icons.description_outlined,
                  hintText: "(选填)",
                ),
                SizedBox(height: 16.h),
                // 性别
                _buildGenderField(),
                SizedBox(height: 30.h),
                // 提交按钮
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    TextEditingController? controller,
    bool enabled = true,
    String? initialValue,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: const Color(0xFF04C264))
            : null,
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
    );
  }

  Widget _buildGenderField() {
    return ValueListenableBuilder<String>(
      valueListenable: _selectedGenderNotifier,
      builder: (context, selectedGender, _) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[300]!),
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
              Row(
                children: [
                  Radio<String>(
                    value: "男",
                    groupValue: selectedGender,
                    activeColor: const Color(0xFF04C264),
                    onChanged: (value) =>
                        _selectedGenderNotifier.value = value ?? "男",
                  ),
                  const Text("男"),
                  const Spacer(),
                  Radio<String>(
                    value: "女",
                    groupValue: selectedGender,
                    activeColor: const Color(0xFF04C264),
                    onChanged: (value) =>
                        _selectedGenderNotifier.value = value ?? "女",
                  ),
                  const Text("女"),
                  const Spacer(),
                  Radio<String>(
                    value: "保密",
                    groupValue: selectedGender,
                    activeColor: const Color(0xFF04C264),
                    onChanged: (value) =>
                        _selectedGenderNotifier.value = value ?? "保密",
                  ),
                  const Text("保密"),
                ],
              ),
            ],
          ),
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
        onPressed: _saveProfile,
        child: Text(
          "保存信息",
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
