import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/repository/data/order_waste_bean.dart';
import 'package:rubbish_detection/utils/custom_helper.dart';
import 'package:rubbish_detection/utils/image_helper.dart';

class WasteCard extends StatefulWidget {
  final OrderWasteBean? waste;
  final VoidCallback? onCalEstimatedPrice;
  final bool isReadOnly;
  final GlobalKey<FormState>? formKey;
  final List<String>? localPhotoPaths;

  const WasteCard({
    super.key,
    required this.waste,
    this.isReadOnly = false,
    this.onCalEstimatedPrice,
    this.formKey,
    this.localPhotoPaths,
  });

  @override
  State<WasteCard> createState() => _WasteCardState();
}

class _WasteCardState extends State<WasteCard>
    with SingleTickerProviderStateMixin {
  late ValueNotifier<int> _typeNotifier;
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late ValueNotifier<int> _unitNotifier;
  late TextEditingController _descriptionController;

  bool _isDeleting = false;

  final _wasteTypeMap = {
    0: "干垃圾",
    1: "湿垃圾",
    2: "可回收物",
    3: "有害垃圾",
  };

  @override
  void initState() {
    super.initState();
    _typeNotifier = ValueNotifier(widget.waste?.type ?? 0)
      ..addListener(() {
        widget.waste?.type = _typeNotifier.value;
        widget.onCalEstimatedPrice?.call();
      });
    _nameController = TextEditingController(text: widget.waste?.name)
      ..addListener(() {
        widget.waste?.name = _nameController.text.trim();
      });
    _weightController =
        TextEditingController(text: widget.waste?.weight?.toString() ?? "")
          ..addListener(() {
            widget.waste?.weight = double.tryParse(_weightController.text) ?? 0;
            widget.onCalEstimatedPrice?.call();
          });
    _unitNotifier = ValueNotifier(widget.waste?.unit ?? 1)
      ..addListener(() {
        widget.waste?.unit = _unitNotifier.value;
        widget.onCalEstimatedPrice?.call();
      });
    _descriptionController =
        TextEditingController(text: widget.waste?.description)
          ..addListener(() {
            widget.waste?.description = _descriptionController.text.trim();
          });
  }

  @override
  void dispose() {
    _typeNotifier.dispose();
    _nameController.dispose();
    _weightController.dispose();
    _unitNotifier.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return "请输入废品名称";
    }
    return null;
  }

  String? _validateWeight(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return "请输入废品重量";
    }
    if (RegExp(r'[^\d.]').hasMatch(trimmed)) {
      return "请输入有效的数字";
    }
    return null;
  }

  String? _validatePhotos(List<String>? value) {
    if (value?.isEmpty ?? true) {
      return "请上传至少一张图片";
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
            Icons.recycling,
            color: const Color(0xFF00CE68),
            size: 24.r,
          ),
          SizedBox(width: 8.w),
          Text(
            "回收物信息",
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
                    icon: Icons.category_outlined,
                    label: "类型",
                    child: _buildTypeDropdown(),
                  ),
                  _buildDivider(),
                  _buildFormField(
                    icon: Icons.edit_outlined,
                    label: "名称",
                    child: _buildTextField(_nameController, "请输入废品名称"),
                    validator: (_) => _validateName(_nameController.text),
                  ),
                  _buildDivider(),
                  _buildFormField(
                    icon: Icons.monitor_weight_outlined,
                    label: "重量",
                    child: _buildWeightField(),
                    validator: (_) => _validateWeight(_weightController.text),
                  ),
                  _buildDivider(),
                  _buildFormField(
                    icon: Icons.description_outlined,
                    label: "描述",
                    child: _buildTextField(_descriptionController, "请输入描述信息"),
                    isRequired: false,
                  ),
                  _buildDivider(),
                  _buildFormField(
                    icon: Icons.image_outlined,
                    label: "图片",
                    child: _buildPhotos(),
                    validator: (_) => _validatePhotos(widget.localPhotoPaths),
                    centerAlign: true,
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
      bool centerAlign = false,
      bool isRequired = true,
      String? Function(String? value)? validator}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        crossAxisAlignment:
            centerAlign ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                  children: widget.isReadOnly
                      ? null
                      : (isRequired
                          ? const [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ]
                          : null),
                ),
              )
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                child,
                if (isRequired) _buildErrorMessage(validator),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1.h, color: Colors.grey[200]);
  }

  Widget _buildTypeDropdown() {
    return ValueListenableBuilder(
      valueListenable: _typeNotifier,
      builder: (context, type, child) {
        if (widget.isReadOnly) {
          return Text(_wasteTypeMap[type] ?? "未知",
              style: TextStyle(fontSize: 16.sp));
        }
        return DropdownButton(
          value: type,
          underline: const SizedBox.shrink(),
          isDense: true,
          padding: EdgeInsets.zero,
          items: const [
            DropdownMenuItem(value: 0, child: Text("干垃圾")),
            DropdownMenuItem(value: 1, child: Text("湿垃圾")),
            DropdownMenuItem(value: 2, child: Text("可回收物")),
            DropdownMenuItem(value: 3, child: Text("有害垃圾")),
          ],
          onChanged: (value) {
            _typeNotifier.value = value!;
          },
        );
      },
    );
  }

  Widget _buildWeightField() {
    return Row(
      children: [
        Expanded(child: _buildTextField(_weightController, "请输入废品重量")),
        SizedBox(width: 8.w),
        ValueListenableBuilder(
          valueListenable: _unitNotifier,
          builder: (context, selectedUnit, child) {
            if (widget.isReadOnly) {
              return Text(selectedUnit == 1 ? "千克" : "克",
                  style: TextStyle(fontSize: 16.sp));
            }
            return DropdownButton(
              value: selectedUnit,
              isDense: true,
              padding: EdgeInsets.zero,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 1, child: Text("千克")),
                DropdownMenuItem(value: 0, child: Text("克")),
              ],
              onChanged: (value) => _unitNotifier.value = value!,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPhotos() {
    final photosToDisplay = widget.isReadOnly
        ? (widget.waste?.photos ?? [])
        : widget.localPhotoPaths ?? [];

    if (photosToDisplay.isEmpty && widget.isReadOnly) {
      return Text("暂无图片", style: TextStyle(fontSize: 16.sp));
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return Wrap(
          children: [
            ...photosToDisplay.asMap().entries.map((entry) {
              final MapEntry(key: index, value: photo) = entry;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: GestureDetector(
                  // 长按图片时显示删除按钮
                  onLongPress: !widget.isReadOnly
                      ? () => setState(() => _isDeleting = !_isDeleting)
                      : null,
                  child: Stack(
                    children: [
                      _buildImageWidget(photo),
                      // 删除按钮，只有长按时才显示
                      if (_isDeleting)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                photosToDisplay.removeAt(index);

                                if (photosToDisplay.isEmpty) {
                                  _isDeleting = false;
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(4.r),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 14.r,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
            if (!widget.isReadOnly && photosToDisplay.length < 3)
              GestureDetector(
                onTap: () async {
                  final imageSource =
                      await ImageHelper.showPickerDialog(context);
                  if (imageSource == null) return;

                  final image = await ImageHelper.pickImage(
                      source: imageSource, imageQuality: 80);
                  if (image == null) return;

                  setState(() => photosToDisplay.add(image.path));
                },
                child: Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: Colors.grey[100],
                  ),
                  child: const Icon(Icons.add, color: Colors.grey),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildImageWidget(String path) {
    final double imageSize = 60.r;
    final double borderRadius = 10.r;

    Widget buildErrorIcon() {
      return Icon(
        Icons.broken_image_outlined,
        color: Colors.grey,
        size: imageSize,
      );
    }

    Widget imageWidget;
    if (Uri.tryParse(path)?.hasScheme ?? false) {
      imageWidget = CachedNetworkImage(
        imageUrl: path,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
        progressIndicatorBuilder: (_, __, ___) =>
            CustomHelper.progressIndicator,
        errorWidget: (_, __, ___) => buildErrorIcon(),
      );
    } else {
      imageWidget = Image.file(
        File(path),
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => buildErrorIcon(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: imageWidget,
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      readOnly: widget.isReadOnly,
      textAlign: TextAlign.right,
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

  Widget _buildErrorMessage(String? Function(String? value)? validator) {
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
}
