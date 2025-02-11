import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rubbish_detection/http/dio_instance.dart';
import 'package:rubbish_detection/repository/api.dart';
import 'package:rubbish_detection/repository/data/order_bean.dart';

class RecycleViewModel with ChangeNotifier {
  // 缓存不同筛选条件下的订单数据，key 根据订单状态生成
  final _ordersCache = <int, List<OrderBean>>{};

  // 记录每个筛选条件下当前加载到的页码
  final _pageTracker = <int, int>{};

  // 当前显示的订单列表（从 _ordersCache 中取出）
  var currentOrders = <OrderBean>[];

  // 记录每个筛选条件下是否还有更多数据
  final _hasMore = <int, bool>{};

  var isLoading = false;

  bool hasMore(int? orderStatus) {
    return _hasMore[_cacheKey(orderStatus)] ?? false;
  }

  /// 根据传入的订单状态生成缓存 key
  int _cacheKey(int? orderStatus, {bool isRecent = false}) {
    if (isRecent) return 100; // 最近订单的 key
    if (orderStatus == null) return 200; // 所有订单的 key
    return orderStatus;
  }

  Future<(OrderBean?, String?)> createOrder(OrderBean order) async {
    final (orderFromRes, message) = await Api.instance.addOrder(order);

    _fixOrderData(orderFromRes!);

    return (orderFromRes, message);
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
      currentOrders = _ordersCache[key]!;
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

      List<OrderBean>? fetchedOrders;
      if (orderStatus == null) {
        fetchedOrders = await Api.instance.getOrderByPage(
          userId,
          pageNum: pageNum,
          pageSize: pageSize,
        );
      } else {
        fetchedOrders = await Api.instance.getOrderByStatusWithPage(
          userId,
          orderStatus,
          pageNum: pageNum,
          pageSize: pageSize,
        );
      }
      fetchedOrders ??= [];

      fetchedOrders.forEach(_fixOrderData);

      if (!loadMore || forceRefresh) {
        _ordersCache[key] = fetchedOrders;
      } else {
        _ordersCache[key] = (_ordersCache[key] ?? []) + fetchedOrders;
      }
      currentOrders = _ordersCache[key]!;

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
    const key = 100;
    if (!forceRefresh && _ordersCache.containsKey(key)) {
      currentOrders = _ordersCache[key]!;
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      final fetchedOrders = await Api.instance.getRecentOrder(userId) ?? [];
      fetchedOrders.forEach(_fixOrderData);

      _ordersCache[key] = fetchedOrders;
      currentOrders = fetchedOrders;
    } catch (e) {
      log("Error fetching recent orders: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _fixOrderData(OrderBean order) {
    final dateFormatter = DateFormat("yyyy年MM月dd日 HH:mm");
    order.waste?.photos = order.waste?.photos
        ?.map((photo) =>
            photo.isEmpty ? "" : DioInstance.instance.baseURL + photo)
        .toList();
    order.orderDate =
        dateFormatter.format(DateTime.parse(order.orderDate ?? ""));
  }
}
