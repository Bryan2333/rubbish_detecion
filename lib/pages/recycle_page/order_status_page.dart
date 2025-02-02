import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/pages/recycle_page/address_card.dart';
import 'package:rubbish_detection/pages/recycle_page/recycle_page.dart';
import 'package:rubbish_detection/pages/recycle_page/waste_card.dart';

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({
    super.key,
    required this.order,
  });

  final Order order;

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
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
      appBar: AppBar(
        title: Text(
          "订单详情",
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.r),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 订单信息概览
              _buildOrderOverview(),
              SizedBox(height: 16.h),
              // 地址信息
              AddressCard(address: widget.order.address, isReadOnly: true),
              SizedBox(height: 16.h),
              // 废品信息
              WasteCard(waste: widget.order.waste, isReadOnly: true),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderOverview() {
    return Column(
      children: [_buildOverviewHeader(), _buildOverviewContent()],
    );
  }

  Widget _buildOverviewHeader() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFF00CE68).withValues(alpha: 0.15),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: const Color(0xFF00CE68),
            size: 24.r,
          ),
          SizedBox(width: 8.w),
          Text(
            "订单信息",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00CE68),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            offset: const Offset(0, 1),
            blurRadius: 2.r,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            label: "处理状态",
            customWidget: true,
            widget: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _getOrderStatusBgColor(widget.order.orderStatus),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                _getStatusText(widget.order.orderStatus),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: _getStatusColor(widget.order.orderStatus),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          _buildDivider(),
          _buildInfoRow(label: "订单编号", value: "${widget.order.id}"),
          _buildDivider(),
          _buildInfoRow(label: "创建时间", value: "${widget.order.orderDate}"),
          _buildDivider(),
          _buildInfoRow(
              label: "预估金额",
              value: "${widget.order.estimatedPrice?.toStringAsFixed(2)} 元"),
          _buildDivider(),
          _buildInfoRow(
              label: "实际金额",
              value: (widget.order.actualPrice == null)
                  ? "未知"
                  : "${widget.order.actualPrice?.toStringAsFixed(2)} 元"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      {required String label,
      String? value,
      bool customWidget = false,
      Widget? widget}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          if (customWidget)
            widget!
          else
            Text(
              value!,
              style: TextStyle(fontSize: 16.sp),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1.h, color: Colors.grey[200]);
  }
}
