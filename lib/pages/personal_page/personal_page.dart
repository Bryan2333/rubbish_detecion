import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/pages/auth_page/login_page.dart';

class PersonalPage extends StatefulWidget {
  final bool? isLoggedIn; // 添加登录状态
  final String? username; // 用户名可为空

  const PersonalPage({
    super.key,
    this.isLoggedIn = false,
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
          "个人主页",
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, size: 24.r),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 顶部个人信息卡片
            Stack(
              children: [
                // 个人信息卡片
                Container(
                  padding: EdgeInsets.only(top: 45.h),
                  child: Container(
                    margin: EdgeInsets.only(left: 20.w, right: 20.h, top: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 头像部分
                        Transform.translate(
                          offset: Offset(0, -40.h),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50.r,
                              backgroundColor: Colors.grey[100],
                              child: Icon(
                                Icons.person,
                                size: 60.r,
                                color: const Color(0xFF04C264),
                              ),
                            ),
                          ),
                        ),
                        // 用户信息
                        Transform.translate(
                          offset: Offset(0, -25.h),
                          child: Column(
                            children: [
                              // 根据登录状态显示不同内容
                              if (widget.isLoggedIn == true) ...[
                                // 已登录状态
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.username ?? "环保达人千库",
                                      style: TextStyle(
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Icon(
                                      Icons.verified,
                                      color: const Color(0xFF04C264),
                                      size: 20.r,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "愿这世界，如你一般美好",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ] else ...[
                                // 未登录状态
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return const LoginPage();
                                        },
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "去登录",
                                        style: TextStyle(
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF04C264),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: const Color(0xFF04C264),
                                        size: 18.r,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              SizedBox(height: 20.h),
                              // 数据统计
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 15.h),
                                margin: EdgeInsets.symmetric(horizontal: 20.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStatItem(
                                      value:
                                          widget.isLoggedIn == true ? "1" : "0",
                                      label: "参与回收次数",
                                      icon: Icons.recycling,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40.h,
                                      color: Colors.grey[300],
                                    ),
                                    _buildStatItem(
                                      value: widget.isLoggedIn == true
                                          ? "0.49"
                                          : "0.00",
                                      label: "累计回收金额(￥)",
                                      icon: Icons.payments_outlined,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            // 功能列表
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildMenuButton(
                    icon: Icons.feedback_outlined,
                    title: "意见反馈",
                    onTap: () {
                      // TODO: 实现意见反馈页面
                    },
                  ),
                  _buildMenuButton(
                    icon: Icons.help_outline_outlined,
                    title: "帮助中心",
                    showDivider: widget.isLoggedIn == true,
                    onTap: () {
                      // TODO: 实现帮助中小页面
                    },
                  ),
                  if (widget.isLoggedIn == true)
                    _buildMenuButton(
                      icon: Icons.logout_rounded,
                      title: "退出登录",
                      showDivider: false,
                      onTap: () {
                        // TODO: 实现退出登录逻辑
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: const Color(0xFF04C264),
          size: 24.r,
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque, // 确保整个区域可点击
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF04C264).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    icon,
                    size: 22.r,
                    color: const Color(0xFF04C264),
                  ),
                ),
                SizedBox(width: 16.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16.r,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1.h,
            indent: 20.w,
            endIndent: 20.w,
            color: Colors.grey[200],
          ),
      ],
    );
  }
}
