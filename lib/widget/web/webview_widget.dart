import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:rubbish_detection/widget/loading_page.dart';

///需要加载的内容类型
enum WebViewType {
  //html文本
  htmlText,
  //链接
  url
}

///定义js通信回调方法
typedef JsChannelCallback = dynamic Function(List<dynamic> arguments);

///封装的WebView组件
class WebViewWidget extends StatefulWidget {
  const WebViewWidget(
      {super.key,
      required this.loadResource,
      this.onWebViewCreated,
      this.clearCache});

  //给webview加载的数据,可以是url，也可以是html文本
  final String loadResource;

  //是否清除缓存后再加载
  final bool? clearCache;

  final Function(InAppWebViewController controller)? onWebViewCreated;

  @override
  State<StatefulWidget> createState() {
    return _WebViewWidgetState();
  }
}

class _WebViewWidgetState extends State<WebViewWidget> {
  //webview控制器
  late InAppWebViewController webViewController;
  final GlobalKey webViewKey = GlobalKey();

  // webview配置
  InAppWebViewSettings options = InAppWebViewSettings(
    useShouldOverrideUrlLoading: true,
    mediaPlaybackRequiresUserGesture: false,
    builtInZoomControls: false,
    useHybridComposition: true,
    allowsInlineMediaPlayback: true,
    loadsImagesAutomatically: true,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
        key: webViewKey,
        initialSettings: options,
        onWebViewCreated: (controller) {
          webViewController = controller;

          //是否清除缓存后再加载
          if (widget.clearCache == true) {
            InAppWebViewController.clearAllCache();
          }

          if (widget.onWebViewCreated == null) {
            webViewController.loadUrl(
                urlRequest: URLRequest(url: WebUri(widget.loadResource)));
          } else {
            widget.onWebViewCreated?.call(controller);
          }
        },
        onConsoleMessage: (controller, consoleMessage) {
          log("consoleMessage ====来自于js的打印==== \n $consoleMessage");
        },
        onProgressChanged: (InAppWebViewController controller, int progress) {},
        onLoadStart: (InAppWebViewController controller, Uri? url) {
          LoadingPage.showLoading(duration: const Duration(seconds: 45));
        },
        onReceivedError: (controller, request, error) {
          LoadingPage.hideLoading();
        },
        onLoadStop: (InAppWebViewController controller, Uri? url) {
          LoadingPage.hideLoading();
        },
        onPageCommitVisible: (InAppWebViewController controller, Uri? url) {});
  }
}
