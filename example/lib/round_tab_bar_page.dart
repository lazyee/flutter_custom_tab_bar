import 'package:flutter/material.dart';
import 'package:flutter_custom_tab_bar/library.dart';

import 'page_item.dart';

class RoundTabBarPage extends StatefulWidget {
  RoundTabBarPage({Key? key}) : super(key: key);

  @override
  _RoundTabBarPageState createState() => _RoundTabBarPageState();
}

class _RoundTabBarPageState extends State<RoundTabBarPage> {
  final int pageCount = 4;
  late PageController _controller = PageController(initialPage: 3);
  CustomTabBarController _tabBarController = CustomTabBarController();

  @override
  void initState() {
    super.initState();
  }

  Widget getTabbarChild(BuildContext context, int index) {
    return TabBarItem(
        transform: ColorsTransform(
            highlightColor: Colors.white,
            normalColor: Colors.black,
            builder: (context, color) {
              return Container(
                padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                alignment: Alignment.center,
                constraints: BoxConstraints(minWidth: 60),
                child: (Text(
                  index == 2 ? 'Tab522222' : 'Tab$index',
                  style: TextStyle(fontSize: 14, color: color),
                )),
              );
            }),
        index: index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Round Indicator')),
      body: Column(
        children: [
          CustomTabBar(
            tabBarController: _tabBarController,
            height: 35,
            itemCount: pageCount,
            builder: getTabbarChild,
            indicator: RoundIndicator(
              color: Colors.red,
              top: 2.5,
              bottom: 2.5,
              left: 2.5,
              right: 2.5,
              radius: BorderRadius.circular(15),
            ),
            pageController: _controller,
          ),
          Expanded(
              child: PageView.builder(
                  controller: _controller,
                  itemCount: pageCount,
                  itemBuilder: (context, index) {
                    return PageItem(index);
                  })),
          TextButton(
              onPressed: () {
                _tabBarController.animateToIndex(3);
              },
              child: Text('gogogo'))
        ],
      ),
    );
  }
}
