import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rubbish_detection/pages/setting_page/change_email_page.dart';
import 'package:rubbish_detection/pages/setting_page/change_password_page.dart';
import 'package:rubbish_detection/pages/setting_page/profile_edit_page.dart';
import 'package:rubbish_detection/repository/data/user_bean.dart';
import 'package:rubbish_detection/utils/custom_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.user});

  final UserBean? user;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "设置中心",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20.r,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            // 个人信息编辑卡片
            _buildSettingsGroup(
              title: "个人信息",
              items: [
                _buildSettingsItem(
                  icon: Icons.person_outline,
                  title: "修改个人信息",
                  onTap: _requireLogin(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ProfileEditPage(user: widget.user!);
                        },
                      ),
                    );
                  }),
                ),
                _buildDivider(),
                _buildSettingsItem(
                  icon: Icons.lock_outline,
                  title: "修改密码",
                  onTap: _requireLogin(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ChangePasswordPage(user: widget.user!);
                        },
                      ),
                    );
                  }),
                ),
                _buildDivider(),
                _buildSettingsItem(
                  icon: Icons.email_outlined,
                  title: "修改邮箱",
                  onTap: _requireLogin(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ChangeEmailPage(user: widget.user!);
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            // 应用设置卡片
            _buildSettingsGroup(
              title: "应用设置",
              items: [
                _buildSettingsItem(
                  icon: Icons.storage_outlined,
                  title: "清除缓存",
                  onTap: () => _showDialog(
                    title: "清理缓存",
                    content: "确认要清理缓存吗",
                    onConfirm: _clearCache,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 16.w, bottom: 8.h),
          child: Text(
            title,
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF00CE68)),
          ),
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[200]!,
                blurRadius: 10.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22.r,
                color: const Color(0xFF00CE68),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(fontSize: 16.sp),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.r,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1.h, color: Colors.grey[100]);
  }

  void _showDialog(
      {required String title,
      required String content,
      required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(title),
        content: Text(content, style: TextStyle(fontSize: 16.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("取消", style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: onConfirm,
            child: const Text("确定", style: TextStyle(color: Color(0xFF00CE68))),
          ),
        ],
      ),
    );
  }

  VoidCallback _requireLogin(VoidCallback onLoggedInAction) {
    return () {
      if (widget.user == null) {
        CustomHelper.showSnackBar(context, "请先登录", success: false);
        return;
      }
      onLoggedInAction();
    };
  }

  Future<void> _clearCache() async {
    Navigator.pop(context);

    final directory = await getTemporaryDirectory();
    final tempDir = Directory(directory.path);
    if (await tempDir.exists()) {
      tempDir.deleteSync(recursive: true);
    }

    if (mounted) {
      CustomHelper.showSnackBar(context, "缓存清理完毕");
    }
  }
}
