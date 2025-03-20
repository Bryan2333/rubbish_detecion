import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rubbish_detection/pages/auth_page/auth_vm.dart';
import 'package:rubbish_detection/pages/recycle_page/address_card.dart';
import 'package:rubbish_detection/pages/recycle_page/order_status_page.dart';
import 'package:rubbish_detection/pages/recycle_page/recycle_vm.dart';
import 'package:rubbish_detection/pages/recycle_page/waste_card.dart';
import 'package:rubbish_detection/repository/data/order_address_bean.dart';
import 'package:rubbish_detection/repository/data/order_bean.dart';
import 'package:rubbish_detection/repository/data/order_waste_bean.dart';
import 'package:rubbish_detection/utils/custom_helper.dart';
import 'package:rubbish_detection/utils/route_helper.dart';

class OrderFormPage extends StatefulWidget {
  const OrderFormPage({super.key});

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _order =
      OrderBean(address: OrderAddressBean(), waste: OrderWasteBean());

  final _wasteFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();

  final _localPhotoPaths = <String>[];

  late ValueNotifier<double> _totalPrice;

  @override
  void initState() {
    super.initState();
    _totalPrice = ValueNotifier<double>(0);
  }

  @override
  void dispose() {
    _totalPrice.dispose();
    super.dispose();
  }

  // 计算预估价格
  void _calEstimatedPrice() {
    final weightInKg = (_order.waste?.unit == 0)
        ? (_order.waste?.weight ?? 0) / 1000
        : _order.waste?.weight ?? 0;

    const pricingRules = {
      0: [0.2, 0.3, 0.4], // 干垃圾
      1: [0.4, 0.6, 0.8], // 湿垃圾
      2: [1.5, 2.0, 2.5], // 可回收物
      3: [5.0, 6.0, 7.0], // 有害垃圾
    };

    final prices = pricingRules[_order.waste?.type];
    if (prices != null && weightInKg > 0) {
      if (weightInKg <= 20) {
        _order.estimatedPrice = weightInKg * prices[0];
      } else if (weightInKg <= 50) {
        _order.estimatedPrice = weightInKg * prices[1];
      } else {
        _order.estimatedPrice = weightInKg * prices[2];
      }
    } else {
      _order.estimatedPrice = 0;
    }

    _totalPrice.value = _order.estimatedPrice ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildInfoBar(),
            _buildFormSection(),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
      title: Text(
        "创建新订单",
        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
    );
  }

  Widget _buildInfoBar() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("带有", style: TextStyle(color: Colors.grey[600])),
          const Text(" * ", style: TextStyle(color: Colors.red)),
          Text("为必填项", style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // AddressCard
            SliverToBoxAdapter(
              child: AddressCard(
                formKey: _addressFormKey,
                address: _order.address,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 16.h)),
            // WasteBags List
            SliverToBoxAdapter(
              child: WasteCard(
                formKey: _wasteFormKey,
                waste: _order.waste,
                onCalEstimatedPrice: _calEstimatedPrice,
                localPhotoPaths: _localPhotoPaths,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 16.h)),
          ],
        ),
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
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "预估回收价",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      "¥ ",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF00CE68),
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: _totalPrice,
                      builder: (context, price, child) {
                        return Text(
                          price.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00CE68),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _submitOrder,
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
                "立即预约",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitOrder() async {
    final isAddressValid = _addressFormKey.currentState?.validate() ?? false;
    final isWasteValid = _wasteFormKey.currentState?.validate() ?? false;

    if (!isAddressValid || !isWasteValid) return;

    CustomHelper.showSnackBar(context, "正在创建订单，请稍后...",
        defaultStyle: true, duration: const Duration(seconds: 10));

    _order.orderStatus = 0;
    _order.orderDate = DateTime.now().toIso8601String();
    for (final bean in _localPhotoPaths) {
      bean.imagePath =
          "data:image/jpeg;base64,${base64Encode(File(bean.imagePath!).readAsBytesSync())}";
    }
    _order.waste?.photos = _localPhotoPaths;
    _order.userId =
        await Provider.of<AuthViewModel>(context, listen: false).getUserId();

    if (!mounted) return;
    await CustomHelper.executeAsyncCall(
      context: context,
      futureCall: Provider.of<RecycleViewModel>(context, listen: false)
          .createOrder(_order),
      successMessage: "订单创建成功",
      onSuccess: (result) {
        RouteHelper.pushReplacement(
            context, OrderStatusPage(order: (result?.$1)!));
      },
      failurePrefix: "订单创建失败",
      successCondition: (result) => result?.$2 == null,
    );
  }
}
