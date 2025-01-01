import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:rubbish_detection/pages/collection_page/collection_vm.dart';
import 'package:rubbish_detection/pages/recognization_result_page/recognization_result_page.dart';

class RecognitionCollection {
  final int id;
  final String rubbishName;
  final String? imagePath;
  final int rubbishType;
  final DateTime createdTime;
  final bool isDeleted;

  RecognitionCollection({
    required this.id,
    required this.rubbishName,
    this.imagePath,
    required this.rubbishType,
    required this.createdTime,
    required this.isDeleted,
  });
}

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage>
    with SingleTickerProviderStateMixin {
  final _collectionViewModel = CollectionViewModel();
  final _dateFormatter = DateFormat('yyyy-MM-dd HH:mm');

  late RefreshController _refreshController;

  Color _getTypeColor(int type) {
    return switch (type) {
      0 => const Color(0xFFFFA721),
      1 => const Color(0xFF4DB8FF),
      2 => const Color(0xFF1ADFCC),
      3 => const Color(0xFFFF7396),
      _ => Colors.grey
    };
  }

  String _getTypeIcon(int type) {
    return switch (type) {
      0 => "assets/images/solid_waste_3.png",
      1 => "assets/images/food_waste_3.png",
      2 => "assets/images/recyclable_waste_3.png",
      3 => "assets/images/harmful_waste_3.png",
      _ => ""
    };
  }

  String _getTypeName(int type) {
    return switch (type) {
      0 => "干垃圾",
      1 => "湿垃圾",
      2 => "可回收物",
      3 => "有害垃圾",
      _ => ""
    };
  }

  Future<void> _refreshOrLoad({required isLoad}) async {
    if (isLoad) {
      // TODO: 在CollectionViewModel中实现加载更多逻辑
      await Future.delayed(const Duration(milliseconds: 500));
      _refreshController.loadComplete();
    } else {
      // TODO: 在CollectionViewModel中实现刷新逻辑
      await Future.delayed(const Duration(milliseconds: 500));
      _refreshController.refreshCompleted();
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    _collectionViewModel.getCollections();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _collectionViewModel,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            "识别收藏",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onLoading: () => _refreshOrLoad(isLoad: true),
          onRefresh: () => _refreshOrLoad(isLoad: false),
          header: const WaterDropMaterialHeader(
            backgroundColor: Colors.white,
            color: Color(0xFF00CE68),
          ),
          child: Consumer<CollectionViewModel>(
            builder: (context, vm, child) {
              if (vm.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00CE68)),
                );
              } else if (vm.collections.isEmpty) {
                return _buildEmptyState();
              } else {
                return _buildCollectionsList(vm.collections);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64.r,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            "暂无收藏记录",
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsList(List<RecognitionCollection> collections) {
    return SingleChildScrollView(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.r),
        itemCount: collections.length,
        itemBuilder: (context, index) {
          return _buildCollectionCard(collections[index]);
        },
      ),
    );
  }

  Widget _buildCollectionCard(RecognitionCollection collection) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecognizationResultPage(
                  rubbishName: collection.rubbishName,
                  imagePath: collection.imagePath,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                // 左侧统一显示圆形区域
                Container(
                  width: 80.w,
                  height: 80.w,
                  margin: EdgeInsets.only(right: 16.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getTypeColor(collection.rubbishType),
                  ),
                  child: collection.imagePath != null
                      // 有图片时显示圆形图片
                      ? ClipOval(
                          child: Image.asset(
                            collection.imagePath!,
                            fit: BoxFit.cover,
                          ),
                        )
                      // 无图片时显示类型图标
                      : Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(15.r),
                          child:
                              Image.asset(_getTypeIcon(collection.rubbishType)),
                        ),
                ),
                // 右侧信息布局保持不变
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        collection.rubbishName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor(collection.rubbishType)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          _getTypeName(collection.rubbishType),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: _getTypeColor(collection.rubbishType),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _dateFormatter.format(collection.createdTime),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.favorite, color: Colors.red, size: 24.r),
                  onPressed: () async {
                    if (await _collectionViewModel.unCollect(collection)) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF00CE68),
                            content: Text(
                              "取消收藏成功",
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
