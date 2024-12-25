import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/pages/recycle_page/order_form_page.dart';

class RecyclingPage extends StatefulWidget {
  const RecyclingPage({super.key});

  @override
  State<RecyclingPage> createState() => _RecyclingPageState();
}

class _RecyclingPageState extends State<RecyclingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab标签数据
  final List<Map<String, dynamic>> _tabs = [
    {
      'text': '创建订单',
      'icon': Icons.add_circle_outline,
      'count': 0,
    },
    {
      'text': '服务中',
      'icon': Icons.pending_actions,
      'count': 1,
    },
    {
      'text': '已完成',
      'icon': Icons.check_circle_outline,
      'count': 1,
    },
    {
      'text': '所有订单',
      'icon': Icons.list_alt,
      'count': 2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "垃圾上门回收",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20.r,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 自定义Tab栏
          Container(
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: 8.h),
                // Tab按钮组
                Container(
                  height: 72.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: ValueListenableBuilder<double>(
                    valueListenable: _tabController.animation!,
                    builder: (context, value, child) {
                      return Row(
                        children: List.generate(_tabs.length, (index) {
                          bool isSelected = _tabController.index == index;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _tabController.animateTo(index);

                                log(_tabController.index.toString());
                                log(index.toString());
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF00CE68).withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF00CE68)
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _tabs[index]['icon'],
                                          size: 20.r,
                                          color: isSelected
                                              ? const Color(0xFF00CE68)
                                              : Colors.grey[600],
                                        ),
                                        if (_tabs[index]['count'] > 0) ...[
                                          SizedBox(width: 4.w),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 4.w,
                                              vertical: 2.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xFF00CE68)
                                                  : Colors.grey[400],
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                            child: Text(
                                              '${_tabs[index]['count']}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      _tabs[index]['text'],
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF00CE68)
                                            : Colors.grey[600],
                                        fontSize: 12.sp,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
                SizedBox(height: 8.h),
                // 底部分割线
                Container(
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tab内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 创建订单页面
                const OrderFormPage(),
                // 服务中订单页面
                OrdersPage(
                  orderType: "服务中订单",
                  orders: sampleOngoingOrders,
                ),
                // 已完成订单页面
                OrdersPage(
                  orderType: "已完成订单",
                  orders: sampleCompletedOrders,
                ),
                // 所有订单页面
                OrdersPage(
                  orderType: "所有订单",
                  orders: allOrders,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// OrdersPage Widget的美化建议
class OrdersPage extends StatelessWidget {
  final String orderType;
  final List<Map<String, String>> orders;

  const OrdersPage({
    super.key,
    required this.orderType,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return orders.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildOrderCard(orders[index]);
            },
          );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64.r,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            "暂无订单",
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, String> order) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: 处理订单点击事件
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.recycling,
                      color: const Color(0xFF00CE68),
                      size: 24.r,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        order['title'] ?? '',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16.r,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.grey[600],
                      size: 16.r,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      order['time'] ?? '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey[600],
                      size: 16.r,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        order['address'] ?? '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 示例订单数据
final List<Map<String, String>> sampleOngoingOrders = [
  {
    "title": "废旧家具回收",
    "time": "2024-12-10 10:00",
    "address": "北京市朝阳区XX路XX号",
  },
];

final sampleCompletedOrders = [
  {
    "title": "电子垃圾回收",
    "time": "2024-12-08 14:00",
    "address": "北京市海淀区XX小区",
  },
];

final allOrders = [
  ...sampleOngoingOrders,
  ...sampleCompletedOrders,
];
