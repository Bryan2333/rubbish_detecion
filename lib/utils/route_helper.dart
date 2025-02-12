import 'package:flutter/material.dart';

class RouteHelper {
  /// 普通跳转（新建一个页面）
  static Future<T?> push<T extends Object?>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// 替换当前路由（新页面替换当前页面）
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
      BuildContext context, Widget page) {
    return Navigator.pushReplacement<T, TO>(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// 跳转并移除直到满足条件的所有页面
  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    Widget page,
    RoutePredicate predicate,
  ) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      MaterialPageRoute(builder: (context) => page),
      predicate,
    );
  }

  /// 返回到指定页面（popUntil）
  static void popUntil(BuildContext context, RoutePredicate predicate) {
    Navigator.popUntil(context, predicate);
  }
}
