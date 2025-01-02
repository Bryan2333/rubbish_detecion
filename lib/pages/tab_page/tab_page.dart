import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';
import 'package:rubbish_detection/pages/discovery_page/discovery_page.dart';
import 'package:rubbish_detection/pages/home_page/home_page.dart';
import 'package:rubbish_detection/pages/personal_page/personal_page.dart';

class TabPage extends StatefulWidget {
  const TabPage({super.key});

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  final _currentIndexNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _currentIndexNotifier,
      builder: (context, currentIndex, child) {
        return Scaffold(
          body: SafeArea(
            child: LazyLoadIndexedStack(
              index: currentIndex,
              children: const [
                HomePage(),
                DiscoveryPage(),
                PersonalPage(),
              ],
            ),
          ),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: TextStyle(fontSize: 14.sp), // 选中的样式
              unselectedLabelStyle: TextStyle(fontSize: 12.sp), // 未选中的样式
              currentIndex: currentIndex,
              items: _buildBarList(),
              // 点击切换页面
              // index是children中元素的下标
              onTap: (index) => _currentIndexNotifier.value = index,
            ),
          ),
        );
      },
    );
  }

  List<BottomNavigationBarItem> _buildBarList() {
    return [
      _buildBarItem(
        "首页",
        "assets/images/home_icon_unselect.png",
        "assets/images/home_icon_selected.png",
      ),
      _buildBarItem(
        "发现",
        "assets/images/discovery_icon_unselect.png",
        "assets/images/discovery_icon_selected.png",
      ),
      _buildBarItem(
        "我的",
        "assets/images/personal_icon_unselect.png",
        "assets/images/personal_icon_selected.png",
      ),
    ];
  }

  BottomNavigationBarItem _buildBarItem(
      String label, String iconPath, String activeIconPath) {
    return BottomNavigationBarItem(
      label: label,
      activeIcon: Image.asset(
        activeIconPath,
        width: 25.r,
        height: 25.r,
      ),
      icon: Image.asset(
        iconPath,
        width: 25.r,
        height: 25.r,
      ),
    );
  }
}
