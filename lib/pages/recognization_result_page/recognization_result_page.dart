import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rubbish_detection/repository/data/rubbish_data.dart';
import 'package:rubbish_detection/pages/recognization_result_page/recognization_result_vm.dart';
import 'package:rubbish_detection/widget/loading_page.dart';

class RecognizationResultPage extends StatefulWidget {
  const RecognizationResultPage({
    super.key,
    this.imagePath,
    required this.rubbishName,
  });

  final String? imagePath;
  final String rubbishName;

  @override
  State<RecognizationResultPage> createState() =>
      _RecognizationResultPageState();
}

class _RecognizationResultPageState extends State<RecognizationResultPage>
    with SingleTickerProviderStateMixin {
  final _recognizationViewModel = RecognizationResultViewModel();
  bool _isEditing = false;
  late TextEditingController _nameController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.rubbishName);
    _recognizationViewModel.getRubbishList(widget.rubbishName);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _recognizationViewModel,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            "识别结果",
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20.r,
              color: Colors.black87,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Consumer<RecognizationResultViewModel>(
            builder: (context, vm, child) {
              if (vm.rubbishList.isEmpty) {
                LoadingPage.showLoading();
                return const SizedBox();
              }

              LoadingPage.hideLoading();
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    children: [
                      // 主要内容卡片
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 15,
                              spreadRadius: 5,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // 图片区域
                            if (widget.imagePath?.isNotEmpty == true)
                              Container(
                                margin: EdgeInsets.only(top: 24.h),
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1.r,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Image.file(
                                    File(widget.imagePath!),
                                    width: 180.w,
                                    height: 140.h,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                            // 名称编辑区域
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 16.h,
                              ),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() => _isEditing = true);
                                    },
                                    child: _isEditing
                                        ? _buildEditableNameField()
                                        : Text(
                                            _nameController.text,
                                            style: TextStyle(
                                              fontSize: 26.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                  ),
                                  SizedBox(height: 8.h),
                                  // 编辑提示
                                  if (!_isEditing)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                              ),
                            ),
                            // 分类图标
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: _typeImage(vm.rubbishList[0].type ?? -1),
                            ),
                            // 处理建议
                            Container(
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
                                          borderRadius:
                                              BorderRadius.circular(2.r),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        "处理建议",
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16.h),
                                  ..._handleAdvice(vm.rubbishList[0]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 收藏按钮
                      GestureDetector(
                        onTap: () {
                          // TODO: 实现收藏功能
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 24.h),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00CE68),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00CE68).withOpacity(0.3),
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
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEditableNameField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF00CE68)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextField(
              controller: _nameController,
              autofocus: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '请输入名称',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.check_circle,
              color: Color(0xFF00CE68),
            ),
            onPressed: () {
              setState(() => _isEditing = false);
              _recognizationViewModel.getRubbishList(_nameController.text);
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _handleAdvice(Rubbish rubbish) {
    final startIdx = rubbish.tip?.indexOf("其中：");
    final realTips =
        startIdx != -1 ? rubbish.tip?.substring(startIdx! + 3) : rubbish.tip;

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
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList() ??
        [const SizedBox()];
  }

  Widget _typeImage(int type) {
    return switch (type) {
      0 => Image.asset(
          "assets/images/recyclable_waste_2.png",
          height: 150.w,
        ),
      1 => Image.asset(
          "assets/images/harmful_waste_2.png",
          height: 150.w,
        ),
      2 => Image.asset(
          "assets/images/food_waste_2.png",
          height: 150.w,
        ),
      3 => Image.asset(
          "assets/images/solid_waste_2.png",
          height: 150.w,
        ),
      _ => const SizedBox(),
    };
  }
}

// class RecognizationResultPage extends StatefulWidget {
//   const RecognizationResultPage(
//       {super.key, this.imagePath, required this.rubbishName});

//   final String? imagePath;
//   final String rubbishName;

//   @override
//   State<RecognizationResultPage> createState() =>
//       _RecognizationResultPageState();
// }

// class _RecognizationResultPageState extends State<RecognizationResultPage> {
//   final _recognizationViewModel = RecognizationResultViewModel();
//   bool _isEditing = false;
//   late TextEditingController _nameController;

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.rubbishName);
//     _recognizationViewModel.getRubbishList(widget.rubbishName);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _nameController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => _recognizationViewModel,
//       child: Scaffold(
//         appBar: AppBar(
//           centerTitle: true,
//           title: Text(
//             "识别结果",
//             style: TextStyle(
//               fontSize: 24.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         body: SingleChildScrollView(
//           child: Consumer<RecognizationResultViewModel>(
//               builder: (context, vm, child) {
//             if (vm.rubbishList.isEmpty) {
//               LoadingPage.showLoading();
//               return const SizedBox();
//             }

