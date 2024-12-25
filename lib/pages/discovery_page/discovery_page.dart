import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rubbish_detection/repository/data/news_data.dart';
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
          centerTitle: true,
          title: Text(
            "发现",
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(left: 15.w, right: 15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "热门活动",
                    style:
                        TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, RoutePath.recyclePage);
                        },
                        child: Image.asset(
                          "assets/images/delivery.png",
                          width: 165.w,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QuizPage(),
                            ),
                          );
                        },
                        child: Image.asset(
                          "assets/images/quiz.png",
                          width: 165.w,
                          fit: BoxFit.fitWidth,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "今日热点",
                    style:
                        TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 20.h),
                  Consumer<DiscoveryViewModel>(
                    builder: (context, vm, child) {
                      if (vm.newsList.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: vm.newsList.length,
                        itemBuilder: (context, index) {
                          return _listViewItem(vm.newsList[index]);
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _listViewItem(News news) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewPage(
              loadResource: news.url ?? "",
            ),
          ),
        );
      },
      child: Container(
        height: 100.h,
        margin: EdgeInsets.only(bottom: 25.h),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.network(
                news.imageUrl ?? "",
                width: 120.w,
                fit: BoxFit.fitWidth,
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                children: [
                  Text(
                    news.title ?? "",
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        news.author ?? "",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      const Spacer(),
                      Text(
                        news.createdTime ?? "",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
