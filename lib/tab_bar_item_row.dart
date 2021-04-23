import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'custom_tab_bar.dart';
import 'tab_bar_item_info.dart';

class TabBarItemRow extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder builder;
  final List<TabBarItemInfo> tabbarItemInfoList;
  final void Function(int index) onTapTabItem;
  final CustomTabbarController controller;
  TabBarItemRow(
      {@required this.itemCount,
      @required this.builder,
      @required this.tabbarItemInfoList,
      @required this.onTapTabItem,
      @required this.controller,
      key})
      : super(key: key);

  @override
  TabBarItemRowState createState() => TabBarItemRowState();
}

class TabBarItemRowState extends State<TabBarItemRow> {
  void updateSelectedIndex() {
    if (widget.controller != null) {
      widget.controller.updateSelectedIndex(this);
    }
  }

  ///通知更新
  void notifyUpdate(double page) {
    setState(() {});
    // var index = page.floor();
    // var index2 = page.ceil();
    // setState(() {
    //   widgetList[index] = _createItem(index);
    //   widgetList[index2] = _createItem(index2);
    // });
  }

  Widget _createItem(int index) {
    return InkWell(
        onTap: () => widget.onTapTabItem(index),
        child: _TabBarItem(
          child: widget.builder(context, index),
          tabbarItemInfoList: widget.tabbarItemInfoList,
          index: index,
        ));
  }

  List<Widget> widgetList = [];
  @override
  Widget build(BuildContext context) {
    widgetList.clear();
    // if (widgetList.isEmpty) {
    for (var i = 0; i < widget.itemCount; i++) {
      widgetList.add(_createItem(i));
    }
    // }

    return Row(children: widgetList);
  }
}

class _TabBarItem extends SingleChildRenderObjectWidget {
  final Widget child;
  final List<TabBarItemInfo> tabbarItemInfoList;
  final int index;
  _TabBarItem({
    @required this.child,
    @required this.index,
    @required this.tabbarItemInfoList,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _TabbarItemRenderObj(
        index: this.index, tabbarItemInfoList: this.tabbarItemInfoList);
  }
}

class _TabbarItemRenderObj extends RenderConstrainedBox {
  final List<TabBarItemInfo> tabbarItemInfoList;
  final int index;
  _TabbarItemRenderObj(
      {@required this.index, @required this.tabbarItemInfoList})
      : super(additionalConstraints: BoxConstraints());

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    super.layout(constraints, parentUsesSize: parentUsesSize);
    tabbarItemInfoList[index].size = Size.copy(size);
  }
}
