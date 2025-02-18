import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/pages/tab_page/tab_page.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return switch (settings.name) {
      RoutePath.tabPage => pageRoute(const TabPage(), settings: settings),
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
}
