import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:rubbish_detection/pages/auth_page/auth_vm.dart';
import 'package:rubbish_detection/pages/discovery_page/discovery_vm.dart';
import 'package:rubbish_detection/pages/quiz_page/quiz_page.dart';
import 'package:rubbish_detection/pages/recycle_page/recycle_page.dart';
import 'package:rubbish_detection/repository/data/news_bean.dart';
import 'package:rubbish_detection/utils/custom_helper.dart';
import 'package:rubbish_detection/utils/route_helper.dart';
import 'package:rubbish_detection/widget/web/webview_page.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  final _discoveryViewModel = DiscoveryViewModel();

  final _dateFormatter = DateFormat("yyyy-MM-dd");

  late RefreshController _refreshController;

  @override
  void initState() {
    super.initState();

    _refreshController = RefreshController(initialRefresh: false);

    _discoveryViewModel.getNews(loadMore: false);
  }

  @override
  void dispose() {
    _refreshController.dispose();

    super.dispose();
  }

  Future<void> _refreshOrLoad({required bool isLoad}) async {
    if (isLoad) {
      if (_discoveryViewModel.hasMore == false) {
        CustomHelper.showSnackBar(context, "没有更多新闻了", defaultStyle: true);
      } else {
        _discoveryViewModel.getNews(loadMore: true);
      }
      _refreshController.loadComplete();
    } else {
      _discoveryViewModel.getNews(loadMore: false);
      _refreshController.refreshCompleted();
    }
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
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        body: SafeArea(
          child: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: true,
            onRefresh: () => _refreshOrLoad(isLoad: false),
            onLoading: () => _refreshOrLoad(isLoad: true),
            header: const WaterDropMaterialHeader(
              backgroundColor: Colors.white,
              color: Color(0xFF00CE68),
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 热门活动区
                SliverToBoxAdapter(child: _buildActivitiesSection()),
                // 今日热点区
                ..._buildNewsSection()
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
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildActivityCard(
                  image: "assets/images/delivery.png",
                  onTap: () async {
                    final isLogged =
                        await Provider.of<AuthViewModel>(context, listen: false)
                            .isLogged();
                    if (!mounted) return;
                    if (!isLogged) {
                      CustomHelper.showSnackBar(context, "请先登录",
                          success: false);
                      return;
                    }
                    RouteHelper.push(context, const RecyclingPage());
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildActivityCard(
                  image: "assets/images/quiz.png",
                  onTap: () => RouteHelper.push(context, const QuizPage()),
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
              color: Colors.black.withValues(alpha: 0.05),
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

  List<Widget> _buildNewsSection() {
    return [
      SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.all(16.r),
          child: Text(
            "今日热点",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
      Consumer<DiscoveryViewModel>(
        builder: (context, vm, child) {
          if (vm.newsList.isEmpty) {
            return const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00CE68),
                ),
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: vm.newsList.length,
              (context, index) => _buildNewsCard(vm.newsList[index]),
            ),
          );
        },
      )
    ];
  }

  Widget _buildNewsCard(NewsBean news) {
    final createdTime =
        _dateFormatter.format(_dateFormatter.parse(news.createdTime ?? ""));

    return Container(
      margin: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => RouteHelper.push(
              context, WebViewPage(loadResource: news.url ?? "")),
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(12.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    height: 90.h,
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
                              color: Colors.black,
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
                                  Text(
                                    createdTime,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[500],
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
