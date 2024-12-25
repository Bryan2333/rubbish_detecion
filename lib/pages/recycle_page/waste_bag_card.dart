import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WasteBag {
  final int id;
  String? type;
  String? name;
  String? weight;
  String? unit;
  String? description;
  List<String> photos = [];
  double? estimatedPrice;

  WasteBag({required this.id});
}

class WasteBagCard extends StatefulWidget {
  final WasteBag bag;
  final VoidCallback? onCalculateTotal;
  final Function(int)? removeWasteBag;
  final Future<void> Function(int)? onPickImage;
  final bool isReadOnly;

  const WasteBagCard({
    super.key,
    required this.bag,
    required this.isReadOnly,
    this.onCalculateTotal,
    this.onPickImage,
    this.removeWasteBag,
  });

  @override
  State<WasteBagCard> createState() => _WasteBagCardState();
}

class _WasteBagCardState extends State<WasteBagCard>
    with SingleTickerProviderStateMixin {
  late String _selectedType;
  late String _selectedUnit;
  bool _isExpanded = true;

  // 添加动画控制器和动画
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.bag.type ?? "请选择废品类型";
    _selectedUnit = "kg";
    widget.bag.unit = _selectedUnit;

    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    // 如果初始状态是展开的，设置动画到结束状态
    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // 卡片头部
          _buildHeader(),
          // 内容区域使用 SizeTransition 包装
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.r),
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
                      ),
                      _buildDivider(),
                      _buildPhotos(),
                      if (!widget.isReadOnly) ...[
                        SizedBox(height: 16.h),
                        _buildActions(),
                      ],
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
            }
          });
        },
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: const Color(0xFF00CE68).withOpacity(0.1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(_isExpanded ? 0 : 16.r),
              bottomRight: Radius.circular(_isExpanded ? 0 : 16.r),
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
                "${widget.bag.id}号废品袋",
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

  Widget _buildTypeDropdown() {
    return widget.isReadOnly
        ? Text(widget.bag.name ?? "", style: TextStyle(fontSize: 16.sp))
        : DropdownButton<String>(
            value: _selectedType == "请选择废品类型" ? null : _selectedType,
            hint: const Text("请选择废品类型"),
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: "干垃圾", child: Text("干垃圾")),
              DropdownMenuItem(value: "湿垃圾", child: Text("湿垃圾")),
              DropdownMenuItem(value: "可回收垃圾", child: Text("可回收垃圾")),
              DropdownMenuItem(value: "有害垃圾", child: Text("有害垃圾")),
            ],
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
                widget.bag.type = value;
              });
            },
          );
  }

  Widget _buildNameField() {
    return widget.isReadOnly
        ? Text(widget.bag.name ?? "", style: TextStyle(fontSize: 16.sp))
        : TextField(
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              hintText: "请输入废品名称",
              border: InputBorder.none,
            ),
            onChanged: (value) => widget.bag.name = value,
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
          );
  }

  Widget _buildWeightField() {
    return widget.isReadOnly
        ? Text(
            "${widget.bag.weight} ${widget.bag.unit}",
            style: TextStyle(fontSize: 16.sp),
          )
        : Row(
            children: [
              Expanded(
                child: TextField(
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "请输入废品重量",
                    border: InputBorder.none,
                  ),
                  onChanged: (value) => widget.bag.weight = value,
                  onTapOutside: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                ),
              ),
              ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<String>(
                  value: _selectedUnit,
                  items: const [
                    DropdownMenuItem(value: "kg", child: Text("千克")),
                    DropdownMenuItem(value: "g", child: Text("克")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedUnit = value!;
                      widget.bag.unit = value;
                    });
                  },
                  padding: EdgeInsets.zero,
                  underline: const SizedBox(),
                  iconSize: 20.r,
                ),
              ),
            ],
          );
  }

  Widget _buildDescriptionField() {
    return widget.isReadOnly
        ? Text(widget.bag.description ?? "", style: TextStyle(fontSize: 16.sp))
        : TextField(
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              hintText: "请输入描述信息",
              border: InputBorder.none,
            ),
            onChanged: (value) => widget.bag.description = value,
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
          );
  }

  Widget _buildPhotos() {
    return Row(
      children: [
        Text("垃圾图片", style: TextStyle(fontSize: 16.sp)),
        const Spacer(),
        Wrap(
          children: [
            ...widget.bag.photos.map((photo) {
              return Container(
                padding: EdgeInsets.all(4.r),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.r),
                  child: Image.file(
                    File(photo),
                    width: 60.w,
                    height: 60.h,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }),
            if (!widget.isReadOnly)
              GestureDetector(
                onTap: () {
                  if (widget.onPickImage == null) return;
                  widget.onPickImage!(widget.bag.id);
                },
                child: Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: const Color(0xFFF9FBFC),
                  ),
                  child: const Icon(Icons.add, color: Color(0xFFC9CBCD)),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            widget.bag.estimatedPrice = 7.64; // 模拟估价逻辑
            if (widget.onCalculateTotal == null) return;
            widget.onCalculateTotal!();
          },
          child: Container(
            padding: EdgeInsets.all(5.r),
            child: Text("估价", style: TextStyle(fontSize: 16.sp)),
          ),
        ),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
          ),
          onPressed: () {
            if (widget.removeWasteBag == null) return;
            widget.removeWasteBag!(widget.bag.id);
          },
          child: Container(
            padding: EdgeInsets.all(5.r),
            child: Text("删除垃圾袋",
                style: TextStyle(fontSize: 16.sp, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
