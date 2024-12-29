import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "关于我们",
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 顶部大标题
                    _buildTitle(),
                    SizedBox(height: 16.h),
                    // 简要介绍
                    _buildSubtitle(),
                    SizedBox(height: 24.h),
                    // 功能卡片
                    _buildCard(
                      title: "主要功能",
                      titleIcon: Icons.featured_play_list,
                      items: [
                        _buildFeatureItem(
                          icon: Icons.image,
                          title: "垃圾识别技术",
                          description:
                              "集成 TensorFlow Lite 模型，实现垃圾图片的实时分类识别，提升分类准确性。",
                        ),
                        _buildFeatureItem(
                          icon: Icons.info,
                          title: "分类指导",
                          description: "提供详细的垃圾分类规则查询和用户交互式引导，帮助用户正确分类垃圾。",
                        ),
                        _buildFeatureItem(
                          icon: Icons.schedule,
                          title: "回收服务",
                          description: "支持智能垃圾回收预约服务，与本地回收系统无缝对接，提升环保效率。",
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // 创新点卡片
                    _buildCard(
                      title: "研究创新点",
                      titleIcon: Icons.lightbulb_outline,
                      items: [
                        _buildInnovationItem(
                          icon: Icons.check_circle_outline,
                          description:
                              "直接在App中集成图像识别模型，对垃圾图像进行实时分类，减少对网络环境的依赖，提升用户体验。",
                        ),
                        _buildInnovationItem(
                          icon: Icons.check_circle_outline,
                          description:
                              "实现垃圾分类与本地回收服务的无缝对接，提供一站式的垃圾处理解决方案，提升垃圾分类的实际效果。",
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // 页脚信息
                    _buildFooterInfo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      "智能垃圾分类与回收服务APP",
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF04C264),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      "通过 Flutter 与 TensorFlow Lite 提供实时垃圾识别、分类指导以及本地回收服务，让垃圾分类更高效、更便捷。",
      style: TextStyle(
        fontSize: 16.sp,
        color: Colors.black87,
        height: 1.5.h,
      ),
    );
  }

  Widget _buildCard(
      {required String title,
      required IconData titleIcon,
      required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 3.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 卡片标题
            Row(
              children: [
                Icon(
                  titleIcon,
                  color: const Color(0xFF04C264),
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF04C264),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey[300], thickness: 1.h, height: 20.h),
            // 行
            ...items
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
      {required IconData icon,
      required String title,
      required String description}) {
    return Container(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF04C264), size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF04C264),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    height: 1.5.h,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInnovationItem(
      {required IconData icon, required String description}) {
    return Container(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF04C264), size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                height: 1.5.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 愿景标题
        Text(
          "我们的愿景",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF04C264),
          ),
        ),
        SizedBox(height: 10.h),
        // 愿景描述
        Text(
          "推动更多人参与到环保行动中，让垃圾分类变得简单高效，共建美好家园。",
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.black87,
            height: 1.5.h,
          ),
        ),
        SizedBox(height: 24.h),
        // 版本和版权信息
        Text(
          "版本信息：1.0.0\nCopyright © 2024",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
