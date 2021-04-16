import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_custom_tab_bar/custom_tab_bar.dart';
import 'package:flutter_custom_tab_bar/indicator/round_indicator.dart';
import 'package:flutter_custom_tab_bar/tab_item_data.dart';

import 'page_item.dart';

class RoundTabBarPage extends StatefulWidget {
  RoundTabBarPage({Key key}) : super(key: key);

  @override
  _RoundTabBarPageState createState() => _RoundTabBarPageState();
}

class _RoundTabBarPageState extends State<RoundTabBarPage> {
  final int pageCount = 20;
  final PageController _controller = PageController();
  final RoundIndicatorController _roundIndicatorController =
      RoundIndicatorController();

  Widget getTabbarChild(BuildContext context, TabItemData data) {
    return RoundTabItem(
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
          alignment: Alignment.center,
          constraints: BoxConstraints(minWidth: 60),
          child: (Text(
            data.itemIndex == 5 ? 'Tab555555555555' : 'Tab${data.itemIndex}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          )),
        ),
        data: data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Round Indicator')),
      body: Column(
        children: [
          Container(
            height: 35,
            child: CustomTabBar(
              defaultPage: 0,
              itemCount: pageCount,
              builder: getTabbarChild,
              tabIndicator: RoundIndicator(
                indicatorColor: Colors.red,
                top: 2.5,
                bottom: 2.5,
                radius: 15,
                controller: _roundIndicatorController,
              ),
              pageController: _controller,
              tabbarController: _roundIndicatorController,
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
