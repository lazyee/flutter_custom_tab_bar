import 'package:flutter/material.dart';

import '../library.dart';

class CustomTabBarController {
  double? lastScrollProgress = 0;
  bool _isJumpToTarget = false;
  ValueChanged<int>? _animateToIndexCallback;

  void startJump() {
    _isJumpToTarget = true;
  }

  void endJump() {
    _isJumpToTarget = false;
  }

  bool get isJumpToTarget => _isJumpToTarget;

  void setAnimToIndexCallback(ValueChanged<int> callback) {
    _animateToIndexCallback = callback;
  }

  void animateToIndex(int targetIndex) {
    _animateToIndexCallback?.call(targetIndex);
  }

  ScrollItemInfo getScrollTabbarItemInfo(
      double? scrollProgress, List<Size> sizeList) {
    double percent = scrollProgress! % 1.0;

    ///确定当前索引值位置
    int currentIndex = 0;
    if (scrollProgress > lastScrollProgress!) {
      if (scrollProgress.toInt() > lastScrollProgress!.toInt()) {
        currentIndex = scrollProgress.toInt();
      } else {
        currentIndex = lastScrollProgress!.toInt();
        percent = percent == 0 ? 1 : percent;
      }
    } else {
      currentIndex = scrollProgress.toInt();
    }

    lastScrollProgress = scrollProgress;

    //获取下一个Item的宽度
    double nextIndexItemWidth = -1;
    if (currentIndex < sizeList.length - 1) {
      nextIndexItemWidth = sizeList[currentIndex + 1].width;
    }

    return ScrollItemInfo.obtain(
        currentIndex,
        getTargetItemScrollEndX(sizeList, currentIndex),
        sizeList[currentIndex].width,
        nextIndexItemWidth,
        percent,
        getTabbarWidth(sizeList),
        sizeList.length);
  }

  //根据pageController来计算进度
  ScrollProgressInfo? updateScrollProgressByPageView(
      int currentIndex, PageController pageController) {
    if (pageController.page == currentIndex) return null;

    int targetIndex = 0;
    if ((pageController.page ?? 0) > currentIndex) {
      targetIndex = pageController.page!.ceil();
    } else {
      targetIndex = pageController.page!.floor();
    }

    var progress = pageController.page! % 1;
    if (targetIndex < currentIndex) {
      progress = 1 - progress;
    }
    progress = progress == 0 ? 1 : progress;

    return ScrollProgressInfo(
        progress: progress,
        targetIndex: targetIndex,
        currentIndex: currentIndex);
  }

  ///根据pageController来设置偏移量
  void scrollByPageView(double tabCenterX, List<Size>? sizeList,
      ScrollController? scrollController, PageController pageController) {
    if (scrollController == null) return;
    var index = pageController.page!.ceil();
    var preIndex = pageController.page!.floor();
    var offsetPercent = pageController.page! % 1;
    var total = sizeList![index].width / 2 + sizeList[preIndex].width / 2;
    var startX = getTargetItemScrollStartX(sizeList, preIndex);
    var endX = startX + sizeList[preIndex].width / 2;
    var offsetX = 0.0;
    var contentInsertWidth = getTabbarWidth(sizeList);

    bool isVisible =
        isItemVisible(scrollController, index, sizeList, tabCenterX * 2);

    if (isVisible) {
      if (endX + total > tabCenterX) {
        if (endX > tabCenterX) {
          offsetX = endX - tabCenterX + offsetPercent * (total);
        } else {
          offsetX = offsetPercent * (total + endX - tabCenterX);
        }
        if (contentInsertWidth - offsetX - tabCenterX > tabCenterX) {
          scrollController.jumpTo(offsetX);
        }
      }
    } else {
      if (startX < tabCenterX) {
        scrollController.jumpTo(0);
      } else {
        scrollController.jumpTo(startX - tabCenterX);
      }
    }
  }

  ///判断item是否显示在可见区域
  bool isItemVisible(ScrollController scrollController, index,
      List<Size>? sizeList, double tabbarWidth) {
    var startX = getTargetItemScrollStartX(sizeList, index);
    return scrollController.position.pixels < startX &&
        startX < scrollController.position.pixels + tabbarWidth;
  }

  int lastIndex = 0;

  ///滚动目标索引的项到中间位置
  void scrollTargetToCenter(
    double tabCenterX,
    int targetIndex,
    List<Size>? sizeList,
    ScrollController? scrollController,
    Duration duration,
  ) {
    if (targetIndex == lastIndex) return;
    var targetItemScrollX = getTargetItemScrollEndX(sizeList, targetIndex);
    var tabbarWidth = getTabbarWidth(sizeList);

    var animateToOffsetX =
        targetItemScrollX - sizeList![targetIndex].width / 2 - tabCenterX;

    if (animateToOffsetX <= 0) {
      animateToOffsetX = 0;
    } else if (animateToOffsetX + tabCenterX > tabbarWidth - tabCenterX) {
      if (tabbarWidth > tabCenterX * 2) {
        animateToOffsetX = tabbarWidth - tabCenterX * 2;
      } else {
        animateToOffsetX = 0;
      }
    }

    lastIndex = targetIndex;

    scrollController?.animateTo(animateToOffsetX,
        duration: duration, curve: Curves.ease);
  }

  double getTargetItemScrollEndX(List<Size>? sizeList, int index) {
    double totalX = 0;
    for (int i = 0; i <= index; i++) {
      totalX += sizeList![i].width;
    }
    return totalX;
  }

  double getTargetItemScrollStartX(List<Size>? sizeList, int index) {
    double totalX = 0;
    for (int i = 0; i < index; i++) {
      totalX += sizeList![i].width;
    }
    return totalX;
  }

  double tabsContentInsetWidth = 0;
  double getTabbarWidth(List<Size>? sizeList) {
    if (tabsContentInsetWidth == 0) {
      sizeList!.forEach((item) {
        tabsContentInsetWidth += item.width;
      });
    }
    return tabsContentInsetWidth;
  }
}

abstract class CustomIndicator extends CustomTabBarController {
  final double? top;
  final Color color;
  final double bottom;
  final double height;
  final double? width;
  final BorderRadius? radius;

  CustomIndicator(
      {this.bottom = 0,
      this.top,
      this.width,
      required this.color,
      required this.height,
      this.radius});

  double getTabIndicatorCenterX(double width) {
    return width / 2;
  }

  void updateScrollIndicator(
      double? scrollProgress,
      List<Size>? tabbarItemInfoList,
      Duration duration,
      ValueNotifier<IndicatorPosition> notifier);
  void indicatorScrollToIndex(
      int index,
      List<Size>? tabbarItemInfoList,
      Duration duration,
      TickerProvider vsync,
      ValueNotifier<IndicatorPosition> notifier);

  void dispose();
}
