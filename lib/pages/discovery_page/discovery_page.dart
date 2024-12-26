import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rubbish_detection/repository/data/news_article.dart';
import 'package:rubbish_detection/route.dart';
import 'package:rubbish_detection/pages/discovery_page/discovery_vm.dart';
import 'package:rubbish_detection/pages/quiz_page/quiz_page.dart';
import 'package:rubbish_detection/widget/web/webview_page.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  final _discoveryViewModel = DiscoveryViewModel();

  @override
  void initState() {
    super.initState();
    _discoveryViewModel.getNews();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _discoveryViewModel,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            "发现",
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            color: const Color(0xFF00CE68),
            onRefresh: () async {
              await _discoveryViewModel.getNews();
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 活动专区
                SliverToBoxAdapter(
                  child: _buildActivitiesSection(),
                ),
                // 新闻列表
                SliverToBoxAdapter(
                  child: _buildNewsSection(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivitiesSection() {
    return Container(
      margin: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "热门活动",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildActivityCard(
                  image: "assets/images/delivery.png",
                  onTap: () =>
                      Navigator.pushNamed(context, RoutePath.recyclePage),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildActivityCard(
                  image: "assets/images/quiz.png",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuizPage()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              Image.asset(
                image,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsSection() {
    return Container(
      margin: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "今日热点",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          Consumer<DiscoveryViewModel>(
            builder: (context, vm, child) {
              if (vm.newsList.isEmpty) {
                return Center(
                  child: SizedBox(
                    height: 200.h,
                    child: const CircularProgressIndicator(
                      color: Color(0xFF00CE68),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vm.newsList.length,
                itemBuilder: (context, index) =>
                    _buildNewsCard(vm.newsList[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(News news) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WebViewPage(loadResource: news.url ?? ""),
            ),
          ),
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(12.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // 改为顶部对齐
              children: [
                // 新闻图片
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    news.imageUrl ?? "",
                    width: 120.w,
                    height: 90.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120.w,
                        height: 90.h,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 32.r,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                // 新闻内容
                Expanded(
                  child: SizedBox(
                    height: 90.h, // 设置固定高度，与图片等高
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题
                        Expanded(
                          child: Text(
                            news.title ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ),
                        // 作者和时间信息
                        Row(
                          children: [
                            // 作者信息
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 16.r,
                                    color: Colors.grey[500],
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      news.author ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 时间信息
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16.r,
                                    color: Colors.grey[500],
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      news.createdTime ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
