import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:rubbish_detection/pages/auth_page/auth_vm.dart';
import 'package:rubbish_detection/pages/recycle_page/order_status_page.dart';
import 'package:rubbish_detection/pages/recycle_page/recycle_vm.dart';
import 'package:rubbish_detection/repository/data/order_bean.dart';
import 'package:rubbish_detection/utils/custom_helper.dart';
import 'package:rubbish_detection/utils/route_helper.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key, required this.title, this.orderStatus});

  final String title;
  final int? orderStatus;

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  late RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    _loadOrRefresh();
  }

  Future<void> _loadOrRefresh(
      {bool forceRefresh = false, bool loadMore = false}) async {
    final userId =
        await Provider.of<AuthViewModel>(context, listen: false).getUserId();

    if (!mounted) return;
    Provider.of<RecycleViewModel>(context, listen: false).getOrdersByStatus(
        userId, widget.orderStatus,
        forceRefresh: forceRefresh, loadMore: loadMore);
  }

  String _getStatusText(int? status) {
    return switch (status) {
      0 => "待处理",
      1 => "处理中",
      2 => "已完成",
      3 => "已取消",
      _ => "未知状态",
    };
  }

  Color _getStatusColor(int? status) {
    return switch (status) {
      0 => Colors.orange,
      1 => const Color(0xFF00CE68),
      2 => Colors.blue,
      _ => Colors.grey,
    };
  }

  Color _getOrderStatusBgColor(int? status) {
    return switch (status) {
      0 => const Color(0xFFFFF3E0),
      1 => const Color(0xFFE8F5E9),
      2 => const Color(0xFFE3F2FD),
      _ => Colors.grey[100]!
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<RecycleViewModel>(
        builder: (context, vm, child) {
          final orders = vm.ordersByStatus(widget.orderStatus);
          return SafeArea(
            child: SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: true,
              onRefresh: () async {
                await _loadOrRefresh(forceRefresh: true);
                _refreshController.refreshCompleted();
              },
              onLoading: () async {
                if (!vm.hasMore(widget.orderStatus)) {
                  CustomHelper.showSnackBar(context, "没有更多数据了", defaultStyle: true);
                } else {
                  await _loadOrRefresh(loadMore: true);
                }
                _refreshController.loadComplete();
              },
              header: const WaterDropMaterialHeader(
                backgroundColor: Colors.white,
                color: Color(0xFF00CE68),
              ),
              child: (vm.isLoading && !vm.hasMore(widget.orderStatus))
                  ? CustomHelper.progressIndicator
                  : orders.isEmpty
                      ? _buildEmptyState()
                      : _buildOrderList(orders),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        widget.title,
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      alignment: Alignment.center,
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
            "暂时没有相关订单",
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<OrderBean> orders) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SingleChildScrollView(
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return _buildOrderCard(orders[index]);
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderBean order) {
    final statusText = _getStatusText(order.orderStatus);
    final statusColor = _getStatusColor(order.orderStatus);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 5.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => RouteHelper.push(context, OrderStatusPage(order: order)),
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                // 订单标题和状态
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
                        order.waste?.name ?? "未知垃圾",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _getOrderStatusBgColor(order.orderStatus),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // 订单时间
                _buildInfoRow(
                  icon: Icons.access_time,
                  value: order.orderDate ?? "",
                ),
                SizedBox(height: 8.h),
                // 重量
                _buildInfoRow(
                  icon: Icons.monitor_weight_outlined,
                  value:
                      "${order.waste?.weight} ${order.waste?.unit == 1 ? "千克" : "克"}",
                ),
                SizedBox(height: 8.h),
                // 订单地址
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  value:
                      "${order.address?.province}${order.address?.city}${order.address?.area}${order.address?.detail}",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String value}) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.grey[600],
          size: 16.r,
        ),
        SizedBox(width: 8.w),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
