import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:provider/provider.dart';
import 'package:rubbish_detection/pages/auth_page/auth_vm.dart';
import 'package:rubbish_detection/pages/collection_page/collection_page.dart';
import 'package:rubbish_detection/pages/record_page/record_page.dart';
import 'package:rubbish_detection/utils/custom_helper.dart';
import 'package:rubbish_detection/utils/image_classification_helper.dart';
import 'package:image/image.dart' as image_lib;
import 'package:rubbish_detection/pages/home_page/home_vm.dart';
import 'package:rubbish_detection/pages/recognization_result_page/recognization_result_page.dart';
import 'package:rubbish_detection/pages/rubbish_type_desc_page/rubbish_type_desc_page.dart';
import 'package:rubbish_detection/utils/image_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _homeViewModel = HomeViewModel();
  final _imageClassificationHelper = ImageClassificationHelper.instance;

  final _categoryCards = [
    {"title": "干垃圾", "image": "assets/images/solid_waste.png", "type": 0},
    {"title": "湿垃圾", "image": "assets/images/food_waste.png", "type": 1},
    {"title": "可回收物", "image": "assets/images/recyclable_waste.png", "type": 2},
    {"title": "有害垃圾", "image": "assets/images/harmful_waste.png", "type": 3},
  ];

  late TextEditingController _searchBarController;
  late ValueNotifier<bool> _hasTextNotifier;

  @override
  void initState() {
    super.initState();

    _homeViewModel.getBannerData();

    _hasTextNotifier = ValueNotifier(false);

    _searchBarController = TextEditingController();
    _searchBarController.addListener(() {
      _hasTextNotifier.value = _searchBarController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _searchBarController.dispose();
    _hasTextNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "垃圾分类助手",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: ChangeNotifierProvider(
        create: (context) => _homeViewModel,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 搜索栏
              SliverToBoxAdapter(child: _buildSearchBar()),
              // 横幅
              SliverToBoxAdapter(child: _buildBanner()),
              // 识别功能区
              SliverToBoxAdapter(child: _buildRecognitionSection()),
              // 垃圾分类指南
              SliverToBoxAdapter(child: _buildCategorySection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchBarController,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: "搜索垃圾分类",
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            size: 24.r,
            color: const Color(0xFF00CE68),
          ),
          suffixIcon: ValueListenableBuilder(
            valueListenable: _hasTextNotifier,
            builder: (context, hasText, child) {
              return Visibility(
                visible: hasText,
                child: IconButton(
                  onPressed: _searchBarController.clear,
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[600],
                  ),
                ),
              );
            },
          ),
        ),
        onSubmitted: _onSearchSubmitted,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      ),
    );
  }

  void _onSearchSubmitted(query) {
    if (query.trim().isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return RecognizationResultPage(
            rubbishName: query,
            imagePath: null,
          );
        },
      ),
    );
  }

  Widget _buildBanner() {
    return Consumer<HomeViewModel>(
      builder: (context, vm, child) {
        return Container(
          margin: EdgeInsets.only(left: 16.w, right: 16.w),
          height: 160.h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Swiper(
              itemCount: vm.bannerList.length,
              autoplay: true,
              controller: SwiperController(),
              pagination: SwiperPagination(
                margin: EdgeInsets.only(bottom: 12.h),
                builder: DotSwiperPaginationBuilder(
                  activeColor: const Color(0xFF00CE68),
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 8.r,
                  activeSize: 8.r,
                ),
              ),
              itemBuilder: (context, index) {
                return Image.network(
                  vm.bannerList[index].imagePath ?? "",
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 50.r,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecognitionSection() {
    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "智能识别",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFeatureItem(
                icon: "assets/images/camera.png",
                title: "图像识别",
                onTap: _imageRecognition,
              ),
              _buildFeatureItem(
                icon: "assets/images/microphone.png",
                title: "语音搜索",
                onTap: _navigateToRecordPage,
              ),
              _buildFeatureItem(
                icon: "assets/images/collection.png",
                title: "识别收藏",
                onTap: _navigateToCollectionPage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToRecordPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return const RecordPage();
        },
      ),
    );
  }

  void _navigateToCollectionPage() async {
    if (!await Provider.of<AuthViewModel>(context, listen: false).isLogged()) {
      if (!mounted) return;
      CustomHelper.showSnackBar(context, "请先登录", success: false);
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return const CollectionPage();
        },
      ),
    );
  }

  Widget _buildFeatureItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: const Color(0xFF00CE68).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              icon,
              width: 28.r,
              height: 28.r,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题部分
          Container(
            padding: EdgeInsets.all(16.r),
            child: Text(
              "垃圾分类指南",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          // 分类卡片网格
          Container(
            padding: EdgeInsets.only(
              left: 16.r,
              right: 16.r,
              bottom: 16.r,
              top: 0,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
              ),
              itemCount: _categoryCards.length,
              itemBuilder: (context, index) {
                return _buildCategoryCard(
                  title: _categoryCards[index]["title"] as String,
                  imagePath: _categoryCards[index]["image"] as String,
                  onTap: () => _navigateToRubbishDescPage(
                      _categoryCards[index]["type"] as int),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRubbishDescPage(int type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return RubbishTypeDescPage(type: type);
        },
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
              // 分类标题
              Positioned(
                left: 16.w,
                bottom: 16.h,
                child: Row(
                  children: [
                    Container(
                      width: 4.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00CE68),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _imageRecognition() async {
    final imageSource = await ImageHelper.showPickerDialog(context);
    if (imageSource == null) return;

    final image = await ImageHelper.pickImage(source: imageSource);
    if (image == null) return;

    final rubbish = await _predict(image);
    if (rubbish == null) return;

    if (mounted == false) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return RecognizationResultPage(
            rubbishName: rubbish,
            imagePath: image.path,
          );
        },
      ),
    );
  }

  Future<String?> _predict(File file) async {
    final image = image_lib.decodeImage(file.readAsBytesSync());
    if (image == null) return null;

    final result = await _imageClassificationHelper.inferenceImage(image);

    final sortedResults = result.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedResults.isEmpty) return null;

    final topResult = sortedResults.first.key;
    final topIndex = _imageClassificationHelper.labelsEn.indexOf(topResult);

    if (topIndex < 400) {
      if (mounted) {
        CustomHelper.showSnackBar(context, "识别失败，请重新尝试", success: false);
      }
      return null;
    }

    return _imageClassificationHelper.labelsZh[topIndex - 399];
  }
}
