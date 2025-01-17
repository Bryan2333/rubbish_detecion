import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/pages/auth_page/login_page.dart';
import 'package:rubbish_detection/pages/setting_page/about_us_page.dart';
import 'package:rubbish_detection/pages/setting_page/feedback_page.dart';
import 'package:rubbish_detection/pages/setting_page/setting_page.dart';

class PersonalPage extends StatefulWidget {
  final bool? isLoggedIn; // 添加登录状态
  final String? username; // 用户名可为空

  const PersonalPage({
    super.key,
    this.isLoggedIn = true,
    this.username,
  });

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "我的",
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              _buildPersonInfoCard(), // 个人信息卡片
              SizedBox(height: 25.h),
              _buildFunctionList(), // 功能列表
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonInfoCard() {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 15.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 头像部分
          _buildUserAvatar(),
          SizedBox(height: 15.h),
          // 用户信息
          widget.isLoggedIn == true
              ? _buildLoggedInUserInfo()
              : _buildLoggedOutUserInfo(),
          SizedBox(height: 20.h),
          // 数据统计
          _buildStatistic(),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.r,
            spreadRadius: 2.r,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 50.r,
        backgroundColor: Colors.grey[100],
        child: Icon(Icons.person, size: 60.r, color: const Color(0xFF00CE68)),
      ),
    );
  }

  // 已登录状态下的用户信息
  Widget _buildLoggedInUserInfo() {
    return Column(
      children: [
        Text(
          widget.username ?? "环保达人Bryan",
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Text(
          "愿这世界，如你一般美好",
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // 未登录状态下的用户信息
  Widget _buildLoggedOutUserInfo() {
    return Column(
      children: [
        Text(
          "您尚未登录",
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 10.h),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const LoginPage()));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "去登录",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF00CE68),
                ),
              ),
              SizedBox(width: 5.w),
              Icon(
                Icons.arrow_forward_ios,
                color: const Color(0xFF00CE68),
                size: 18.r,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatistic() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            value: widget.isLoggedIn == true ? "1" : "0",
            label: "参与回收次数",
            icon: Icons.recycling,
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: Colors.grey[300],
          ),
          _buildStatItem(
            value: widget.isLoggedIn == true ? "0.49" : "0.00",
            label: "累计回收金额(￥)",
            icon: Icons.payments_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF00CE68), size: 24.r),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildFunctionList() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 0.r,
            blurRadius: 15.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFunctionItem(
            icon: Icons.feedback_outlined,
            title: "意见反馈",
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FeedbackPage()));
            },
          ),
          Divider(color: Colors.grey[300], thickness: 0.5.h),
          _buildFunctionItem(
            icon: Icons.share_outlined,
            title: "分享给好友",
            onTap: () {
              // TODO: 实现分享给微信好友的功能
            },
          ),
          Divider(color: Colors.grey[300], thickness: 0.5.h),
          _buildFunctionItem(
            icon: Icons.settings_outlined,
            title: "设置中心",
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
          ),
          Divider(color: Colors.grey[300], thickness: 0.5.h),
          _buildFunctionItem(
            icon: Icons.info_outline_rounded,
            title: "关于我们",
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AboutUsPage()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionItem(
      {required IconData icon,
      required String title,
      required GestureTapCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
        child: Row(
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF00CE68), size: 24.r),
                SizedBox(width: 16.w),
                Text(title, style: TextStyle(fontSize: 16.sp)),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20.r),
          ],
        ),
      ),
    );
  }
}
