import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_custom_tab_bar/custom_tab_bar.dart';
import 'package:flutter_custom_tab_bar/delegate/color_transform_delegte.dart';
import 'package:flutter_custom_tab_bar/indicator/linear_indicator.dart';
import 'package:flutter_custom_tab_bar/tab_bar_item.dart';
import 'package:flutter_custom_tab_bar/tab_bar_item_info.dart';

import 'page_item.dart';

class LinearTabBarPage extends StatefulWidget {
  LinearTabBarPage({Key key}) : super(key: key);

  @override
  _LinearTabBarPageState createState() => _LinearTabBarPageState();
}

class _LinearTabBarPageState extends State<LinearTabBarPage> {
  final int pageCount = 20;
  final PageController _controller = PageController();
  final LinearIndicatorController _linearIndicatorController =
      LinearIndicatorController();

  Widget getTabbarChild(BuildContext context, TabBarItemInfo info) {
    return TabBarItem(
      tabbarItemInfo: info,
      delegate: ColorTransformDelegate(
          highlightColor: Colors.pink,
          normalColor: Colors.black,
          builder: (context, color) {
            return Container(
              padding: EdgeInsets.all(2),
              alignment: Alignment.center,
              constraints: BoxConstraints(minWidth: 60),
              child: (Text(
                info.itemIndex == 5
                    ? 'Tab555555555555'
                    : 'Tab${info.itemIndex}',
                style: TextStyle(fontSize: 14, color: color),
              )),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Linear Indicator')),
      body: Column(
        children: [
          Container(
            height: 35,
            child: CustomTabBar(
              defaultPage: 0,
              itemCount: pageCount,
              builder: getTabbarChild,
              indicator: LinearIndicator(
                indicatorColor: Colors.pink,
                controller: _linearIndicatorController,
              ),
              pageController: _controller,
              tabbarController: _linearIndicatorController,
            ),
          ),
          Expanded(
              child: PageView.builder(
                  controller: _controller,
                  itemCount: pageCount,
                  itemBuilder: (context, index) {
                    return PageItem(index);
                  }))
        ],
      ),
    );
  }
}
