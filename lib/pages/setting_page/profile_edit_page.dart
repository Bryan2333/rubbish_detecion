import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/repository/api.dart';
import 'package:rubbish_detection/repository/data/user_bean.dart';
import 'package:rubbish_detection/utils/db_helper.dart';
import 'package:rubbish_detection/utils/image_helper.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key, required this.user});

  final UserBean user;

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _ageController;
  late TextEditingController _signatureController;
  late ValueNotifier<String> _selectedGender;
  late ValueNotifier<File?> _avatarImage;

  @override
  void initState() {
    super.initState();
    _selectedGender = ValueNotifier("男");
    _usernameController = TextEditingController(text: widget.user.username);
    _ageController = TextEditingController(text: widget.user.age.toString());
    _signatureController = TextEditingController(
        text: widget.user.signature?.isEmpty == true
            ? "这个人很懒，什么都没留下"
            : widget.user.signature);
    _avatarImage = ValueNotifier(null);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    _signatureController.dispose();
    _selectedGender.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() == false) {
      return;
    }

    try {
      final (user, message) = await Api.instance.changeUserInfo(
          widget.user.id!,
          _usernameController.text.trim(),
          int.parse(_ageController.text.trim()),
          _selectedGender.value,
          _signatureController.text.trim(),
          _avatarImage.value != null
              ? base64Encode(await _avatarImage.value!.readAsBytes())
              : null);

      if (message == null) {
        await DbHelper.instance.updateUser(user!);
        _showSnackBar("用户信息更新成功");
      } else {
        _showSnackBar("用户信息更新失败：$message", success: false);
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
          "编辑个人信息",
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
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
                // 头像
                _buildAvatarField(),
                SizedBox(height: 30.h),
                // 用户名
                _buildTextField(
                  labelText: "用户名",
                  controller: _usernameController,
                  validator: (value) {
                    final trimmed = value?.trim();

                    if (trimmed == null || trimmed.isEmpty) {
                      return "请输入用户名";
                    }

                    if (trimmed.length < 3 || trimmed.length > 20) {
                      return "用户名长度需在3-20之间";
                    }

                    return null;
                  },
                  prefixIcon: Icons.person_outline,
                ),
                SizedBox(height: 20.h),
                // 年龄
                _buildTextField(
                  labelText: "年龄",
                  controller: _ageController,
                  prefixIcon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "请输入年龄";
                    }

                    final age = int.tryParse(value);
                    if (age == null || age < 0 || age > 150) {
                      return "请输入合理的年龄";
                    }

                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                // 个人签名
                _buildTextField(
                  labelText: "个人签名",
                  controller: _signatureController,
                  prefixIcon: Icons.description_outlined,
                  hintText: "(选填)",
                ),
                SizedBox(height: 20.h),
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
            _avatarImage.value = image;
          }
        },
        child: Stack(
          children: [
            ValueListenableBuilder(
              valueListenable: _avatarImage,
              builder: (context, avatarImage, child) {
                ImageProvider? imageProvider;
                if (avatarImage != null) {
                  imageProvider = FileImage(avatarImage);
                } else if (widget.user.avatar?.isNotEmpty == true) {
                  imageProvider =
                      CachedNetworkImageProvider(widget.user.avatar!);
                }

                return Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00CE68),
                      width: 2.r,
                    ),
                    image: imageProvider != null
                        ? DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageProvider == null
                      ? Icon(
                          Icons.add_a_photo_outlined,
                          size: 40.r,
                          color: const Color(0xFF00CE68),
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
                  color: Color(0xFF00CE68),
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
            ? Icon(prefixIcon, color: const Color(0xFF00CE68))
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
          borderSide: const BorderSide(color: Color(0xFF00CE68)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }

  Widget _buildGenderField() {
    return ValueListenableBuilder(
      valueListenable: _selectedGender,
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
                  Radio(
                    value: "男",
                    groupValue: selectedGender,
                    activeColor: const Color(0xFF00CE68),
                    onChanged: (value) => _selectedGender.value = value!,
                  ),
                  const Text("男"),
                  const Spacer(),
                  Radio(
                    value: "女",
                    groupValue: selectedGender,
                    activeColor: const Color(0xFF00CE68),
                    onChanged: (value) => _selectedGender.value = value!,
                  ),
                  const Text("女"),
                  const Spacer(),
                  Radio(
                    value: "保密",
                    groupValue: selectedGender,
                    activeColor: const Color(0xFF00CE68),
                    onChanged: (value) => _selectedGender.value = value!,
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
          backgroundColor: const Color(0xFF00CE68),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: _saveProfile,
        child: Text(
          "保存信息",
          style: TextStyle(fontSize: 18.sp, color: Colors.white),
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
