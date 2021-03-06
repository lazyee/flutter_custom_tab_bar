import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_custom_tab_bar/custom_tab_bar.dart';
import 'package:flutter_custom_tab_bar/delegate/color_transform_delegte.dart';
import 'package:flutter_custom_tab_bar/delegate/scale_transform_delegate.dart';
import 'package:flutter_custom_tab_bar/indicator/standard_indicator.dart';
import 'package:flutter_custom_tab_bar/tab_bar_item.dart';
import 'package:flutter_custom_tab_bar/tab_bar_item_info.dart';

import 'page_item.dart';

class StandardTabBarPage extends StatefulWidget {
  StandardTabBarPage({Key key}) : super(key: key);

  @override
  _StandardTabBarPageState createState() => _StandardTabBarPageState();
}

class _StandardTabBarPageState extends State<StandardTabBarPage> {
  final int pageCount = 20;
  final PageController _controller = PageController();
  StandardIndicatorController controller = StandardIndicatorController();

  Widget getTabbarChild(BuildContext context, TabBarItemInfo data) {
    return TabBarItem(
        tabbarItemInfo: data,
        delegate: ScaleTransformDelegate(
            maxScale: 1.3,
            delegate: ColorTransformDelegate(
              normalColor: Colors.black,
              highlightColor: Colors.green,
              builder: (context, color) {
                return Container(
                    padding: EdgeInsets.all(2),
                    alignment: Alignment.center,
                    constraints: BoxConstraints(minWidth: 70),
                    child: (Text(
                      data.itemIndex == 5
                          ? 'Tab555555555555'
                          : 'Tab${data.itemIndex}',
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
      appBar: AppBar(title: Text('Standard Indicator')),
      body: Column(
        children: [
          Container(
            height: 35,
            child: CustomTabBar(
              defaultPage: 0,
              itemCount: pageCount,
              builder: getTabbarChild,
              indicator: StandardIndicator(
                indicatorWidth: 20,
                indicatorColor: Colors.green,
                controller: controller,
              ),
              pageController: _controller,
              tabbarController: controller,
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
