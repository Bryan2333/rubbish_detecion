import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rubbish_detection/pages/auth_page/auth_vm.dart';
import 'package:rubbish_detection/pages/recognization_result_page/recognization_result_vm.dart';
import 'package:rubbish_detection/repository/api.dart';
import 'package:rubbish_detection/repository/data/rubbish_data.dart';
import 'package:rubbish_detection/utils/custom_helper.dart';

class RecognizationResultPage extends StatefulWidget {
  const RecognizationResultPage({
    super.key,
    this.imagePath,
    required this.rubbishName,
    this.isCollected = false,
  });

  final String? imagePath;
  final String rubbishName;
  final bool isCollected;

  @override
  State<RecognizationResultPage> createState() =>
      _RecognizationResultPageState();
}

class _RecognizationResultPageState extends State<RecognizationResultPage>
    with SingleTickerProviderStateMixin {
  final _recognizationViewModel = RecognizationResultViewModel();
  final _nameFieldKey = GlobalKey<FormFieldState>();

  late ValueNotifier<bool> _isEditingNotifier;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.rubbishName);
    _isEditingNotifier = ValueNotifier(false);
    _recognizationViewModel.getRubbishList(widget.rubbishName);
  }

  @override
  void dispose() {
    _isEditingNotifier.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _typeImage(int type) {
    return switch (type) {
      0 => "assets/images/recyclable_waste_2.png",
      1 => "assets/images/harmful_waste_2.png",
      2 => "assets/images/food_waste_2.png",
      3 => "assets/images/solid_waste_2.png",
      _ => "",
    };
  }

  void _addCollection(Rubbish rubbish) async {
    final userId =
        await Provider.of<AuthViewModel>(context, listen: false).getUserId();

    if (!mounted) return;
    if (userId == -1) {
      CustomHelper.showSnackBar(context, "请先登录", success: false);
      return;
    }

    await CustomHelper.executeAsyncCall(
      context: context,
      futureCall: Api.instance.addCollection(
        userId,
        _nameController.text.trim(),
        rubbish.type!,
        DateTime.now().toIso8601String(),
        widget.imagePath?.isNotEmpty ?? false
            ? base64Encode(File(widget.imagePath!).readAsBytesSync())
            : null,
      ),
      successMessage: "添加成功",
      failurePrefix: "添加失败",
    );
  }

  void _submitName() {
    if (_nameFieldKey.currentState?.validate() ?? false) {
      _isEditingNotifier.value = false;
      _recognizationViewModel.getRubbishList(_nameController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _recognizationViewModel,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: Consumer<RecognizationResultViewModel>(
            builder: (context, vm, child) {
          if (vm.isLoading) {
            return CustomHelper.progressIndicator;
          } else if (vm.rubbishList.isEmpty) {
            return _buildFailedContent();
          } else {
            return _buildSuccessContent(vm.rubbishList.first);
          }
        }),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        "识别结果",
        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildFailedContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.r,
            color: Colors.redAccent,
          ),
          SizedBox(height: 16.h),
          Text(
            "识别失败，请重试。",
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              _recognizationViewModel.getRubbishList(widget.rubbishName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00CE68),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              "重试",
              style: TextStyle(fontSize: 16.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(Rubbish rubbish) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          children: [
            // 主要内容卡片
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(color: Colors.grey[300]!, blurRadius: 15.r),
                ],
              ),
              child: Column(
                children: [
                  // 图片区域
                  if (widget.imagePath != null) _buildImageField(),
                  if (widget.imagePath == null) SizedBox(height: 20.h),
                  // 名称编辑区域
                  _buildNameField(),
                  // 分类图标
                  _buildIconField(rubbish.type ?? -1),
                  // 处理建议
                  _buildHandleAdviceField(rubbish.tip),
                ],
              ),
            ),
            // 收藏按钮
            if (!widget.isCollected) _buildCollectButton(rubbish),
          ],
        ),
      ),
    );
  }

  Widget _buildImageField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.h),
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey[200]!, width: 1.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: _buildImageWidget(),
      ),
    );
  }

  Widget _buildImageWidget() {
    final path = widget.imagePath!;
    if (path.startsWith("http://") || path.startsWith("https://")) {
      return CachedNetworkImage(
        imageUrl: path,
        width: 180.w,
        height: 140.h,
        fit: BoxFit.cover,
        placeholder: (_, __) => CustomHelper.progressIndicator,
        errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined),
      );
    } else {
      return Image.file(
        File(path),
        width: 180.w,
        height: 140.h,
        fit: BoxFit.contain,
      );
    }
  }

  Widget _buildNameField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: ValueListenableBuilder(
        valueListenable: _isEditingNotifier,
        builder: (context, isEditing, child) {
          return Column(
            children: [
              isEditing
                  ? _buildEditableNameField()
                  : GestureDetector(
                      onTap: () => _isEditingNotifier.value = true,
                      child: Text(
                        _nameController.text,
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
              SizedBox(height: 8.h),
              // 编辑提示
              if (!isEditing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/edit_text.png",
                      width: 16.r,
                      height: 16.r,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "识别结果有误？点击修正",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF00CE68),
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEditableNameField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF00CE68)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              key: _nameFieldKey,
              controller: _nameController,
              autofocus: true,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '请输入名称',
              ),
              onTapOutside: (_) {
                _isEditingNotifier.value = false;
                FocusManager.instance.primaryFocus?.unfocus();
              },
              onEditingComplete: _submitName,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "垃圾名称不能为空";
                }
                return null;
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_outlined, color: Color(0xFF00CE68)),
            onPressed: _submitName,
          ),
        ],
      ),
    );
  }

  Widget _buildIconField(int type) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.h),
      child: Image.asset(_typeImage(type), height: 150.w),
    );
  }

  Widget _buildHandleAdviceField(String? tips) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF00CE68),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "处理建议",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ..._handleAdvice(tips),
        ],
      ),
    );
  }

  List<Widget> _handleAdvice(String? tips) {
    final startIdx = tips?.indexOf("其中：");
    final realTips = startIdx != -1 ? tips?.substring(startIdx! + 3) : tips;

    return realTips?.split('；').map((tip) {
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 4.h),
                  width: 6.w,
                  height: 6.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00CE68),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(fontSize: 16.sp, height: 1.5.h),
                  ),
                ),
              ],
            ),
          );
        }).toList() ??
        [const SizedBox.shrink()];
  }

  Widget _buildCollectButton(Rubbish rubbish) {
    return GestureDetector(
      onTap: () => _addCollection(rubbish),
      child: Container(
        margin: EdgeInsets.only(top: 24.h),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFF00CE68),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00CE68).withValues(alpha: 0.3),
              blurRadius: 15.r,
              spreadRadius: 1.r,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/collection_2.png",
              width: 24.r,
              height: 24.r,
            ),
            SizedBox(width: 12.w),
            Text(
              "添加到识别收藏",
              style: TextStyle(fontSize: 18.sp, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
