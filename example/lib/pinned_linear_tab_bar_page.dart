import 'package:flutter/material.dart';
import 'package:flutter_custom_tab_bar/library.dart';

import 'page_item.dart';

class PinnedLinearTabBarPage extends StatefulWidget {
  PinnedLinearTabBarPage({Key? key}) : super(key: key);

  @override
  _PinnedLinearTabBarPageState createState() => _PinnedLinearTabBarPageState();
}

class _PinnedLinearTabBarPageState extends State<PinnedLinearTabBarPage> {
  PageController pageController = PageController();
  CustomTabBarController _tabBarController = CustomTabBarController();

  @override
  void initState() {
    super.initState();
  }

  Widget getTabbarChild(BuildContext context, int index) {
    return TabBarItem(
        index: index,
        transform: ScaleTransform(
            maxScale: 1.3,
            transform: ColorsTransform(
              normalColor: Colors.black,
              highlightColor: Colors.green,
              builder: (context, color) {
                return Container(
                    padding: EdgeInsets.all(12),
                    alignment: Alignment.center,
                    constraints: BoxConstraints(minWidth: 70),
                    child: (Text(
                      index == 5 ? 'Tab555' : 'Tab$index',
                      style: TextStyle(
                        fontSize: 14,
                        color: color,
                      ),
                    )));
              },
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Pinned Linear Indicator')),
        body: Column(
          children: [
            CustomTabBar(
                tabBarController: _tabBarController,
                builder: getTabbarChild,
                pinned: true,
                width: 140,
                // height: 50,
                pageController: pageController,
                indicator: LinearIndicator(
                    color: Colors.blue,
                    height: 3,
                    bottom: 5,
                    width: 20,
                    radius: BorderRadius.circular(2)),
                itemCount: 2),
            Expanded(
                child: PageView(
              children: [
                PageItem(0),
                PageItem(1),
              ],
              controller: pageController,
            ))
          ],
        ));
  }
}
