import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/pages/recycle_page/address_card.dart';
import 'package:rubbish_detection/pages/recycle_page/waste_bag_card.dart';

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({
    super.key,
    required this.wasteBags,
    required this.totalPrice,
    required this.address,
  });

  final List<WasteBag> wasteBags;
  final Address address;
  final double totalPrice;

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  final List<Map<String, dynamic>> _orderStatus = [
    {
      'status': '订单已提交',
      'time': '2024-12-25 05:30:27',
      'icon': Icons.check_circle,
      'isCompleted': true,
    },
    {
      'status': '等待回收员接单',
      'time': '--:--',
      'icon': Icons.person_search,
      'isCompleted': false,
    },
    {
      'status': '回收员已接单',
      'time': '--:--',
      'icon': Icons.person_outline,
      'isCompleted': false,
    },
    {
      'status': '正在上门回收',
      'time': '--:--',
      'icon': Icons.local_shipping_outlined,
      'isCompleted': false,
    },
    {
      'status': '回收完成',
      'time': '--:--',
      'icon': Icons.task_alt,
      'isCompleted': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "订单状态",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.r, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 订单状态卡片
          _buildStatusCard(),
          // 订单详情
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 订单信息概览
                SliverToBoxAdapter(
                  child: _buildOrderOverview(),
                ),
                // 地址信息
                SliverToBoxAdapter(
                  child: AddressCard(
                    address: widget.address,
                    isReadOnly: true,
                  ),
                ),
                // 废品袋列表
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final bag = widget.wasteBags[index];
                      return WasteBagCard(
                        bag: bag,
                        isReadOnly: true,
                      );
                    },
                    childCount: widget.wasteBags.length,
                  ),
                ),
                // 底部间距
                SliverPadding(padding: EdgeInsets.only(bottom: 16.h)),
              ],
            ),
          ),
        ],
      ),
      // 底部联系按钮
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(16.r),
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
      child: Column(
        children: List.generate(_orderStatus.length, (index) {
          final status = _orderStatus[index];
          final isLast = index == _orderStatus.length - 1;

          return Row(
            children: [
              // 状态图标和连接线
              Column(
                children: [
                  Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      color: status['isCompleted']
                          ? const Color(0xFF00CE68)
                          : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      status['icon'],
                      color: Colors.white,
                      size: 20.r,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 32.h,
                      color: status['isCompleted']
                          ? const Color(0xFF00CE68)
                          : Colors.grey[300],
                    ),
                ],
              ),
              SizedBox(width: 12.w),
              // 状态文字和时间
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status['status'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: status['isCompleted']
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: status['isCompleted']
                            ? Colors.black87
                            : Colors.grey[600],
                      ),
                    ),
                    if (status['time'] != '--:--') ...[
                      SizedBox(height: 4.h),
                      Text(
                        status['time'],
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (!isLast) SizedBox(height: 16.h),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOrderOverview() {
    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(16.r),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "订单信息",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00CE68).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  "待接单",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF00CE68),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInfoRow("订单编号", "2024122505302700001"),
          _buildInfoRow("创建时间", "2024-12-25 05:30:27"),
          _buildInfoRow("预估金额", "¥${widget.totalPrice.toStringAsFixed(2)}"),
          _buildInfoRow("废品袋数量", "${widget.wasteBags.length}个"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: 实现客服联系功能
                },
                icon: const Icon(Icons.headset_mic_outlined),
                label: const Text("联系客服"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00CE68),
                  side: const BorderSide(color: Color(0xFF00CE68)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: 实现回收员联系功能
                },
                icon: const Icon(Icons.phone_outlined),
                label: const Text("联系回收员"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00CE68),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class OrderStatusPage extends StatefulWidget {
//   const OrderStatusPage(
//       {super.key,
//       required this.wasteBags,
//       required this.totalPrice,
//       required this.address});

//   final List<WasteBag> wasteBags;
//   final Address address;
//   final double totalPrice;

//   @override
//   State<OrderStatusPage> createState() => _OrderStatusPageState();
// }

// class _OrderStatusPageState extends State<OrderStatusPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Container(
//           color: Colors.white,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 margin: EdgeInsets.only(left: 16.w, top: 20.h),
//                 child: Text(
//                   "订单提交成功",
//                   style: TextStyle(fontSize: 24.sp),
//                 ),
//               ),
//               Expanded(
//                 child: CustomScrollView(
//                   slivers: [
//                     // AddressCard
//                     SliverToBoxAdapter(
//                       child: AddressCard(
//                         address: widget.address,
                        
//                         isReadOnly: true,
//                       ),
//                     ),
//                     // WasteBagCards List
//                     SliverList(
//                       delegate: SliverChildBuilderDelegate(
//                         (context, index) {
//                           final bag = widget.wasteBags[index];
//                           return WasteBagCard(
//                             bag: bag,
//                             isReadOnly: true,
//                           );
//                         },
//                         childCount: widget.wasteBags.length,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
