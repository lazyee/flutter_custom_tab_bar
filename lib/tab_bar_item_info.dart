import 'package:flutter/material.dart';

class TabBarItemInfo {
  int? currentIndex;
  Size? size;
  bool? isJumpPage;
  int? jumpPageIndex;
  int? itemIndex;
  double? page;

  TabBarItemInfo.create({
    this.itemIndex,
    this.currentIndex,
    this.isJumpPage,
    this.jumpPageIndex,
    this.size,
    this.page,
  });
}
