import 'package:flutter/material.dart';
import 'package:flutter_custom_tab_bar/custom_tab_bar.dart';
import 'package:flutter_custom_tab_bar/library.dart';

import 'page_item.dart';

class StandardTabBarPage extends StatefulWidget {
  StandardTabBarPage({Key? key}) : super(key: key);

  @override
  _StandardTabBarPageState createState() => _StandardTabBarPageState();
}

class _StandardTabBarPageState extends State<StandardTabBarPage> {
  final int pageCount = 20;
  final PageController _controller = PageController();

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
                    padding: EdgeInsets.all(2),
                    alignment: Alignment.center,
                    constraints: BoxConstraints(minWidth: 70),
                    child: (Text(
                      index == 5 ? 'Tab555555555555' : 'Tab$index',
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
          CustomTabBar(
            initialIndex: 0,
            height: 35,
            width: 200,
            // physics: NeverScrollableScrollPhysics(),
            itemCount: pageCount,
            builder: getTabbarChild,
            indicator: StandardIndicator(
              width: 20,
              height: 2,
              color: Colors.green,
            ),
            pageController: _controller,
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
