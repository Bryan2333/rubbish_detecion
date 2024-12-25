import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rubbish_detection/pages/recycle_page/address_card.dart';
import 'package:rubbish_detection/pages/recycle_page/order_status_page.dart';
import 'package:rubbish_detection/pages/recycle_page/waste_bag_card.dart';

class OrderFormPage extends StatefulWidget {
  const OrderFormPage({super.key});

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _wasteBags = [WasteBag(id: 1)];
  double _totalPrice = 0.0;
  late Address _address;

  // 添加新废品袋
  void _addWasteBag() {
    setState(() {
      _wasteBags.add(WasteBag(id: _wasteBags.length + 1));
    });
  }

  // 计算总价
  void _calculateTotal() {
    setState(() {
      _totalPrice =
          _wasteBags.fold(0.0, (sum, bag) => sum + (bag.estimatedPrice ?? 0));
    });
  }

  void _removeWasteBag(int id) {
    setState(() {
      _wasteBags.removeWhere((bag) => id == bag.id);
    });
  }

  void _updateAddress(Map<String, String?> json) {
    _address = Address.fromJson(json);
  }

  Future<ImageSource?> _showPickerDialog(BuildContext context) async {
    ImageSource? source;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择图片'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.of(context).pop();
                  source = ImageSource.camera;
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () {
                  Navigator.of(context).pop();
                  source = ImageSource.gallery;
                },
              ),
            ],
          ),
        );
      },
    );

    return source;
  }

  // 选择照片
  Future<void> _pickImage(int bagId) async {
    final imageSource = await _showPickerDialog(context);
    if (imageSource == null) {
      return;
    }

    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: imageSource);

    if (pickedImage == null) {
      return;
    }
    setState(() {
      _wasteBags
          .firstWhere((bag) => bag.id == bagId)
          .photos
          .add(pickedImage.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // AddressCard
                SliverToBoxAdapter(
                  child: AddressCard(
                    isReadOnly: false,
                    onAddressUpdate: _updateAddress,
                  ),
                ),
                // WasteBags List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final bag = _wasteBags[index];
                      return WasteBagCard(
                        bag: bag,
                        isReadOnly: false,
                        onCalculateTotal: _calculateTotal,
                        onPickImage: _pickImage,
                        removeWasteBag: _removeWasteBag,
                      );
                    },
                    childCount: _wasteBags.length,
                  ),
                ),
                // 底部间距
                SliverPadding(padding: EdgeInsets.only(bottom: 100.h)),
              ],
            ),
          ),
          // 底部操作栏
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 总价和预约按钮
                  Padding(
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
                                  "¥",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF00CE68),
                                  ),
                                ),
                                Text(
                                  _totalPrice.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF00CE68),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderStatusPage(
                                  wasteBags: _wasteBags,
                                  totalPrice: _totalPrice,
                                  address: _address,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00CE68),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 32.w,
                              vertical: 12.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "立即预约",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 添加废品袋按钮
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(16.r),
                    child: ElevatedButton.icon(
                      onPressed: _addWasteBag,
                      icon: const Icon(Icons.add_circle_outline),
                      label: Text(
                        "添加废品袋",
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF00CE68),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                          side: const BorderSide(
                            color: Color(0xFF00CE68),
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
