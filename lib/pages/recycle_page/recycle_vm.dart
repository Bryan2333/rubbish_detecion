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

        // 解析更新后的订单，并格式化订单数据
        final updatedOrder = OrderBean.fromJson(jsonDecode(message));
        _fixOrderData(updatedOrder);

        // 更新普通缓存（非近期缓存）
        // 普通缓存的 key 生成规则：isRecent 为 false，
        // 即：orderStatus 为 null 时 key 为 200，否则 key 就是 orderStatus 本身。
        _ordersCache.forEach((key, orderSet) {
          // 跳过近期缓存（key 为 100 或 >= 1000的缓存）
          if (key == 100 || key >= 1000) return;

          final existingOrder =
              orderSet.firstWhereOrNull((order) => order.id == updatedOrder.id);
          if (existingOrder != null) {
            // 如果订单状态发生变化，则从该缓存中移除
            if (existingOrder.orderStatus != updatedOrder.orderStatus) {
              orderSet.remove(existingOrder);
            } else {
              // 否则直接使用 copyWith 方法更新订单信息
              existingOrder.copyWith(updatedOrder);
            }
          }
        });

        // 更新近期缓存
        // 首先更新“全部近期”缓存，其 key 为 100
        final allRecentKey = _cacheKey(null, isRecent: true);
        final allRecentSet = _ordersCache[allRecentKey];
        if (allRecentSet != null) {
          final existingRecent = allRecentSet
              .firstWhereOrNull((order) => order.id == updatedOrder.id);
          if (existingRecent != null) {
            // 更新“全部近期”缓存中的订单信息
            existingRecent.copyWith(updatedOrder);

            // 如果订单状态发生变化，则需要在近期缓存中从旧状态移除并添加到新状态的近期缓存
            final newRecentKey =
                _cacheKey(updatedOrder.orderStatus, isRecent: true);
            // 假设订单状态值范围在 0、1、2、3，这里列出所有近期状态的 key（1000, 1001, 1002, 1003）
            final recentStateKeys = [
              for (var st in [0, 1, 2, 3]) 1000 + st
            ];
            for (var key in recentStateKeys) {
              if (key != newRecentKey) {
                _ordersCache[key]
                    ?.removeWhere((order) => order.id == updatedOrder.id);
              }
            }
            // 添加到新的状态近期缓存中（如果不存在则先初始化）
            _ordersCache[newRecentKey] ??= <OrderBean>[];
            // 比较日期，在插入 eg 2025年04月17日 23:27
            // 时，确保新插入的订单在列表的最前面
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
          }
        }

        EventBusHelper.eventBus.fire(OrderInfoUpdateEvent(updatedOrder));

        notifyListeners();
      });
    });
  }
}
