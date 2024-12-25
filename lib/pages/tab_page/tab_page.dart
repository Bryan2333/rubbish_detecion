import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/pages/discovery_page/discovery_page.dart';
import 'package:rubbish_detection/pages/home_page/home_page.dart';
import 'package:rubbish_detection/pages/personal_page/personal_page.dart';

class TabPage extends StatefulWidget {
  const TabPage({super.key});

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  int currentIdx = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: currentIdx,
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
          currentIndex: currentIdx,
          items: _barItemList(),
          // 点击切换页面
          // index是children中元素的下标
          onTap: (index) {
            setState(() {
              currentIdx = index;
            });
          },
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _barItemList() {
    return [
      BottomNavigationBarItem(
        label: "首页",
        activeIcon: Image.asset(
          "assets/images/home_icon_selected.png",
          width: 25.r,
          height: 25.r,
        ),
        icon: Image.asset(
          "assets/images/home_icon_unselect.png",
          width: 25.r,
          height: 25.r,
        ),
      ),
      BottomNavigationBarItem(
        label: "发现",
        activeIcon: Image.asset(
          "assets/images/discovery_icon_selected.png",
          width: 25.r,
          height: 25.r,
        ),
        icon: Image.asset(
          "assets/images/discovery_icon_unselect.png",
          width: 25.r,
          height: 25.r,
        ),
      ),
      BottomNavigationBarItem(
        label: "我的",
        activeIcon: Image.asset(
          "assets/images/personal_icon_selected.png",
          width: 25.r,
          height: 25.r,
        ),
        icon: Image.asset(
          "assets/images/personal_icon_unselect.png",
          width: 25.r,
          height: 25.r,
        ),
      )
    ];
  }
}
