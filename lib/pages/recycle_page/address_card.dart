import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:rubbish_detection/repository/data/order_address_bean.dart';
import 'package:rubbish_detection/widget/custom_address_picker.dart';
import 'package:rubbish_detection/widget/custom_time_picker.dart';

class AddressCard extends StatefulWidget {
  const AddressCard({
    super.key,
    this.address,
    this.isReadOnly = false,
    this.formKey,
  });

  final GlobalKey<FormState>? formKey;
  final OrderAddressBean? address;
  final bool isReadOnly;

  @override
  State<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late ValueNotifier<String> _provinceNotifier;
  late ValueNotifier<String> _cityNotifier;
  late ValueNotifier<String> _areaNotifier;
  late TextEditingController _detailController;
  late ValueNotifier<String> _pickupTimeNotifier;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.name)
      ..addListener(() => widget.address?.name = _nameController.text.trim());
    _phoneController = TextEditingController(text: widget.address?.phoneNum)
      ..addListener(() => widget.address?.phoneNum = _phoneController.text);
    _provinceNotifier = ValueNotifier(widget.address?.province ?? "")
      ..addListener(() => widget.address?.province = _provinceNotifier.value);
    _cityNotifier = ValueNotifier(widget.address?.city ?? "")
      ..addListener(() => widget.address?.city = _cityNotifier.value);
    _areaNotifier = ValueNotifier(widget.address?.area ?? "")
      ..addListener(() => widget.address?.area = _areaNotifier.value);
    _detailController = TextEditingController(text: widget.address?.detail)
      ..addListener(
          () => widget.address?.detail = _detailController.text.trim());
    _pickupTimeNotifier = ValueNotifier(widget.address?.pickupTime ?? "请选择上门时间")
      ..addListener(
          () => widget.address?.pickupTime = _pickupTimeNotifier.value);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _provinceNotifier.dispose();
    _cityNotifier.dispose();
    _areaNotifier.dispose();
    _detailController.dispose();
    _pickupTimeNotifier.dispose();
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
    if (_provinceNotifier.value.isEmpty ||
        _cityNotifier.value.isEmpty ||
        _areaNotifier.value.isEmpty) {
      return "请选择省市区";
    }
    return null;
  }

  String? _validatePickupTime(_) {
    if (_pickupTimeNotifier.value == "请选择上门时间") {
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
            Icons.location_on_outlined,
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
                    child: _buildTextField(
                      controller: _nameController,
                      hintText: "请输入姓名",
                    ),
                    validator: _validateName,
                  ),
                  _buildDivider(),
                  _buildFormField(
                    icon: Icons.phone_outlined,
                    label: "手机号",
                    child: _buildTextField(
                      controller: _phoneController,
                      hintText: "请输入手机号",
                      keyboardType: TextInputType.phone,
                    ),
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
                    child: _buildTextField(
                      controller: _detailController,
                      hintText: "请输入详细地址",
                    ),
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
              RichText(
                text: TextSpan(
                  text: label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                  children: widget.isReadOnly
                      ? null
                      : const [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                ),
              )
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
      readOnly: widget.isReadOnly,
      textAlign: TextAlign.right,
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      style: TextStyle(fontSize: 16.sp),
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }

  Widget _buildProvinceCityAreaField() {
    return MultiValueListenableBuilder(
      valueListenables: [_provinceNotifier, _cityNotifier, _areaNotifier],
      builder: (context, values, child) {
        final province = values[0] as String;
        final city = values[1] as String;
        final area = values[2] as String;
        final text = (province.isEmpty || city.isEmpty || area.isEmpty)
            ? "请选择省市区"
            : "$province $city $area";

        return GestureDetector(
          onTap: () {
            if (widget.isReadOnly) return;
            _showCustomPicker(
              picker: CustomAddressPicker(
                initialAddress: {
                  "province": province,
                  "city": city,
                  "district": area
                },
                onAddressSelected: (value) {
                  _provinceNotifier.value = value["province"]!;
                  _cityNotifier.value = value["city"]!;
                  _areaNotifier.value = value["district"]!;
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
                    fontSize: 16.sp,
                    color: text == "请选择省市区" ? Colors.grey : Colors.black,
                  ),
                  textAlign: TextAlign.right,
                  softWrap: true,
                ),
              ),
              if (!widget.isReadOnly)
                Icon(Icons.keyboard_arrow_down, size: 20.r),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPickupTimeField() {
    return ValueListenableBuilder(
      valueListenable: _pickupTimeNotifier,
      builder: (context, pickupTime, child) {
        return GestureDetector(
          onTap: () {
            if (widget.isReadOnly) return;
            _showCustomPicker(
              picker: CustomTimePicker(
                initialDateTime: pickupTime,
                onTimeSelected: (value) {
                  _pickupTimeNotifier.value = value;
                },
              ),
            );
          },
          child: Row(
            children: [
              Expanded(
                child: Text(
                  pickupTime,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: pickupTime == "请选择上门时间" ? Colors.grey : Colors.black,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              if (!widget.isReadOnly)
                Icon(Icons.keyboard_arrow_down, size: 20.r),
            ],
          ),
        );
      },
    );
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
