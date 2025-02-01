import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/widget/custom_address_picker.dart';
import 'package:rubbish_detection/widget/custom_time_picker.dart';

class Address {
  String? name;
  String? phoneNum;
  String? province;
  String? city;
  String? area;
  String? detail;
  String? pickupTime;

  Address({
    this.name,
    this.phoneNum,
    this.province,
    this.city,
    this.area,
    this.detail,
    this.pickupTime,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      name: json["name"] ?? "",
      phoneNum: json["phoneNum"] ?? "",
      province: json["province"] ?? "",
      city: json["city"] ?? "",
      area: json["area"] ?? "",
      detail: json["detail"] ?? "",
      pickupTime: json["pickupTime"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "phoneNum": phoneNum,
      "province": province,
      "city": city,
      "area": area,
      "detail": detail,
      "pickupTime": pickupTime,
    };
  }
}

class AddressCard extends StatefulWidget {
  const AddressCard({
    super.key,
    this.address,
    this.isReadOnly = false,
    this.formKey,
  });

  final GlobalKey<FormState>? formKey;
  final Address? address;
  final bool isReadOnly;

  @override
  State<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _detailController;

  late String _selectedPickupTime;
  late String _selectedProvince;
  late String _selectedCity;
  late String _selectedArea;

  @override
  void initState() {
    super.initState();
    _selectedPickupTime = widget.address?.pickupTime ?? "请选择上门时间";
    _selectedProvince = widget.address?.province ?? "";
    _selectedCity = widget.address?.city ?? "";
    _selectedArea = widget.address?.area ?? "";
    _nameController = TextEditingController(text: widget.address?.name)
      ..addListener(() => widget.address?.name = _nameController.text);
    _phoneController = TextEditingController(text: widget.address?.phoneNum)
      ..addListener(() => widget.address?.phoneNum = _phoneController.text);
    _detailController = TextEditingController(text: widget.address?.detail)
      ..addListener(() => widget.address?.detail = _detailController.text);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  String? _validateName(_) {
    if (_nameController.text.trim().isEmpty) {
      return "请输入姓名";
    }
    return null;
  }

  String? _validatePhone(_) {
    final value = _phoneController.text.trim();
    if (value.isEmpty) {
      return "请输入手机号";
    }
    final phoneRegex = RegExp(
        r"^(?:\+?86)?1(?:3\d{3}|5[^4\D]\d{2}|8\d{3}|7(?:[235-8]\d{2}|4(?:0\d|1[0-2]|9\d))|9[0-35-9]\d{2}|66\d{2})\d{6}$");
    if (!phoneRegex.hasMatch(value)) {
      return "请输入正确的手机号";
    }
    return null;
  }

  String? _validateDetail(_) {
    if (_detailController.text.trim().isEmpty) {
      return "请输入详细地址";
    }
    return null;
  }

  String? _validateRegion(_) {
    if (_selectedProvince.isEmpty ||
        _selectedCity.isEmpty ||
        _selectedArea.isEmpty) {
      return "请选择省市区";
    }
    return null;
  }

  String? _validatePickupTime(_) {
    if (_selectedPickupTime == "请选择上门时间") {
      return "请选择上门时间";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 卡片头部
        _buildHeader(),
        // 内容区域
        _buildContent(),
      ],
    );
  }

