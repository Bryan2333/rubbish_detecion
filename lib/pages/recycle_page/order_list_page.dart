import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rubbish_detection/pages/recycle_page/order_status_page.dart';
import 'package:rubbish_detection/pages/recycle_page/recycle_page.dart';
import 'package:rubbish_detection/pages/recycle_page/recycle_vm.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key, required this.title, this.orderStatus});

  final String title;
  final int? orderStatus;

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final _recycleViewModel = RecycleViewModel();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    await _recycleViewModel.getOrdersByStatus(widget.orderStatus);
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
    return ChangeNotifierProvider(
      create: (_) => _recycleViewModel,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Consumer<RecycleViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00CE68)),
              );
            } else if (vm.orders.isEmpty && !vm.isLoading) {
              return _buildEmptyState();
            } else {
              return SafeArea(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vm.orders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(vm.orders[index]);
                      },
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
      centerTitle: true,
      title: Text(
        widget.title,
        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios),
      ),
    );
  }

  /// 构建当订单列表为空时的显示内容
  Widget _buildEmptyState() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64.r, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            "暂时没有相关订单",
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
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
          onTap: () {
            // TODO: 处理订单点击事件，例如导航到订单详情页
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderStatusPage(order: order),
              ),
            );
          },
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
                        order.waste.name ?? "未知垃圾",
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
                  value: "${order.waste.weight} ${order.waste.unit}",
                ),
                SizedBox(height: 8.h),
                // 订单地址
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  value:
                      "${order.address.province} ${order.address.city} ${order.address.area} ${order.address.detail}",
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
        Icon(icon, color: Colors.grey[600], size: 16.r),
        SizedBox(width: 8.w),
        Text(
          value,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
