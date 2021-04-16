import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_custom_tab_bar/custom_tab_bar.dart';
import 'package:flutter_custom_tab_bar/indicator/linear_indicator.dart';
import 'package:flutter_custom_tab_bar/tab_item_data.dart';

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

  Widget getTabbarChild(BuildContext context, TabItemData data) {
    return LinearTabItem(
        child: Container(
          padding: EdgeInsets.all(2),
          alignment: Alignment.center,
          constraints: BoxConstraints(minWidth: 60),
          child: (Text(
            data.itemIndex == 5 ? 'Tab555555555555' : 'Tab${data.itemIndex}',
            style: TextStyle(
              fontSize: 14,
              color: data.currentIndex == data.itemIndex
                  ? Colors.pink
                  : Colors.black,
            ),
          )),
        ),
        data: data);
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
              tabIndicator: LinearIndicator(
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
