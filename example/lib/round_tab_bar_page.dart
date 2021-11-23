import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_custom_tab_bar/custom_tab_bar.dart';
import 'package:flutter_custom_tab_bar/delegate/color_transform_delegte.dart';
import 'package:flutter_custom_tab_bar/indicator/round_indicator.dart';
import 'package:flutter_custom_tab_bar/tab_bar_item.dart';
import 'package:flutter_custom_tab_bar/tab_bar_item_info.dart';

import 'page_item.dart';

class RoundTabBarPage extends StatefulWidget {
  RoundTabBarPage({Key? key}) : super(key: key);

  @override
  _RoundTabBarPageState createState() => _RoundTabBarPageState();
}

class _RoundTabBarPageState extends State<RoundTabBarPage> {
  final int pageCount = 20;
  final PageController _controller = PageController();
  final RoundIndicatorController _roundIndicatorController =
      RoundIndicatorController();

  Widget getTabbarChild(BuildContext context, TabBarItemInfo data) {
    return TabBarItem(
        delegate: ColorTransformDelegate(
            highlightColor: Colors.white,
            normalColor: Colors.black,
            builder: (context, color) {
              return Container(
                padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                alignment: Alignment.center,
                constraints: BoxConstraints(minWidth: 60),
                child: (Text(
                  data.itemIndex == 5
                      ? 'Tab555555555555'
                      : 'Tab${data.itemIndex}',
                  style: TextStyle(fontSize: 14, color: color),
                )),
              );
            }),
        tabbarItemInfo: data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Round Indicator')),
      body: Column(
        children: [
          CustomTabBar(
            initPage: 0,
            height: 35,
            itemCount: pageCount,
            builder: getTabbarChild,
            indicator: RoundIndicator(
              color: Colors.red,
              top: 2.5,
              bottom: 2.5,
              radius: 15,
              controller: _roundIndicatorController,
            ),
            pageController: _controller,
            controller: _roundIndicatorController,
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
