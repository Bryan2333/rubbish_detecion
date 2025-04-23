import 'dart:convert';
import 'dart:developer';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rubbish_detection/http/dio_instance.dart';
import 'package:rubbish_detection/repository/api.dart';
import 'package:rubbish_detection/repository/data/order_bean.dart';
import 'package:rubbish_detection/utils/event_bus_helper.dart';
import 'package:rubbish_detection/utils/stomp_helper.dart';

class RecycleViewModel with ChangeNotifier {
  // 缓存不同筛选条件下的订单数据，key 根据订单状态生成
  final _ordersCache = <int, List<OrderBean>>{};

  // 记录每个筛选条件下当前加载到的页码
  final _pageTracker = <int, int>{};

  // 记录每个筛选条件下是否还有更多数据
  final _hasMore = <int, bool>{};

  var isLoading = false;

  bool hasMore(int? orderStatus) {
    return _hasMore[_cacheKey(orderStatus)] ?? false;
  }

  List<OrderBean> ordersByStatus(int? status) {
    final key = _cacheKey(status, isRecent: false);
    return _ordersCache[key] ?? [];
  }

  List<OrderBean> recentByStatus(int? status) {
    final key = _cacheKey(status, isRecent: true);
    return _ordersCache[key] ?? [];
  }

  /// key 约定：
  ///  status == null, isRecent=false → 200 （所有订单分页）
  ///  status != null, isRecent=false → 状态本身（0、1、2……）
  ///  status == null, isRecent=true  → 100 （所有近期订单）
  ///  status != null, isRecent=true  → 1000 + status （各状态的近期）
  int _cacheKey(int? orderStatus, {bool isRecent = false}) {
    if (isRecent) {
      if (orderStatus == null) return 100;
      return 1000 + orderStatus;
    }
    if (orderStatus == null) return 200;
    return orderStatus;
  }

  Future<(int?, String?, OrderBean?)> createOrder(OrderBean order) async {
    final result = await Api.instance.addOrder(order);

    _fixOrderData(result.$3!);

    return result;
  }

