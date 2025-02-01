import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/utils/image_helper.dart';

class Waste {
  int? id;
  String? type;
  String? name;
  String? weight;
  String? unit;
  String? description;
  List<String> photos = [];

  Waste({
    this.id,
    this.type = "0",
    this.name,
    this.weight,
    this.unit = "kg",
    this.description,
    this.photos = const [],
  });

  // 从JSON创建WasteBag实例
  factory Waste.fromJson(Map<String, dynamic> json) {
    return Waste(
      id: json['id'] ?? 0,
      type: json['type'],
      name: json['name'],
      weight: json['weight'],
      unit: json['unit'],
      description: json['description'],
      photos: List<String>.from(json['photos'] ?? []),
    );
  }

  // 将WasteBag实例转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'weight': weight,
      'unit': unit,
      'description': description,
      'photos': photos,
    };
  }
}

class WasteCard extends StatefulWidget {
  final Waste waste;
  final VoidCallback? onCalculateTotal;
  final Function(int)? removeWasteBag;
  final bool isReadOnly;
  final GlobalKey<FormState>? formKey;

  const WasteCard({
    super.key,
    required this.waste,
    this.isReadOnly = false,
    this.onCalculateTotal,
    this.removeWasteBag,
    this.formKey,
  });

  @override
  State<WasteCard> createState() => _WasteCardState();
}

class _WasteCardState extends State<WasteCard>
    with SingleTickerProviderStateMixin {
  late String _selectedType;
  late String _selectedUnit;

  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.waste.type ?? "0";
    _selectedUnit = widget.waste.unit ?? "kg";
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty == true) {
      return "请输入废品名称";
    }
    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.trim().isEmpty == true) {
      return "请输入废品重量";
    }
    if (RegExp(r'[^\d.]').hasMatch(value)) {
      return "请输入有效的数字";
    }
    return null;
  }

  String? _validatePhotos(List<String> value) {
    if (value.isEmpty) {
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
                    child: _buildNameField(),
                  ),
                  _buildDivider(),
                  _buildFormField(
                    icon: Icons.monitor_weight_outlined,
                    label: "重量",
                    child: _buildWeightField(),
                  ),
                  _buildDivider(),
                  _buildFormField(
                    icon: Icons.description_outlined,
                    label: "描述",
                    child: _buildDescriptionField(),
                    isRequired: false,
                  ),
                  _buildDivider(),
                  _buildFormField(
                    icon: Icons.image_outlined,
                    label: "图片",
                    child: _buildPhotos(),
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

  Widget _buildFormField({
    required IconData icon,
    required String label,
    required Widget child,
    bool centerAlign = false,
    bool isRequired = true,
  }) {
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
              if (isRequired && !widget.isReadOnly)
                RichText(
                  text: TextSpan(
                    text: label,
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
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
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                ),
            ],
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              child: child,
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
    if (widget.isReadOnly) {
      return Text(widget.waste.name ?? "", style: TextStyle(fontSize: 16.sp));
    } else {
      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              DropdownButton(
                value: _selectedType,
                underline: const SizedBox.shrink(),
                isDense: true,
                padding: EdgeInsets.zero,
                items: const [
                  DropdownMenuItem(value: "0", child: Text("干垃圾")),
                  DropdownMenuItem(value: "1", child: Text("湿垃圾")),
                  DropdownMenuItem(value: "2", child: Text("可回收物")),
                  DropdownMenuItem(value: "3", child: Text("有害垃圾")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                    widget.waste.type = _selectedType;
                    widget.onCalculateTotal?.call();
                  });
                },
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildNameField() {
    if (widget.isReadOnly) {
      return Text(widget.waste.name ?? "", style: TextStyle(fontSize: 16.sp));
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              hintText: "请输入废品名称",
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) => widget.waste.name = value,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
          _buildErrorMessage((_) => _validateName(widget.waste.name)),
        ],
      );
    }
  }

  Widget _buildWeightField() {
    if (widget.isReadOnly) {
      return Text(
        "${widget.waste.weight} ${widget.waste.unit}",
        style: TextStyle(fontSize: 16.sp),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "请输入废品重量",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    widget.waste.weight = value;
                    widget.onCalculateTotal?.call();
                  },
                  onTapOutside: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                ),
              ),
              SizedBox(width: 8.w),
              StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButton(
                    value: _selectedUnit,
                    isDense: true,
                    padding: EdgeInsets.zero,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: "kg", child: Text("千克")),
                      DropdownMenuItem(value: "g", child: Text("克")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedUnit = value!;
                        widget.waste.unit = _selectedUnit;
                        widget.onCalculateTotal?.call();
                      });
                    },
                  );
                },
              ),
            ],
          ),
          _buildErrorMessage((_) => _validateWeight(widget.waste.weight)),
        ],
      );
    }
  }

  Widget _buildDescriptionField() {
    if (widget.isReadOnly) {
      return Text(
        widget.waste.description ?? "无",
        style: TextStyle(fontSize: 16.sp),
      );
    } else {
      return TextField(
        textAlign: TextAlign.right,
        decoration: const InputDecoration(
          hintText: "请输入描述信息",
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) => widget.waste.description = value,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      );
    }
  }

  Widget _buildPhotos() {
    if (widget.waste.photos.isEmpty && widget.isReadOnly) {
      return Text("暂无图片", style: TextStyle(fontSize: 16.sp));
    } else {
      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Wrap(
                children: [
                  ...widget.waste.photos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final photo = entry.value;
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: GestureDetector(
                        // 长按图片时显示删除按钮
                        onLongPress: !widget.isReadOnly
                            ? () => setState(() => _isDeleting = !_isDeleting)
                            : null,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: Image.file(
                                File(photo),
                                width: 60.w,
                                height: 60.h,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.grey,
                                    size: 30.r,
                                  );
                                },
                              ),
                            ),
                            // 删除按钮，只有长按时才显示
                            if (_isDeleting)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      widget.waste.photos.removeAt(index);

                                      if (widget.waste.photos.isEmpty) {
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
                  if (!widget.isReadOnly && widget.waste.photos.length < 3)
                    GestureDetector(
                      onTap: () async {
                        final imageSource =
                            await ImageHelper.showPickerDialog(context);
                        if (imageSource == null) {
                          return;
                        }

                        final image =
                            await ImageHelper.pickImage(source: imageSource);
                        if (image == null) {
                          return;
                        }

                        setState(() => widget.waste.photos.add(image.path));
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
              ),
              _buildErrorMessage((_) => _validatePhotos(widget.waste.photos)),
            ],
          );
        },
      );
    }
  }

  Widget _buildErrorMessage(String? Function(String? value) validator) {
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
