import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rubbish_detection/pages/recycle_page/address_card.dart';
import 'package:rubbish_detection/pages/recycle_page/recycle_vm.dart';
import 'package:rubbish_detection/pages/recycle_page/waste_card.dart';
import 'package:rubbish_detection/repository/data/order_bean.dart';
import 'package:rubbish_detection/utils/custom_helper.dart';
import 'package:rubbish_detection/utils/event_bus_helper.dart';

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({
    super.key,
    required this.order,
  });

  final OrderBean order;

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  late StreamSubscription<OrderInfoUpdateEvent> _eventBusSubscription;

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
  void initState() {
    _eventBusSubscription =
        EventBusHelper.eventBus.on<OrderInfoUpdateEvent>().listen((event) {
      setState(() {
        widget.order.copyWith(event.order!);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _eventBusSubscription.cancel();
    super.dispose();
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
          icon: const Icon(Icons.arrow_back_ios),
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
      bottomNavigationBar: _buildBottomBar(),
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
              fontWeight: FontWeight.w600,
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
              value: widget.order.actualPrice == null
                  ? "未知"
                  : "${widget.order.actualPrice?.toStringAsFixed(2)} 元"),
          _buildDivider(),
          _buildInfoRow(
              label: "评价分数",
              value: widget.order.reviewRate == null
                  ? "无"
                  : "${widget.order.reviewRate}分"),
          _buildDivider(),
          _buildInfoRow(
            label: "评价留言",
            value: widget.order.reviewMessage ?? "无",
          ),
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

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 2.r,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(16.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _cancelOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
                elevation: 0,
              ),
              child: Text(
                "取消订单",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _reviewOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00CE68),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
                elevation: 0,
              ),
              child: Text(
                "评价订单",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1.h, color: Colors.grey[200]);
  }

  void _cancelOrder() async {
    if (widget.order.orderStatus == 2) {
      CustomHelper.showSnackBar(context, "订单已完成，无法取消", success: false);
      return;
    }

    if (widget.order.orderStatus == 1) {
      CustomHelper.showSnackBar(context, "订单处理中，无法取消", success: false);
      return;
    }

    if (widget.order.orderStatus == 3) {
      CustomHelper.showSnackBar(context, "订单已取消", success: false);
      return;
    }

    final shouldCancel = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("确认取消订单"),
        content: const Text("您确定要取消此订单吗？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("确认"),
          ),
        ],
      ),
    );

    if (shouldCancel != true) {
      return;
    }

    if (!mounted) return;
    await CustomHelper.executeAsyncCall(
      context: context,
      futureCall: Provider.of<RecycleViewModel>(context, listen: false)
          .cancelOrder(
              userId: widget.order.userId ?? -1,
              orderId: widget.order.id ?? -1),
      successMessage: "订单取消成功",
      onSuccess: (result) {
        setState(() {
          widget.order.orderStatus = 3;
        });
      },
      failurePrefix: "订单取消失败",
    );
  }

  void _reviewOrder() async {
    if (widget.order.orderStatus != 2) {
      CustomHelper.showSnackBar(context, "订单未完成，无法评价", success: false);
      return;
    }

    if (widget.order.reviewRate != null) {
      CustomHelper.showSnackBar(context, "订单已评价", defaultStyle: true);
      return;
    }

    int reviewRate = 0;
    String reviewMessage = "";
    final formKey = GlobalKey<FormState>();
    final shouldSubmit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF7F7F7),
          title: Text(
            "评价订单",
            style: TextStyle(color: const Color(0xFF00CE68), fontSize: 20.sp),
          ),
          content: Form(
            key: formKey,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            index < reviewRate ? Icons.star : Icons.star_border,
                            color: index < reviewRate
                                ? const Color(0xFFFFC107)
                                : Colors.grey,
                            size: 32.r,
                          ),
                          onPressed: () {
                            setState(() {
                              reviewRate = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    SizedBox(height: 16.h),
                    // Review message input with validator
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "留言",
                        labelStyle: TextStyle(
                            color: const Color(0xFF00CE68), fontSize: 16.sp),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF00CE68)),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Color(0xFF00CE68)),
                            borderRadius: BorderRadius.circular(8.r)),
                      ),
                      onChanged: (value) {
                        reviewMessage = value;
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "留言至少需要一个字符";
                        }
                        return null;
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "取消",
                style: TextStyle(color: Colors.grey, fontSize: 16.sp),
              ),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (reviewRate == 0) {
                    // Although rating is initialized to 5, extra check if needed
                    CustomHelper.showSnackBar(
                      context,
                      "评分不能为0分",
                      success: false,
                    );
                    return;
                  }
                  Navigator.of(context).pop(true);
                }
              },
              child: Text(
                "提交",
                style:
                    TextStyle(color: const Color(0xFF00CE68), fontSize: 16.sp),
              ),
            ),
          ],
        );
      },
    );

    if (shouldSubmit != true) {
      return;
    }

    if (!mounted) return;
    await CustomHelper.executeAsyncCall(
      context: context,
      futureCall: Provider.of<RecycleViewModel>(context, listen: false)
          .submitReview(
              userId: widget.order.userId ?? -1,
              orderId: widget.order.id ?? -1,
              reviewRate: reviewRate,
              reviewMessage: reviewMessage),
      successMessage: "订单评价成功",
      onSuccess: (result) {
        setState(() {
          widget.order.reviewRate = reviewRate;
          widget.order.reviewMessage = reviewMessage;
        });
      },
      failurePrefix: "订单评价失败",
    );
  }
}
