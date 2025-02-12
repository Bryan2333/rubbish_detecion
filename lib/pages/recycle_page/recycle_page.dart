import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:rubbish_detection/pages/auth_page/auth_vm.dart';
import 'package:rubbish_detection/pages/recycle_page/order_form_page.dart';
import 'package:rubbish_detection/pages/recycle_page/order_list_page.dart';
import 'package:rubbish_detection/pages/recycle_page/order_status_page.dart';
import 'package:rubbish_detection/pages/recycle_page/recycle_vm.dart';
import 'package:rubbish_detection/repository/data/order_bean.dart';
import 'package:rubbish_detection/utils/route_helper.dart';

class RecyclingPage extends StatefulWidget {
  const RecyclingPage({super.key});

  @override
  State<RecyclingPage> createState() => _RecyclingPageState();
}

class _RecyclingPageState extends State<RecyclingPage> {
  late RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    _initRecentOrders();
  }

  Future<void> _initRecentOrders({bool forceRefresh = false}) async {
    final userId =
        await Provider.of<AuthViewModel>(context, listen: false).getUserId();

    if (!mounted) return;
    Provider.of<RecycleViewModel>(context, listen: false)
        .getRecentOrders(userId, forceRefresh: forceRefresh);
  }

  final _wasteTypeMap = {
    0: "干垃圾",
    1: "湿垃圾",
    2: "可回收物",
    3: "有害垃圾",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Consumer<RecycleViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00CE68)),
              );
            } else {
              final pendingOrders = vm.currentOrders
                  .where((order) => order.orderStatus == 0)
                  .toList();
              final processingOrders = vm.currentOrders
                  .where((order) => order.orderStatus == 1)
                  .toList();
              final completedOrders = vm.currentOrders
                  .where((order) => order.orderStatus == 2)
                  .toList();

              return SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                onRefresh: () async {
                  await _initRecentOrders(forceRefresh: true);
                  _refreshController.refreshCompleted();
                },
                header: const WaterDropMaterialHeader(
                  backgroundColor: Colors.white,
                  color: Color(0xFF00CE68),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.r),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 服务中订单卡片
                        _buildGroupCard(
                          title: "待处理订单",
                          icon: Icons.pending_actions_outlined,
                          orders: pendingOrders,
                          orderStatus: 0,
                        ),
                        SizedBox(height: 24.h),
                        // 服务中订单卡片
                        _buildGroupCard(
                          title: "服务中订单",
                          icon: Icons.recycling_outlined,
                          orders: processingOrders,
                          orderStatus: 1,
                        ),
                        SizedBox(height: 24.h),
                        // 已完成订单卡片
                        _buildGroupCard(
                          title: "已完成订单",
                          icon: Icons.check_circle_outline,
                          orders: completedOrders,
                          orderStatus: 2,
                        ),
                        SizedBox(height: 24.h),
                        // 所有订单卡片
                        _buildGroupCard(
                          title: "全部订单",
                          icon: Icons.list_alt,
                          orders: vm.currentOrders,
                        ),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "垃圾上门回收",
        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.add_outlined, size: 30.r),
          onPressed: () => RouteHelper.push(context, const OrderFormPage()),
        )
      ],
    );
  }

  // 订单卡片
  Widget _buildGroupCard(
      {required String title,
      required IconData icon,
      required List<OrderBean> orders,
      int? orderStatus}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 标题栏
          GestureDetector(
            onTap: () => RouteHelper.push(context,
                    OrderListPage(title: title, orderStatus: orderStatus))
                .then((_) => _initRecentOrders()),
            child: Container(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 24.r,
                    color: const Color(0xFF00CE68),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    title,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20.r,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
          // 分隔线
          Divider(height: 1.h, color: Colors.grey[100]),
          _buildPreviewHeader(),
          if (orders.isEmpty)
            _buildEmptyState()
          else
            ...orders.asMap().entries.map((entry) {
              final index = entry.key;
              final order = entry.value;
              final isLast = index == orders.length - 1;

              return _buildOrderPreviewItem(order, showBorder: !isLast);
            })
        ],
      ),
    );
  }

  // 空状态提示
  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48.r,
            color: Colors.grey[400],
          ),
          SizedBox(height: 12.h),
          Text(
            "暂时没有相关订单",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // 预览说明
  Widget _buildPreviewHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!, width: 1.h),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 16.r, color: Colors.grey[600]),
          SizedBox(width: 8.w),
          Text(
            "最近一周的订单",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // 订单预览项
  Widget _buildOrderPreviewItem(OrderBean order, {bool showBorder = true}) {
    return GestureDetector(
      onTap: () => RouteHelper.push(context, OrderStatusPage(order: order)),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          border: showBorder
              ? Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1.h),
                )
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                // 左侧订单信息
                Text(
                  order.orderDate ?? "",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                const Spacer(),
                // 右侧状态
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getOrderStatusBgColor(order.orderStatus ?? -1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    _getOrderStatusText(order.orderStatus ?? -1),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: _getOrderStatusColor(order.orderStatus ?? -1),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // 废弃物信息
            _buildInfoRow(
              Icons.delete_outline,
              "${_wasteTypeMap[order.waste?.type]} - ${order.waste?.name}",
              weight:
                  "${order.waste?.weight} ${order.waste?.unit == 1 ? "千克" : "克"}",
            ),
            SizedBox(height: 8.h),
            // 地址信息
            _buildInfoRow(
              Icons.location_on_outlined,
              order.address?.detail ?? "",
            ),
          ],
        ),
      ),
    );
  }

  // 信息行组件
  Widget _buildInfoRow(IconData icon, String text, {String? weight}) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: Colors.grey[600]),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[700],
          ),
        ),
        const Spacer(),
        if (weight != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(3.r),
            ),
            child: Text(
              weight,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }

  Color _getOrderStatusBgColor(int status) {
    return switch (status) {
      0 => const Color(0xFFFFF3E0),
      1 => const Color(0xFFE8F5E9),
      2 => const Color(0xFFE3F2FD),
      _ => Colors.grey[100]!
    };
  }

  String _getOrderStatusText(int status) {
    return switch (status) {
      0 => "待处理",
      1 => "处理中",
      2 => "已完成",
      3 => "已取消",
      _ => "未知状态",
    };
  }

  Color _getOrderStatusColor(int status) {
    return switch (status) {
      0 => Colors.orange,
      1 => const Color(0xFF00CE68),
      2 => Colors.blue,
      _ => Colors.grey,
    };
  }
}
