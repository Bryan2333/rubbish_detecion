import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/repository/data/smart_address_data.dart';
import 'package:rubbish_detection/widget/custom_address_picker.dart';
import 'package:rubbish_detection/widget/custom_time_picker.dart';

class Address {
  String? name;
  String? phoneNum;
  String? province;
  String? city;
  String? area;
  String? detail;
  String? datetime;

  Address(
      {this.name,
      this.phoneNum,
      this.province,
      this.city,
      this.area,
      this.detail,
      this.datetime});

  Address.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phoneNum = json['phoneNum'];
    province = json['province'];
    city = json['city'];
    area = json['area'];
    detail = json['detail'];
    datetime = json['datetime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['phoneNum'] = phoneNum;
    data['province'] = province;
    data['city'] = city;
    data['area'] = area;
    data['detail'] = detail;
    data['datetime'] = datetime;
    return data;
  }
}

class AddressCard extends StatefulWidget {
  const AddressCard({
    super.key,
    this.onAddressUpdate,
    this.address,
    required this.isReadOnly,
  });

  final Address? address;
  final Function(Map<String, String?>)? onAddressUpdate;
  final bool isReadOnly;

  @override
  State<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard>
    with SingleTickerProviderStateMixin {
  late TextEditingController _smartAddrController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _detailController;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late FocusNode _focusNode;

  String _selectedDateTime = "请选择上门时间";
  late String _selectedProvince;
  late String _selectedCity;
  late String _selectedArea;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _initializeFocusNode();
  }

  void _initializeControllers() {
    _smartAddrController = TextEditingController();
    _nameController = TextEditingController(text: widget.address?.name);
    _phoneController = TextEditingController(text: widget.address?.phoneNum);
    _detailController = TextEditingController(text: widget.address?.detail);
    _selectedProvince = widget.address?.province ?? "";
    _selectedCity = widget.address?.city ?? "";
    _selectedArea = widget.address?.area ?? "";
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    if (_isExpanded) _animationController.forward();
  }

