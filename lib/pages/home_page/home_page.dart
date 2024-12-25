import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:rubbish_detection/route.dart';
import 'package:rubbish_detection/utils/image_classification_helper.dart';
import 'package:image/image.dart' as image_lib;
import 'package:rubbish_detection/pages/home_page/home_vm.dart';
import 'package:rubbish_detection/pages/recognization_result_page/recognization_result_page.dart';
import 'package:rubbish_detection/pages/rubbish_type_desc_page/rubbish_type_desc_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _homeViewModel = HomeViewModel();

  late ImageClassificationHelper _imageHelper;
  late TextEditingController _searchBarController;

  @override
  void initState() {
    super.initState();
    _homeViewModel.getBannerData();
    _imageHelper = ImageClassificationHelper();
    _searchBarController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _searchBarController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "首页",
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ChangeNotifierProvider(
        create: (context) => _homeViewModel,
        child: SafeArea(
          child: Column(
            children: [
              // 搜索框
              Container(
                margin: EdgeInsets.only(left: 15.w, right: 15.w, bottom: 20.h),
                padding: EdgeInsets.only(left: 10.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: TextField(
                  controller: _searchBarController,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: "请输入垃圾名称",
                    hintStyle: const TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search,
                      size: 30.r,
                    ),
                    suffixIcon: _searchBarController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _searchBarController.text = "";
                                _searchBarController.clear();
                              });
                            },
                            icon: Icon(Icons.clear, size: 30.r),
                          )
                        : null,
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                  onSubmitted: (value) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return RecognizationResultPage(
                            imagePath: "",
                            rubbishName: value,
                          );
                        },
                      ),
                    );
                  },
                  onTapOutside: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                ),
              ),
              // banner
              Consumer<HomeViewModel>(
                builder: (context, vm, child) {
                  return Container(
                    margin: EdgeInsets.only(
                      bottom: 20.h,
                      left: 15.w,
                      right: 15.w,
                    ),
                    height: 150.h,
                    child: Swiper(
                      indicatorLayout: PageIndicatorLayout.COLOR,
                      autoplay: true,
                      pagination: const SwiperPagination(), // 分页指示器
                      control: const SwiperControl(), // 左右两侧控制按钮
                      itemCount: vm.bannerList.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(15.r),
                          child: Image.network(
                            vm.bannerList[index].imagePath ?? "",
                            fit: BoxFit.fill,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              Container(
                margin: EdgeInsets.only(left: 20.w, bottom: 15.h),
                alignment: Alignment.centerLeft,
                child: Text(
                  "垃圾识别",
                  style:
                      TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 30.w, right: 30.w),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final imageSource = await _showPickerDialog(context);
                        if (imageSource == null) {
                          return;
                        }

                        final image = await _pickImage(imageSource);
                        if (image == null) {
                          return;
                        }

                        final rubbish = await _predict(image);
                        if (rubbish == null) {
                          return;
                        }

                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return RecognizationResultPage(
                                  rubbishName: rubbish,
                                  imagePath: image.path,
                                );
                              },
                            ),
                          );
                        }
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/camera.png",
                            width: 35.r,
                            height: 35.r,
                          ),
                          SizedBox(height: 10.h),
                          Text("图像识别", style: TextStyle(fontSize: 16.sp))
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, RoutePath.recordPage);
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/microphone.png",
                            width: 35.r,
                            height: 35.r,
                          ),
                          SizedBox(height: 10.h),
                          Text("语言搜索", style: TextStyle(fontSize: 16.sp)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/collection.png",
                            width: 35.r,
                            height: 35.r,
                          ),
                          SizedBox(height: 10.h),
                          Text("识别收藏", style: TextStyle(fontSize: 16.sp)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 15.h),
              Container(
                margin: EdgeInsets.only(left: 20.w, bottom: 5.h),
                alignment: Alignment.centerLeft,
                child: Text(
                  "垃圾分类",
                  style:
                      TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (coutext) {
                              return const RubbishTypeDescPage(type: 3);
                            },
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 15.w, top: 10.h),
                        child: Stack(
                          children: [
                            Image.asset(
                              "assets/images/solid_waste.png",
                            ),
                            Positioned(
                              top: 35.h,
                              left: 15.w,
                              child: Text(
                                "干垃圾",
                                style: TextStyle(
                                    fontSize: 16.sp, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const RubbishTypeDescPage(type: 2);
                            },
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 15.w, top: 10.h),
                        child: Stack(
                          children: [
                            Image.asset(
                              "assets/images/food_waste.png",
                            ),
                            Positioned(
                              top: 35.h,
                              left: 15.w,
                              child: Text(
                                "湿垃圾",
                                style: TextStyle(
                                    fontSize: 16.sp, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const RubbishTypeDescPage(type: 0);
                            },
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 15.w),
                        child: Stack(
                          children: [
                            Image.asset(
                              "assets/images/recyclable_waste.png",
                            ),
                            Positioned(
                              top: 35.h,
                              left: 15.w,
                              child: Text(
                                "可回收物",
                                style: TextStyle(
                                    fontSize: 16.sp, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const RubbishTypeDescPage(type: 1);
                            },
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 15.w),
                        child: Stack(
                          children: [
                            Image.asset(
                              "assets/images/harmful_waste.png",
                            ),
                            Positioned(
                              top: 35.h,
                              left: 15.w,
                              child: Text(
                                "有害垃圾",
                                style: TextStyle(
                                    fontSize: 16.sp, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
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

  Future<File?> _pickImage(ImageSource source) async {
    final returnImage = await ImagePicker().pickImage(source: source);

    if (returnImage != null) {
      final croppedImage = await _cropImage(returnImage);

      return File(croppedImage.path);
    }

    return null;
  }

  Future<CroppedFile> _cropImage(XFile image) async {
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: image.path,
      uiSettings: [
        AndroidUiSettings(
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          toolbarColor: Colors.white,
          toolbarTitle: "图片裁剪",
          toolbarWidgetColor: Colors.black,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        )
      ],
    );

    return croppedImage!;
  }

  Future<String?> _predict(File file) async {
    final image = image_lib.decodeImage(file.readAsBytesSync())!;

    final result = await _imageHelper.inferenceImage(image);

    final sortedList = result.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sortedMap = Map.fromEntries(sortedList);

    final resultEn = sortedMap.keys.first;
    final resultEnIdx =
        _imageHelper.labelsEn.indexWhere((item) => item == resultEn);

    if (resultEnIdx < 400) {
      showToast("识别失败");
      return null;
    }

    final resultZh = _imageHelper.labensZh[resultEnIdx - 400 + 1];

    return resultZh;
  }
}
