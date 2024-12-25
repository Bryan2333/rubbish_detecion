import 'package:flutter/material.dart';

import 'webview_widget.dart';

///显示网页资源的页面
class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key, required this.loadResource});

  //给webview加载的数据,可以是url，也可以是html文本
  final String loadResource;

  @override
  State<StatefulWidget> createState() {
    return _WebViewPageState();
  }
}

class _WebViewPageState extends State<WebViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(
          loadResource: widget.loadResource,
        ),
      ),
    );
  }
}
