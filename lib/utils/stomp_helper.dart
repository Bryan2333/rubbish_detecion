import 'dart:async';
import 'dart:developer';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rubbish_detection/http/dio_instance.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class StompHelper {
  static StompClient? _stompClient;
  static bool isConnected = false;

  static String _satoken = "";

  static Future<void> _initToken() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;
    final jar = PersistCookieJar(storage: FileStorage("$appDocPath/.cookies/"));

    final cookies =
        await jar.loadForRequest(Uri.parse(DioInstance.instance.baseURL));
    _satoken = cookies
        .firstWhere(
          (cookie) => cookie.name == "satoken",
          orElse: () => throw Exception("satoken not found in cookies"),
        )
        .value;
  }

  /// 初始化Stomp客户端，连接到WebSocket，带上Cookie
  static Future<void> initStompClient({required String url}) async {
    try {
      if (_satoken.isEmpty) {
        await _initToken();
      }

      _stompClient = StompClient(
        config: StompConfig.sockJS(
          url: url,
          onWebSocketError: (error) => log('WebSocket error: $error'),
          onStompError: (error) => log('STOMP error: $error'),
          onDisconnect: (frame) => _onDisconnect(frame),
          webSocketConnectHeaders: {'Cookie': 'satoken=$_satoken'},
        ),
      );
      await activate();
    } catch (e) {
      log('Error initializing Stomp client: $e');
    }
  }

  static void subscribe(String topic, void Function(StompFrame) callback) {
    _stompClient?.subscribe(
      destination: "$topic/$_satoken",
      callback: callback,
    );
  }

  /// 处理断开连接时的逻辑
  static void _onDisconnect(StompFrame frame) {
    isConnected = false;
    log('Disconnected: ${frame.command}');
  }

  /// 激活Stomp客户端并建立连接
  static Future<void> activate() async {
    try {
      if (_stompClient != null) {
        _stompClient?.activate();
        isConnected = true;
      } else {
        log('StompClient is null. Please initialize it first.');
      }
    } catch (e) {
      log('Error activating Stomp client: $e');
    }
  }

  /// 关闭Stomp客户端连接
  static void dispose() {
    if (_stompClient != null) {
      _stompClient?.deactivate();
      _stompClient = null;
      _satoken = "";
      isConnected = false;
      log('Stomp client disposed and connection closed');
    }
  }
}
