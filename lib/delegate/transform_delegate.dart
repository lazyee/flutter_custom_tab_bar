import 'package:flutter/material.dart';

import '../tab_bar_item_info.dart';

typedef TransformBuilder = Widget Function(
    BuildContext context, dynamic transform);

abstract class TransfromDelegate {
  // TabBarItemInfo tabbarItemInfo;
  TransfromDelegate delegate;
  TransformBuilder builder;
  TransfromDelegate({
    // @required this.tabbarItemInfo,
    this.delegate,
    this.builder,
  });

  void calculate(TabBarItemInfo tabBarItemInfo);

  Widget build(BuildContext context, TabBarItemInfo tabBarItemInfo);
}
