import 'package:flutter/material.dart';

import '../tab_bar_item_info.dart';
import 'transform_delegate.dart';

class ScaleTransformDelegate extends TransfromDelegate {
  double maxScale;
  ScaleTransformDelegate({
    TransfromDelegate? delegate,
    TransformBuilder? builder,
    this.maxScale = 1.2,
  })  : assert(maxScale >= 1),
        super(delegate: delegate, builder: builder);

  double scale = 0;
  @override
  void calculate(TabBarItemInfo tabbarItemInfo) {
    scale = tabbarItemInfo.page! % 1.0;

    if (tabbarItemInfo.isJumpPage!) {
      scale = tabbarItemInfo.jumpPageIndex == tabbarItemInfo.itemIndex ? 1 : 0;
    } else {
      var itemIndex = tabbarItemInfo.page!.ceil();
      if (tabbarItemInfo.itemIndex != itemIndex) {
        itemIndex = tabbarItemInfo.page!.floor();
      }

      if (itemIndex == tabbarItemInfo.itemIndex) {
        if (tabbarItemInfo.page!.floor() == itemIndex) {
          scale = 1 - scale;
        }
      } else {
        scale = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context, TabBarItemInfo tabbarItemInfo) {
    calculate(tabbarItemInfo);

    return Transform.scale(
      scale: 1 + ((maxScale - 1) * scale),
      child: builder == null
          ? delegate!.build(context, tabbarItemInfo)
          : builder!(context, scale),
    );
  }
}
