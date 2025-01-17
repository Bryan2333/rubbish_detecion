import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rubbish_detection/pages/rubbish_type_desc_page/rubbish_type_desc_vm.dart';

class RubbishTypeDescPage extends StatefulWidget {
  const RubbishTypeDescPage({super.key, required this.type});

  final int type;

  @override
  State<RubbishTypeDescPage> createState() => _RubbishTypeDescPageState();
}

class _RubbishTypeDescPageState extends State<RubbishTypeDescPage> {
  final _rubbishTypeDescViewModel = RubbishTypeDescViewModel();

  // 获取垃圾类型名称
  String get _typeName => switch (widget.type) {
        0 => "干垃圾",
        1 => "湿垃圾",
        2 => "可回收物",
        3 => "有害垃圾啊",
        _ => ""
      };

  // 获取主题色
  Color get _themeColor => switch (widget.type) {
        0 => const Color(0xFFFFA721),
        1 => const Color(0xFF4DB8FF),
        2 => const Color(0xFF1ADFCC),
        3 => const Color(0xFFFF7396),
        _ => Colors.grey
      };

  // 获取垃圾类型图标
  String get _iconImg => switch (widget.type) {
        0 => "assets/images/solid_waste_3.png",
        1 => "assets/images/food_waste_3.png",
        2 => "assets/images/recyclable_waste_3.png",
        3 => "assets/images/harmful_waste_3.png",
        _ => ""
      };

  @override
  void initState() {
    super.initState();
    _rubbishTypeDescViewModel.getDesc(widget.type);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _rubbishTypeDescViewModel,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: _themeColor,
          centerTitle: true,
          title: Text(
            _typeName,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 20.r, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Consumer<RubbishTypeDescViewModel>(
            builder: (context, vm, child) {
              if (vm.desc == null) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 介绍卡片
                      _buildDescCard(vm.desc?.name ?? "", vm.desc?.desc ?? ""),
                      SizedBox(height: 24.h),
                      // 投放要求
                      _buildSection(
                        title: "投放要求",
                        icon: Icons.assignment_outlined,
                        children: _buildDisposalAdvice(vm.desc?.disposalAdvice),
                      ),
                      SizedBox(height: 24.h),
                      // 处置方法
                      _buildSection(
                        title: "处置方法",
                        icon: Icons.recycling,
                        children: _buildHandlerMethods(vm.desc?.handleMethods),
                      ),
                      SizedBox(height: 24.h),
                      // 常见物品
                      _buildSection(
                        title: "常见物品",
                        icon: Icons.category_outlined,
                        children: _buildCommonThings(vm.desc?.commonThings),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDescCard(String name, String desc) {
    return Container(
      decoration: BoxDecoration(
        color: _themeColor,
        boxShadow: [
          BoxShadow(
            color: _themeColor.withValues(alpha: 0.3),
            blurRadius: 15.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Image.asset(
              _iconImg,
              width: 80.w,
              height: 80.h,
            ),
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16.sp,
                    height: 1.5.h,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10.r,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: _themeColor,
                  size: 24.r,
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1.h, color: Colors.grey[200]),
          Container(
            padding: EdgeInsets.all(20.r),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Container(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8.h),
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: _themeColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                height: 1.5.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDisposalAdvice(List<String>? advice) {
    return advice?.map((item) => _buildListItem(item)).toList() ?? [];
  }

  List<Widget> _buildHandlerMethods(List<String>? methods) {
    return methods?.map((method) => _buildListItem(method)).toList() ?? [];
  }

  List<Widget> _buildCommonThings(List<String>? things) {
    return things?.map((thing) => _buildListItem(thing)).toList() ?? [];
  }
}