  /// 获取指定状态的订单列表，支持分页加载
  ///
  /// - [loadMore] 为 false 时表示加载第一页（或刷新），为 true 时表示加载下一页并追加数据；
  /// - [forceRefresh] 为 true 时表示强制刷新数据（从第一页重新加载）。
  /// - [pageSize] 为每页数据条数，默认为 10 条。
  Future<void> getOrdersByStatus(
    int userId,
    int? orderStatus, {
    bool loadMore = false,
    bool forceRefresh = false,
    int pageSize = 5,
  }) async {
    final key = _cacheKey(orderStatus);
    // 如果不是加载更多、非强制刷新，并且缓存已经存在，就直接返回缓存数据
    if (!loadMore && !forceRefresh && _ordersCache.containsKey(key)) {
      notifyListeners();
      return;
    }

    // 根据 loadMore 参数决定当前页码
    if (!loadMore || forceRefresh) {
      _pageTracker[key] = 1;
    } else {
      _pageTracker[key] = (_pageTracker[key] ?? 1) + 1;
    }
    final int pageNum = _pageTracker[key]!;

    try {
      isLoading = true;
      notifyListeners();

      final response = await Api.instance.getOrderByPage(
        userId,
        orderStatus: orderStatus,
        pageNum: pageNum,
        pageSize: pageSize,
      );

      List<OrderBean>? fetchedOrders = response?.$3;
      fetchedOrders ??= [];

      fetchedOrders.forEach(_fixOrderData);

      if (!loadMore || forceRefresh) {
        _ordersCache[key] = fetchedOrders;
      } else {
        _ordersCache[key] = (_ordersCache[key] ?? []) + fetchedOrders;
      }

      // 判断是否有更多数据
      _hasMore[key] = fetchedOrders.length == pageSize;
    } catch (e) {
      log("Error fetching orders by status: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getRecentOrders(int userId, {bool forceRefresh = false}) async {
    final allRecentKey = _cacheKey(null, isRecent: true); // 100
    // 初始化／清空所有近期相关缓存
    final statusKeys = [
      allRecentKey,
      for (var st in [0, 1, 2]) _cacheKey(st, isRecent: true), // 1000,1001,1002
    ];

    // 如果不强制刷新又已有“全部近期”缓存，直接返回
    if (!forceRefresh && _ordersCache.containsKey(allRecentKey)) {
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      // 1. 拉回所有近期订单
      final response = await Api.instance.getRecentOrder(userId);
      final fetched = response?.$3 ?? [];
      fetched.forEach(_fixOrderData);

      // 2. 清空旧缓存
      for (var key in statusKeys) {
        _ordersCache[key] = <OrderBean>[];
      }

      // 3. “全部近期”缓存填充
      _ordersCache[allRecentKey] = fetched;

      // 4. 按状态拆分到各自“近期”缓存
      for (var order in fetched) {
        final st = order.orderStatus;
        final key = _cacheKey(st, isRecent: true);
        _ordersCache[key] ??= [];
        _ordersCache[key]!.add(order);
      }
    } catch (e) {
      log("Error fetching recent orders: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<(int?, String?, Object?)> cancelOrder(
      {required int userId, required int orderId}) async {
    return await Api.instance.cancelOrder(userId, orderId);
  }

  Future<(int?, String?, Object?)> submitReview(
      {required int userId,
      required int orderId,
      required int reviewRate,
      required String reviewMessage}) async {
    return await Api.instance.submitOrderReview(
        userId: userId,
        orderId: orderId,
        reviewRate: reviewRate,
        reviewMessage: reviewMessage);
  }

  void _fixOrderData(OrderBean order) {
    final dateFormatter = DateFormat("yyyy年MM月dd日 HH:mm");
    order.waste?.photos = order.waste?.photos?.map((photo) {
      if (photo.imagePath?.isNotEmpty ?? false) {
        photo.imagePath = "${DioInstance.instance.baseURL}${photo.imagePath}";
      }
      return photo;
    }).toList();
    order.orderDate =
        dateFormatter.format(DateTime.parse(order.orderDate ?? ""));
  }

  void clearCache() {
    _ordersCache.clear();
    _pageTracker.clear();
    _hasMore.clear();
  }

  void stompSync() {
    Future.delayed(const Duration(seconds: 3), () {
      StompHelper.subscribe("/topic/order", (frame) {
        final message = frame.body;
        if (message == null) return;

        final allRecentKey = _cacheKey(null, isRecent: true);

        // 解析更新后的订单，并格式化订单数据
        final updatedOrder = OrderBean.fromJson(jsonDecode(message));
        _fixOrderData(updatedOrder);

        OrderBean? oldBean;
        int? oldStatus;

        _ordersCache.forEach((key, orders) {
          for (final o in orders) {
            if (o.id == updatedOrder.id) {
              oldBean = o;
              oldStatus = o.orderStatus;
              return;
            }
          }
        });

        final newStatus = updatedOrder.orderStatus;

        // 订单状态发生改变
        if (oldBean != null && oldStatus != newStatus) {
          final oldPageKey = _cacheKey(oldStatus, isRecent: false);
          final oldRecentKey = _cacheKey(oldStatus, isRecent: true);

          _ordersCache[oldPageKey]?.removeWhere((o) => o.id == updatedOrder.id);
          _ordersCache[oldRecentKey]
              ?.removeWhere((o) => o.id == updatedOrder.id);

          if (_ordersCache[allRecentKey]?.any((o) => o.id == updatedOrder.id) ==
              true) {
            final newRecentKey = _cacheKey(newStatus, isRecent: true);
            _ordersCache[newRecentKey] ??= [];

            final dateFormatter = DateFormat("yyyy年MM月dd日 HH:mm");
            final index = _ordersCache[newRecentKey]!.indexWhere((order) {
              final orderDate = dateFormatter.parse(order.orderDate ?? "");
              final newOrderDate =
                  dateFormatter.parse(updatedOrder.orderDate ?? "");

              return orderDate.isBefore(newOrderDate);
            });

            if (index == -1) {
              _ordersCache[newRecentKey]!.add(updatedOrder);
            } else {
              _ordersCache[newRecentKey]!
                  .insert(index, updatedOrder); // 插入到指定位置
            }

            if (_ordersCache[allRecentKey]
                    ?.any((o) => o.id == updatedOrder.id) ==
                true) {
              _ordersCache[allRecentKey]!
                  .firstWhereOrNull((o) => o.id == updatedOrder.id)
                  ?.copyWith(updatedOrder);
            }
          }
        } else if (oldBean != null) { // 订单状态未改变
          final pageKey = _cacheKey(oldStatus, isRecent: false);
          final recentKey = _cacheKey(oldStatus, isRecent: true);

          if (_ordersCache[pageKey]?.any((o) => o.id == updatedOrder.id) ==
              true) {
            _ordersCache[pageKey]!
                .firstWhereOrNull((o) => o.id == updatedOrder.id)
                ?.copyWith(updatedOrder);
          }

          if (_ordersCache[recentKey]?.any((o) => o.id == updatedOrder.id) ==
              true) {
            _ordersCache[recentKey]!
                .firstWhereOrNull((o) => o.id == updatedOrder.id)
                ?.copyWith(updatedOrder);
          }

          if (_ordersCache[allRecentKey]?.any((o) => o.id == updatedOrder.id) ==
              true) {
            _ordersCache[allRecentKey]!
                .firstWhereOrNull((o) => o.id == updatedOrder.id)
                ?.copyWith(updatedOrder);
          }
        }

        EventBusHelper.eventBus.fire(OrderInfoUpdateEvent(updatedOrder));

        notifyListeners();
      });
    });
  }
}
