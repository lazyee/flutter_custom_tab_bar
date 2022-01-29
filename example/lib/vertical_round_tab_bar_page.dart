import 'package:flutter/material.dart';
import 'package:flutter_custom_tab_bar/library.dart';

import 'page_item.dart';

class VerticalRoundTabBarPage extends StatefulWidget {
  VerticalRoundTabBarPage({Key? key}) : super(key: key);

  @override
  _VerticalRoundTabBarPageState createState() =>
      _VerticalRoundTabBarPageState();
}

class _VerticalRoundTabBarPageState extends State<VerticalRoundTabBarPage> {
  final int pageCount = 30;
  late PageController _controller = PageController(initialPage: 0);
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
                constraints: BoxConstraints(minHeight: 35),
                child: (Text(
                  index == 2 ? 'Tab22222222222222222' : 'Tab$index',
                  style: TextStyle(fontSize: 14, color: color),
                )),
              );
            }),
        index: index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vertical Round Indicator')),
      body: Row(
        children: [
          CustomTabBar(
            tabBarController: _tabBarController,
            width: 80,
            direction: Axis.vertical,
            itemCount: pageCount,
            builder: getTabbarChild,
            indicator: RoundIndicator(
              color: Colors.red,
              top: 2.5,
              bottom: 2.5,
              left: 2.5,
              right: 2.5,
              radius: BorderRadius.circular(5),
            ),
            pageController: _controller,
          ),
          Expanded(
              child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  controller: _controller,
                  itemCount: pageCount,
                  itemBuilder: (context, index) {
                    return PageItem(index);
                  })),
        ],
      ),
    );
  }
}
