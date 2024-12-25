import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/pages/discovery_page/discovery_page.dart';
import 'package:rubbish_detection/pages/record_page/record_page.dart';
import 'package:rubbish_detection/pages/recycle_page/recycle_page.dart';
import 'package:rubbish_detection/pages/quiz_page/quiz_page.dart';
import 'package:rubbish_detection/pages/quiz_page/quiz_result_page.dart';
import 'package:rubbish_detection/pages/tab_page/tab_page.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return switch (settings.name) {
      RoutePath.tabPage => pageRoute(const TabPage(), settings: settings),
      RoutePath.recordPage => pageRoute(const RecordPage(), settings: settings),
      RoutePath.discoveryPage =>
        pageRoute(const DiscoveryPage(), settings: settings),
      RoutePath.quizPage => pageRoute(const QuizPage(), settings: settings),
      RoutePath.quizResultPage =>
        pageRoute(const QuizResultPage(), settings: settings),
      RoutePath.recyclePage =>
        pageRoute(const RecyclingPage(), settings: settings),
      _ => pageRoute(notFoundPage(settings))
    };
  }

  static MaterialPageRoute pageRoute(Widget page,
      {RouteSettings? settings,
      bool? fullscreenDialog,
      bool? maintainState,
      bool? allowSnapshotting}) {
    return MaterialPageRoute(
        builder: (BuildContext context) => page,
        settings: settings,
        fullscreenDialog: fullscreenDialog ?? false,
        maintainState: maintainState ?? true,
        allowSnapshotting: allowSnapshotting ?? true);
  }

  static Widget notFoundPage(RouteSettings settings) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            "route path ${settings.name} 不存在",
            style: TextStyle(fontSize: 32.sp),
          ),
        ),
      ),
    );
  }
}

class RoutePath {
  static const String tabPage = "/";

  static const String recordPage = "/record_page";

  static const String discoveryPage = "/discovery_page";

  static const String quizPage = "/quiz_page";

  static const String quizResultPage = "/quiz_result_page";

  static const String recyclePage = "/recycle_page";
}
