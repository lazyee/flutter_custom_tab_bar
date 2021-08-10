import 'package:flutter/material.dart';

import '../tab_bar_item_info.dart';

typedef TransformBuilder = Widget Function(
    BuildContext context, dynamic transform);

abstract class TransfromDelegate {
  TransfromDelegate? delegate;
  TransformBuilder? builder;
  TransfromDelegate({
    this.delegate,
    this.builder,
  });

  void calculate(TabBarItemInfo tabBarItemInfo);

  Widget build(BuildContext context, TabBarItemInfo tabBarItemInfo);
}
