import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:rubbish_detection/pages/recycle_page/address_card.dart';
import 'package:rubbish_detection/pages/recycle_page/recycle_page.dart';
import 'package:rubbish_detection/pages/recycle_page/waste_bag_card.dart';

class RecycleViewModel with ChangeNotifier {
  final orders = <Order>[];
  bool isLoading = false;

  Future<void> getRecentOrders() async {
    try {
      isLoading = true;
      orders.clear();
      await Future.delayed(const Duration(milliseconds: 300));
      orders.addAll(_mockOrders);
    } catch (e) {
      log("Error fetching recent orders: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  final _mockOrders = [
    Order(
      id: 1,
      address: Address(
        name: '张三',
        phoneNum: '13800138000',
        province: '北京市',
        city: '北京市',
        area: '朝阳区',
        detail: '建国路88号',
        datetime: '2024-12-25 10:00',
      ),
      waste: Waste(
        id: 101,
        type: '可回收物',
        name: '纸张',
        weight: '5',
        unit: '公斤',
        description: '废旧报纸和杂志',
        photos: [
          'https://example.com/photos/paper1.jpg',
          'https://example.com/photos/paper2.jpg',
        ],
        estimatedPrice: 10.5,
      ),
      orderDate: '2024-12-25',
      orderStatus: 3,
    ),
    Order(
      id: 2,
      address: Address(
        name: '李四',
        phoneNum: '13900139000',
        province: '上海市',
        city: '上海市',
        area: '浦东新区',
        detail: '世纪大道100号',
        datetime: '2024-12-26 14:30',
      ),
      waste: Waste(
        id: 201,
        type: '湿垃圾',
        name: '剩菜剩饭',
        weight: '3',
        unit: '公斤',
        description: '家庭剩余食物',
        photos: [
          'https://example.com/photos/food1.jpg',
          'https://example.com/photos/food2.jpg',
        ],
        estimatedPrice: 0.0,
      ),
      orderDate: '2024-12-26',
      orderStatus: 3,
    ),
  ];
}