//             LoadingPage.hideLoading();
//             return Column(children: [
//               Container(
//                 margin: EdgeInsets.only(left: 30.w, right: 30.w, top: 10.h),
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16.r),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.shade200,
//                       blurRadius: 10.r,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     if (widget.imagePath?.isNotEmpty == true)
//                       Container(
//                         margin: EdgeInsets.only(top: 20.h),
//                         alignment: Alignment.center,
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(20.r),
//                           child: Image.file(
//                             File(widget.imagePath!),
//                             width: 150.w,
//                             height: 120.h,
//                             fit: BoxFit.fitHeight,
//                           ),
//                         ),
//                       ),
//                     SizedBox(height: 10.h),
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _isEditing = true;
//                         });
//                       },
//                       child: _isEditing
//                           ? _buildEditableNameField()
//                           : Text(
//                               _nameController.text,
//                               style: TextStyle(
//                                   fontSize: 24.sp, fontWeight: FontWeight.bold),
//                             ),
//                     ),
//                     SizedBox(height: 10.h),
//                     Row(
//                       children: [
//                         const Spacer(),
//                         Image.asset(
//                           "assets/images/edit_text.png",
//                           width: 20.r,
//                           height: 20.r,
//                         ),
//                         SizedBox(width: 10.w),
//                         Text(
//                           "识别记过有误？点击修正",
//                           style:
//                               TextStyle(fontSize: 16.sp, color: Colors.green),
//                         ),
//                         const Spacer(),
//                       ],
//                     ),
//                     SizedBox(height: 20.h),
//                     _typeImage(vm.rubbishList[0].type ?? -1),
//                     SizedBox(height: 20.h),
//                     Text(
//                       "处理建议",
//                       style: TextStyle(
//                           fontSize: 20.sp, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 20.h),
//                     ..._handleAdvice(vm.rubbishList[0]),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 30.h),
//               Container(
//                 margin: EdgeInsets.only(left: 30.w, right: 30.w),
//                 padding: EdgeInsets.symmetric(vertical: 15.h),
//                 decoration: BoxDecoration(
//                   color: Colors.green,
//                   borderRadius: BorderRadius.circular(10.r),
//                 ),
//                 child: Row(
//                   children: [
//                     const Spacer(),
//                     Image.asset(
//                       "assets/images/collection_2.png",
//                       width: 30.r,
//                       height: 30.r,
//                     ),
//                     SizedBox(width: 15.w),
//                     Text(
//                       "添加到识别收藏",
//                       style: TextStyle(fontSize: 20.sp, color: Colors.white),
//                     ),
//                     const Spacer(),
//                   ],
//                 ),
//               )
//             ]);
//           }),
//         ),
//       ),
//     );
//   }

//   List<Widget> _handleAdvice(Rubbish rubbish) {
//     final startIdx = rubbish.tip?.indexOf("其中：");
//     final realTips =
//         startIdx != -1 ? rubbish.tip?.substring(startIdx! + 3) : rubbish.tip;

//     return realTips?.split('；').map(
//           (tip) {
//             return Container(
//               margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 10.h),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(
//                     Icons.circle,
//                     size: 20.r,
//                   ),
//                   SizedBox(width: 5.w),
//                   Expanded(
//                     child: Text(
//                       tip,
//                       style: TextStyle(fontSize: 16.sp),
//                       softWrap: true,
//                       overflow: TextOverflow.visible,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ).toList() ??
//         [const SizedBox()];
//   }

//   Widget _buildEditableNameField() {
//     return Stack(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: _nameController,
//                 autofocus: true,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
//                 decoration: const InputDecoration(
//                   border: InputBorder.none,
//                   hintText: '请输入名称',
//                 ),
//               ),
//             ),
//           ],
//         ),
//         Positioned(
//           right: 20.w,
//           top: 6.h,
//           child: IconButton(
//             icon: const Icon(Icons.check, color: Colors.green),
//             onPressed: () {
//               // 保存修改
//               setState(() {
//                 _isEditing = false;
//               });
//               _recognizationViewModel.getRubbishList(_nameController.text);
//             },
//           ),
//         ),
//       ],
//     );
//   }

// }
