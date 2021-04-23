import 'package:flutter/material.dart';

import 'delegate/transform_delegate.dart';
import 'tab_bar_item_info.dart';

class TabBarItem extends StatelessWidget {
  final Widget child;
  final TabBarItemInfo tabbarItemInfo;
  final TransfromDelegate delegate;
  TabBarItem({
    Key key,
    this.child,
    @required this.tabbarItemInfo,
    this.delegate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (delegate != null) {
      return delegate.build(context, tabbarItemInfo);
    }

    return Container(
      child: child,
    );
  }
}
