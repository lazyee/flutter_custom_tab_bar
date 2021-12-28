import 'package:flutter/material.dart';
import 'package:flutter_custom_tab_bar/library.dart';

import 'page_item.dart';

class LinearTabBarPage extends StatefulWidget {
  LinearTabBarPage({Key? key}) : super(key: key);

  @override
  _LinearTabBarPageState createState() => _LinearTabBarPageState();
}

class _LinearTabBarPageState extends State<LinearTabBarPage> {
  final int pageCount = 4;
  final PageController _controller = PageController(initialPage: 3);

  Widget getTabbarChild(BuildContext context, int index) {
    return TabBarItem(
      index: index,
      transform: ColorsTransform(
          highlightColor: Colors.pink,
          normalColor: Colors.black,
          builder: (context, color) {
            return Container(
              padding: EdgeInsets.all(2),
              alignment: Alignment.center,
              constraints: BoxConstraints(minWidth: 60),
              child: (Text(
                index == 5 ? 'Tab555555555555' : 'Tab$index',
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
          CustomTabBar(
            height: 35,
            itemCount: pageCount,
            builder: getTabbarChild,
            indicator: LinearIndicator(color: Colors.pink, bottom: 5),
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
