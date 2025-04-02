import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rubbish_detection/pages/auth_page/auth_vm.dart';
import 'package:rubbish_detection/pages/auth_page/login_page.dart';
import 'package:rubbish_detection/pages/personal_page/personal_vm.dart';
import 'package:rubbish_detection/pages/setting_page/about_us_page.dart';
import 'package:rubbish_detection/pages/setting_page/feedback_page.dart';
import 'package:rubbish_detection/pages/setting_page/setting_page.dart';
import 'package:rubbish_detection/pages/tab_page/tab_page.dart';
import 'package:rubbish_detection/repository/data/user_bean.dart';
import 'package:rubbish_detection/utils/custom_helper.dart';
import 'package:rubbish_detection/utils/route_helper.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  final _personalViewModel = PersonalViewModel();

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  Future<void> _initUserData() async {
    final isLogged =
        await Provider.of<AuthViewModel>(context, listen: false).isLogged();
    if (isLogged) {
      if (!mounted) return;

      final userId =
          await Provider.of<AuthViewModel>(context, listen: false).getUserId();
      await _personalViewModel.initData(userId);
    }
  }

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
      body: SafeArea(
        child: ChangeNotifierProvider(
          create: (_) => _personalViewModel,
          child: SingleChildScrollView(
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
      child: Consumer<PersonalViewModel>(
        builder: (context, vm, child) {
          return Column(
            children: [
              // 头像部分
              _buildUserAvatar(vm.user),
              SizedBox(height: 15.h),
              // 用户信息
              vm.user == null
                  ? _buildLoggedOutUserInfo()
                  : _buildLoggedInUserInfo(vm.user),
              SizedBox(height: 20.h),
              // 数据统计
              _buildStatistic(vm.user),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserAvatar(UserBean? user) {
    final defaultAvatar = CircleAvatar(
      radius: 50.r,
      backgroundColor: Colors.grey[100],
      child: Icon(Icons.person, size: 60.r, color: const Color(0xFF00CE68)),
    );

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
      child: (user?.avatar?.isNotEmpty ?? false)
          ? CachedNetworkImage(
              imageUrl: user!.avatar!,
              imageBuilder: (context, imageProvider) {
                return CircleAvatar(
                  radius: 50.r,
                  backgroundImage: imageProvider,
                );
              },
              placeholder: (_, __) => CustomHelper.progressIndicator,
              errorWidget: (_, __, ___) => defaultAvatar,
            )
          : defaultAvatar,
    );
  }

  // 已登录状态下的用户信息
  Widget _buildLoggedInUserInfo(UserBean? user) {
    final String signature;
    if (user?.signature?.isEmpty ?? true) {
      signature = "这个人很懒，什么都没留下";
    } else {
      signature = user!.signature!;
    }

    return Column(
      children: [
        Text(
          user?.username ?? "佚名",
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Text(
          signature,
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
          onTap: () => RouteHelper.push(context, const LoginPage()),
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

  Widget _buildStatistic(UserBean? user) {
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
            value: user == null ? "0" : "${user.participationCount ?? 0}",
            label: "参与回收次数",
            icon: Icons.recycling,
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: Colors.grey[300],
          ),
          _buildStatItem(
            value: user == null
                ? "0.00"
                : (user.totalRecycleAmount ?? 0).toStringAsFixed(2),
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
      child: Consumer<PersonalViewModel>(
        builder: (context, vm, child) {
          return Column(
            children: [
              _buildFunctionItem(
                icon: Icons.feedback_outlined,
                title: "意见反馈",
                onTap: () => RouteHelper.push(context, const FeedbackPage()),
              ),
              Divider(color: Colors.grey[300], thickness: 0.5.h),
              _buildFunctionItem(
                icon: Icons.settings_outlined,
                title: "设置中心",
                onTap: () =>
                    RouteHelper.push(context, SettingsPage(user: vm.user))
                        .then((_) => _initUserData()),
              ),
              Divider(color: Colors.grey[300], thickness: 0.5.h),
              _buildFunctionItem(
                icon: Icons.info_outline_rounded,
                title: "关于我们",
                onTap: () => RouteHelper.push(context, const AboutUsPage()),
              ),
              if (vm.user != null) ...[
                Divider(color: Colors.grey[300], thickness: 0.5.h),
                _buildFunctionItem(
                  icon: Icons.exit_to_app_outlined,
                  title: "退出登录",
                  onTap: () {
                    _showDialog(
                      title: "退出登录",
                      content: "确定要退出登录吗？",
                      onConfirm: _handleLogout,
                    );
                  },
                )
              ]
            ],
          );
        },
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
        content: Text(
          content,
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "取消",
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: onConfirm,
            child: const Text(
              "确定",
              style: TextStyle(
                color: Color(0xFF04C264),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    await CustomHelper.executeAsyncCall(
      context: context,
      futureCall:
          Provider.of<AuthViewModel>(context, listen: false).logout("0"),
      onSuccess: (_) {
        RouteHelper.pushAndRemoveUntil(context, const TabPage(), (_) => false);
        Provider.of<RecycleViewModel>(context, listen: false).clearCache();
      },
      successMessage: "退出登录成功",
      failurePrefix: "退出登录失败",
    );
  }
}