  Widget _buildHeader() {
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
            Icons.location_on,
            color: const Color(0xFF00CE68),
            size: 24.r,
          ),
          SizedBox(width: 8.w),
          Text(
            "上门信息",
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

  Widget _buildContent() {
    return Container(
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
      child: Form(
        key: widget.formKey,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  _buildFormField(
                    icon: Icons.person_outline,
                    label: "姓名",
                    child: _buildNameField(),
                    validator: _validateName,
                  ),
                  _buildDivider(),
                  _buildFormField(
                    icon: Icons.phone_outlined,
                    label: "手机号",
                    child: _buildPhoneField(),
                    validator: _validatePhone,
                  ),
                  _buildDivider(),
                  _buildFormField(
                    icon: Icons.map_outlined,
                    label: "省市区",
                    child: _buildProvinceCityAreaField(),
                    validator: _validateRegion,
                  ),
                  _buildDivider(),
                  _buildFormField(
                    icon: Icons.home_outlined,
                    label: "详细地址",
                    child: _buildDetailField(),
                    validator: _validateDetail,
                  ),
                  _buildDivider(),
                  _buildFormField(
                    icon: Icons.access_time_outlined,
                    label: "上门时间",
                    child: _buildPickupTimeField(),
                    validator: _validatePickupTime,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(
      {required IconData icon,
      required String label,
      required Widget child,
      required String? Function(String?) validator}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20.r,
                color: Colors.grey[600],
              ),
              SizedBox(width: 12.w),
              if (!widget.isReadOnly)
                RichText(
                  text: TextSpan(
                    text: label,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                    children: const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                child,
                _buildErrorMessage(validator),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String? Function(String?) validator) {
    return FormField(
      validator: validator,
      builder: (field) {
        if (field.errorText?.isEmpty ?? true) {
          return const SizedBox.shrink();
        } else {
          return Container(
            margin: EdgeInsets.only(top: 10.h),
            child: Text(
              field.errorText!,
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          );
        }
      },
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hintText,
      TextInputType? keyboardType}) {
    return TextField(
      textAlign: TextAlign.right,
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }

  Widget _buildNameField() {
    if (widget.isReadOnly) {
      return Text(
        widget.address?.name ?? "",
        style: TextStyle(fontSize: 16.sp),
      );
    } else {
      return _buildTextField(
        controller: _nameController,
        hintText: "请输入姓名",
      );
    }
  }

  Widget _buildPhoneField() {
    if (widget.isReadOnly) {
      return Text(
        widget.address?.phoneNum ?? "",
        style: TextStyle(fontSize: 16.sp),
      );
    } else {
      return _buildTextField(
        controller: _phoneController,
        hintText: "请输入手机号",
        keyboardType: TextInputType.phone,
      );
    }
  }

  Widget _buildProvinceCityAreaField() {
    return StatefulBuilder(
      builder: (context, setState) {
        final String text;
        if (_selectedProvince.isEmpty ||
            _selectedCity.isEmpty ||
            _selectedArea.isEmpty) {
          text = "请选择省市区";
        } else {
          text = "$_selectedProvince $_selectedCity $_selectedArea";
        }

        if (widget.isReadOnly) {
          return Text(text, style: TextStyle(fontSize: 16.sp));
        } else {
          return GestureDetector(
            onTap: () {
              _showCustomPicker(
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

                      widget.address?.province = _selectedProvince;
                      widget.address?.city = _selectedCity;
                      widget.address?.area = _selectedArea;
                    });
                  },
                ),
              );
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: text == "请选择省市区" ? Colors.grey : Colors.black,
                    ),
                    textAlign: TextAlign.right,
                    softWrap: true,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, size: 20.r),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildDetailField() {
    if (widget.isReadOnly) {
      return Text(
        widget.address?.detail ?? "",
        style: TextStyle(fontSize: 16.sp),
      );
    } else {
      return _buildTextField(
        controller: _detailController,
        hintText: "请输入详细地址",
      );
    }
  }

  Widget _buildPickupTimeField() {
    if (widget.isReadOnly) {
      return Text(_selectedPickupTime, style: TextStyle(fontSize: 16.sp));
    } else {
      return StatefulBuilder(
        builder: (context, setState) {
          return GestureDetector(
            onTap: () {
              _showCustomPicker(
                picker: CustomTimePicker(
                  initialDateTime: _selectedPickupTime,
                  onTimeSelected: (value) {
                    setState(() {
                      _selectedPickupTime = value;
                      widget.address?.pickupTime = _selectedPickupTime;
                    });
                  },
                ),
              );
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedPickupTime,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: _selectedPickupTime == "请选择上门时间"
                          ? Colors.grey
                          : Colors.black,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, size: 20.r),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildDivider() {
    return Divider(height: 1.h, color: Colors.grey[200]);
  }

  void _showCustomPicker({required Widget picker}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: picker,
        );
      },
    );
  }
}
