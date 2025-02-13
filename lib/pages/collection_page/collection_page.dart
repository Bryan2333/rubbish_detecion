import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:rubbish_detection/pages/auth_page/auth_vm.dart';
import 'package:rubbish_detection/pages/collection_page/collection_vm.dart';
import 'package:rubbish_detection/pages/recognization_result_page/recognization_result_page.dart';
import 'package:rubbish_detection/repository/data/recognition_collection_bean.dart';
import 'package:rubbish_detection/utils/custom_helper.dart';
import 'package:rubbish_detection/utils/route_helper.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage>
    with SingleTickerProviderStateMixin {
  final _collectionViewModel = CollectionViewModel();
  final _dateFormatter = DateFormat("yyyy-MM-ddTHH:mm:ss");

  late RefreshController _refreshController;

  Color _getTypeColor(int? type) {
    return switch (type) {
      0 => const Color(0xFFFFA721),
      1 => const Color(0xFF4DB8FF),
      2 => const Color(0xFF1ADFCC),
      3 => const Color(0xFFFF7396),
      _ => Colors.grey
    };
  }

  String _getTypeIcon(int? type) {
    return switch (type) {
      0 => "assets/images/solid_waste_3.png",
      1 => "assets/images/food_waste_3.png",
      2 => "assets/images/recyclable_waste_3.png",
      3 => "assets/images/harmful_waste_3.png",
      _ => ""
    };
  }

  String _getTypeName(int? type) {
    return switch (type) {
      0 => "干垃圾",
      1 => "湿垃圾",
      2 => "可回收物",
      3 => "有害垃圾",
      _ => ""
    };
  }

  Future<void> _refreshOrLoad({bool isLoad = false}) async {
    final userId =
        await Provider.of<AuthViewModel>(context, listen: false).getUserId();

    if (isLoad) {
      _collectionViewModel.getCollections(userId: userId, loadMore: true);
      _refreshController.loadComplete();
    } else {
      _collectionViewModel.getCollections(userId: userId, loadMore: false);
      _refreshController.refreshCompleted();
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    _refreshOrLoad();
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
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        "识别收藏",
        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios),
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

  Widget _buildCollectionsList(List<RecognitionCollectionBean> collections) {
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

  Widget _buildCollectionCard(RecognitionCollectionBean collection) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 8.r,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            RouteHelper.push(
              context,
              RecognizationResultPage(
                  rubbishName: collection.rubbishName ?? "",
                  imagePath: collection.image,
                  isCollected: true),
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                // 左侧统一显示圆形区域
                _buildImageField(collection),
                // 右侧信息布局保持不变
                _buildInfoField(collection),
                IconButton(
                  icon: Icon(Icons.favorite, color: Colors.red, size: 24.r),
                  onPressed: () => _handleUnCollect(collection),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageField(RecognitionCollectionBean collection) {
    return Container(
      width: 80.w,
      height: 80.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getTypeColor(collection.rubbishType),
      ),
      child: collection.image != null
          // 有图片时显示圆形图片
          ? CachedNetworkImage(
              imageUrl: collection.image!,
              imageBuilder: (context, imageProvider) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  const CircularProgressIndicator(color: Color(0xFF00CE68)),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.broken_image_outlined, color: Colors.grey),
            )
          // 无图片时显示类型图标
          : Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(15.r),
              child: Image.asset(_getTypeIcon(collection.rubbishType)),
            ),
    );
  }

  Widget _buildInfoField(RecognitionCollectionBean collection) {
    final DateTime(:year, :month, :day, :hour, :minute) =
        _dateFormatter.parse(collection.createdAt!);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            collection.rubbishName!,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _getTypeColor(collection.rubbishType!)
                  .withValues(alpha: 0.15),
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
            "$year年$month月$day日 $hour:$minute",
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _handleUnCollect(RecognitionCollectionBean collection) async {
    await CustomHelper.executeAsyncCall(
      context: context,
      futureCall: _collectionViewModel.unCollect(collection),
      successMessage: "取消收藏成功",
      failurePrefix: "取消收藏失败",
      successCondition: (result) => result ?? false,
    );
  }
}
