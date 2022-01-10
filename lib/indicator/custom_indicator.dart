import 'package:flutter/material.dart';

import '../library.dart';

class CustomTabBarController {
  double? _lastPage = 0;
  bool _isJumpToTarget = false;
  ValueChanged<int>? _animateToIndexCallback;
  int _currentIndex = 0;
  double _progress = 0;

  List<VoidCallback?> _listeners = [];

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
  }

  void addListener(VoidCallback? callback) {
    _listeners.add(callback);
  }

  void removeAt(int index) {
    if (index >= 0 && index < _listeners.length) {
      _listeners.removeAt(index);
    }
  }

  bool isChanging() {
    if (isJumpToTarget) return true;
    if (!isJumpToTarget) {
      return double.parse(_progress.toStringAsFixed(3)) > 0.001;
    }

    return false;
  }

  void forEachListenerCallback() {
    _listeners.forEach((listener) {
      listener?.call();
    });
  }

  void startJump() {
    _isJumpToTarget = true;
  }

  void endJump() {
    _isJumpToTarget = false;
  }

  bool get isJumpToTarget => _isJumpToTarget;

  void setAnimateToIndexCallback(ValueChanged<int> callback) {
    _animateToIndexCallback = callback;
  }

  void animateToIndex(int targetIndex) {
    _animateToIndexCallback?.call(targetIndex);
  }

  ScrollItemInfo calculateScrollTabbarItemInfo(
      double? page, List<Size> sizeList) {
    _progress = page! % 1.0;

    ///确定当前索引值位置
    if (page > _lastPage!) {
      if (page.toInt() > _lastPage!.toInt()) {
        _currentIndex = page.toInt();
      } else {
        _currentIndex = _lastPage!.toInt();
        _progress = _progress == 0 ? 1 : _progress;
      }
    } else {
      _currentIndex = page.toInt();
    }

    _lastPage = page;

    //获取下一个Item的宽度
    double nextIndexItemWidth = -1;
    if (_currentIndex < sizeList.length - 1) {
      nextIndexItemWidth = sizeList[_currentIndex + 1].width;
    }

    return ScrollItemInfo.obtain(
        _currentIndex,
        getTargetItemScrollEndX(sizeList, _currentIndex),
        sizeList[_currentIndex].width,
        nextIndexItemWidth,
        _progress,
        getTabbarWidth(sizeList),
        sizeList.length);
  }

  //根据pageController来计算进度
  ScrollProgressInfo? calculateScrollProgressByPageView(
      int currentIndex, PageController pageController) {
    if (pageController.page == currentIndex) return null;

    int targetIndex = 0;
    if ((pageController.page ?? 0) > currentIndex) {
      targetIndex = pageController.page!.ceil();
    } else {
      targetIndex = pageController.page!.floor();
    }

    _progress = pageController.page! % 1.0;
    if (targetIndex < currentIndex) {
      _progress = 1 - _progress;
    }
    _progress = _progress == 0 ? 1 : _progress;

    return ScrollProgressInfo(
        progress: _progress,
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
  void scrollTargetToCenter(double tabCenterX, int targetIndex,
      List<Size>? sizeList, ScrollController? scrollController,
      {Duration? duration}) {
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

    if (duration == null) {
      scrollController?.jumpTo(animateToOffsetX);
    } else {
      scrollController?.animateTo(animateToOffsetX,
          duration: duration, curve: Curves.easeIn);
    }
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

  double getTabbarWidth(List<Size>? sizeList) {
    double totalWidth = 0;
    sizeList!.forEach((item) {
      totalWidth += item.width;
    });
    return totalWidth;
  }

  double getTabIndicatorCenterX(double width) {
    return width / 2;
  }
}

abstract class CustomIndicator {
  final double? top;
  final Color color;
  final double bottom;
  final double height;
  final double? width;
  final BorderRadius? radius;

  late CustomTabBarController controller;

  CustomIndicator(
      {this.bottom = 0,
      this.top,
      this.width,
      required this.color,
      required this.height,
      this.radius});

  void updateScrollIndicator(double? page, List<Size>? sizeList,
      Duration duration, ValueNotifier<IndicatorPosition> notifier);

  void indicatorScrollToIndex(
      int index,
      List<Size>? sizeList,
      Duration duration,
      TickerProvider vsync,
      ValueNotifier<IndicatorPosition> notifier);

  void dispose();
}