  void _initializeFocusNode() {
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _passAddress();
      }
    });
  }

  void _passAddress() {
    if (widget.onAddressUpdate != null) {
      widget.onAddressUpdate!({
        "name": _nameController.text,
        "phoneNum": _phoneController.text,
        "province": _selectedProvince,
        "city": _selectedCity,
        "area": _selectedArea,
        "detail": _detailController.text,
        "datetime": _selectedDateTime
      });
    }
  }

  @override
  void dispose() {
    _smartAddrController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _detailController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.r),
      clipBehavior: Clip.antiAlias,
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
        children: [
          // 卡片头部
          _buildHeader(),
          // 内容区域
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                if (!widget.isReadOnly) _buildSmartAddressSection(),
                Container(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    children: [
                      _buildFormField(
                        icon: Icons.person_outline,
                        label: "姓名",
                        child: _buildNameField(),
                      ),
                      _buildDivider(),
                      _buildFormField(
                        icon: Icons.phone_outlined,
                        label: "手机号",
                        child: _buildPhoneField(),
                      ),
                      _buildDivider(),
                      _buildFormField(
                        icon: Icons.location_on_outlined,
                        label: "省市区",
                        child: _buildProvinceCityAreaField(),
                      ),
                      _buildDivider(),
                      _buildFormField(
                        icon: Icons.home_outlined,
                        label: "详细地址",
                        child: _buildDetailField(),
                      ),
                      _buildDivider(),
                      _buildFormField(
                        icon: Icons.access_time,
                        label: "上门时间",
                        child: _buildPickupTimeField(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
            if (_isExpanded) {
              _animationController.forward();
            } else {
              _animationController.reverse();
              _passAddress();
            }
          });
        },
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: const Color(0xFF00CE68).withOpacity(0.1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: const Color(0xFF00CE68),
                size: 24.r,
              ),
              SizedBox(width: 8.w),
              Text(
                "上门信息",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00CE68),
                ),
              ),
              const Spacer(),
              AnimatedRotation(
                duration: const Duration(milliseconds: 300),
                turns: _isExpanded ? 0.5 : 0,
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF00CE68),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmartAddressSection() {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              child: TextField(
                controller: _smartAddrController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "请粘贴或输入文本，点击“识别”自动识别姓名、手机和地址",
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14.sp,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 12.r, bottom: 12.r),
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _parseSmartAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00CE68),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 8.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "智能识别",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20.r,
            color: Colors.grey[600],
          ),
          SizedBox(width: 12.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Divider(
        height: 1,
        color: Colors.grey[200],
      ),
    );
  }

  void _showCustomPicker(BuildContext context, {required Widget picker}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4.h,
                width: 40.w,
                margin: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              picker,
            ],
          ),
        );
      },
    );
  }

  Widget _buildNameField() {
    return widget.isReadOnly
        ? Text(
            widget.address?.name ?? "",
            style: TextStyle(fontSize: 16.sp),
          )
        : _buildEditableTextField(
            controller: _nameController,
            hintText: "请输入姓名",
          );
  }

  Widget _buildPhoneField() {
    return widget.isReadOnly
        ? Text(
            widget.address?.phoneNum ?? "",
            style: TextStyle(fontSize: 16.sp),
          )
        : _buildEditableTextField(
            controller: _phoneController,
            hintText: "请输入手机号",
            keyboardType: TextInputType.phone,
          );
  }

  Widget _buildProvinceCityAreaField() {
    return widget.isReadOnly
        ? Text(
            "${widget.address?.province} ${widget.address?.city} ${widget.address?.area}",
            style: TextStyle(fontSize: 16.sp),
          )
        : Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "$_selectedProvince $_selectedCity $_selectedArea",
                    style: TextStyle(fontSize: 14.sp),
                    softWrap: true,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showCustomPicker(
                    context,
                    picker: CustomAddressPicker(
                      initialAddress: {
                        "province": _selectedProvince,
                        "city": _selectedCity,
                        "district": _selectedArea
                      },
                      onAddressSelected: (value) {
                        setState(() {
                          _selectedProvince = value["province"]!;
                          _selectedCity = value["city"]!;
                          _selectedArea = value["district"]!;
                        });
                      },
                    ),
                  );
                },
                child: const Icon(Icons.keyboard_arrow_down, size: 20),
              ),
            ],
          );
  }

  Widget _buildDetailField() {
    return widget.isReadOnly
        ? Text(
            widget.address?.detail ?? "",
            style: TextStyle(fontSize: 16.sp),
          )
        : _buildEditableTextField(
            controller: _detailController,
            hintText: "请输入详细地址",
          );
  }

  Widget _buildPickupTimeField() {
    return widget.isReadOnly
        ? Text(
            widget.address?.datetime ?? "",
            style: TextStyle(fontSize: 16.sp),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.h),
                child: Text(
                  _selectedDateTime,
                  style: TextStyle(fontSize: 15.sp),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showCustomPicker(
                    context,
                    picker: CustomTimePicker(
                      initialDateTime: _selectedDateTime,
                      onTimeSelected: (value) {
                        setState(() {
                          _selectedDateTime = value;
                        });
                      },
                    ),
                  );
                },
                child: const Icon(Icons.keyboard_arrow_down, size: 20),
              ),
            ],
          );
  }

  void _parseSmartAddress() async {
    final dio = Dio(BaseOptions(baseUrl: "https://aip.baidubce.com"));

    final tokenRes = await dio.post(
        "/oauth/2.0/token?client_id=zG70jVwPrYEgKIlAuSnZR1cl&client_secret=adRGFNfW4kjIIffnIAht017DKARLJ07E&grant_type=client_credentials");

    final token = tokenRes.data["access_token"].toString();

    final smartAddrRes = await dio.post("/rpc/2.0/nlp/v1/address",
        queryParameters: {"access_token": token},
        data: jsonEncode({"text": _smartAddrController.text}));

    final smartAddrData = SmartAddress.fromJson(smartAddrRes.data);

    setState(() {
      _nameController.text = smartAddrData.person ?? "";
      _phoneController.text = smartAddrData.phonenum ?? "";
      _selectedProvince = smartAddrData.province ?? "";
      _selectedCity = smartAddrData.city ?? "";
      _selectedArea = smartAddrData.county ?? "";
      _detailController.text = smartAddrData.detail ?? "";
    });
  }

  Widget _buildEditableTextField(
      {required TextEditingController controller,
      required String hintText,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
      ),
      onTapOutside: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}
