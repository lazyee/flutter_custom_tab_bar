import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_custom_tab_bar/library.dart';

import 'custom_tab_bar.dart';

class TabBarItemRow extends StatefulWidget {
  final double? viewPortWidth;
  final int itemCount;
  final IndexedWidgetBuilder builder;
  final List<TabBarItemInfo> tabBarItemInfoList;
  final ValueChanged<int> onTapItem;
  final ScrollPhysics physics;
  final CustomTabBarController controller;
  TabBarItemRow(
      {required this.viewPortWidth,
      required this.itemCount,
      required this.builder,
      required this.tabBarItemInfoList,
      required this.onTapItem,
      required this.physics,
      required this.controller,
      key})
      : super(key: key);

  @override
  TabBarItemRowState createState() => TabBarItemRowState();
}

class TabBarItemRowState extends State<TabBarItemRow> {
  void updateSelectedIndex() {
    widget.controller.updateSelectedIndex(this);
  }

  ///通知更新
  void notifyUpdate(double? page) {
    setState(() {});
  }

  Widget _createItem(int index, Widget child) {
    return InkWell(onTap: () => widget.onTapItem(index), child: child);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];

    ///如果不能滑动就平分父级组件宽度
    if (widget.physics is NeverScrollableScrollPhysics) {
      double? itemWidth = (widget.viewPortWidth ?? 0) / widget.itemCount;
      for (var i = 0; i < widget.itemCount; i++) {
        widgetList.add(_createItem(
            i,
            Container(
              width: itemWidth,
              child: widget.builder(context, i),
            )));
        widget.tabBarItemInfoList[i].size = Size(itemWidth, 0);
      }
    } else {
      for (var i = 0; i < widget.itemCount; i++) {
        widgetList.add(_createItem(
            i,
            MeasureSizeBox(
              child: widget.builder(context, i),
              onSizeCallback: (size) {
                widget.tabBarItemInfoList[i].size = size;
              },
            )));
      }
    }

    return Row(children: widgetList);
  }
}

class MeasureSizeBox extends SingleChildRenderObjectWidget {
  final Widget child;
  final ValueChanged<Size> onSizeCallback;

  MeasureSizeBox({
    required this.child,
    required this.onSizeCallback,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderConstrainedBox(onSizeCallback: this.onSizeCallback);
  }
}

class _RenderConstrainedBox extends RenderConstrainedBox {
  final ValueChanged<Size> onSizeCallback;

  _RenderConstrainedBox({required this.onSizeCallback})
      : super(additionalConstraints: BoxConstraints());

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    super.layout(constraints, parentUsesSize: parentUsesSize);
    onSizeCallback(Size.copy(size));
  }
}
