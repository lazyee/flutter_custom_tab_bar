import 'package:flutter/material.dart';

import '../library.dart';

class CustomTabBarController {
  double? _lastPage = 0;
  bool _isJumpToTarget = false;
  ValueChanged<int>? _animateToIndexCallback;
  int _currentIndex = 0;
  double _progress = 0;

  Axis _direction = Axis.horizontal;

  List<VoidCallback?> _listeners = [];

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
  }

  Axis get direction => _direction;

  void setOrientation(Axis orientation) {
    this._direction = orientation;
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

    //获取下一个Item的Size
    Size nextIndexItemSize = Size(-1, -1);
    if (_currentIndex < sizeList.length - 1) {
      nextIndexItemSize = sizeList[_currentIndex + 1];
    }

    return ScrollItemInfo.obtain(
        _currentIndex,
        getTargetItemScrollEndOffset(sizeList, _currentIndex),
        sizeList[_currentIndex],
        nextIndexItemSize,
        _progress,
        getTabBarSize(sizeList),
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
  void scrollByPageView(Size tabCenterSize, List<Size>? sizeList,
      ScrollController? scrollController, PageController pageController) {
    if (scrollController == null) return;
    var index = pageController.page!.ceil();
    var preIndex = pageController.page!.floor();
    var offsetPercent = pageController.page! % 1;
    var currentIndexHalfSize = sizeList![index] / 2;
    var preIndexHalfSize = sizeList[preIndex] / 2;

    var totalSize = Size(currentIndexHalfSize.width + preIndexHalfSize.width,
        currentIndexHalfSize.height + preIndexHalfSize.height);

    var startOffset = getTargetItemScrollStartOffset(sizeList, preIndex);
    var endSize = sizeList[preIndex] / 2 + startOffset;

    var contentInsertSize = getTabBarSize(sizeList);

    bool isVisible =
        isItemVisible(scrollController, index, sizeList, tabCenterSize * 2);

    var offset = 0.0;
    if (direction == Axis.horizontal) {
      if (isVisible) {
        if (endSize.width + totalSize.width > tabCenterSize.width) {
          if (endSize.width > tabCenterSize.width) {
            offset = endSize.width -
                tabCenterSize.width +
                offsetPercent * totalSize.width;
          } else {
            offset = offsetPercent *
                (totalSize.width + endSize.width - tabCenterSize.width);
          }
          if (contentInsertSize.width - offset - tabCenterSize.width >
              tabCenterSize.width) {
            scrollController.jumpTo(offset);
          }
        }
      } else {
        offset = startOffset.dx - tabCenterSize.width;
        scrollController.jumpTo(offset < 0 ? 0 : offset);
      }
    } else {
      //竖直方向
      if (isVisible) {
        if (endSize.height + totalSize.height > tabCenterSize.height) {
          if (endSize.height > tabCenterSize.height) {
            offset = endSize.height -
                tabCenterSize.height +
                offsetPercent * totalSize.height;
          } else {
            offset = offsetPercent *
                (totalSize.height + endSize.height - tabCenterSize.height);
          }

          if (contentInsertSize.height - offset - tabCenterSize.height >
              tabCenterSize.height) {
            scrollController.jumpTo(offset);
          }
        }
      } else {
        offset = startOffset.dy - tabCenterSize.height;
        scrollController.jumpTo(offset < 0 ? 0 : offset);
      }
    }
  }

  ///判断item是否显示在可见区域
  bool isItemVisible(ScrollController scrollController, index,
      List<Size>? sizeList, Size tabBarSize) {
    var startOffset = getTargetItemScrollStartOffset(sizeList, index);

    if (direction == Axis.horizontal) {
      return scrollController.position.pixels < startOffset.dx &&
          startOffset.dx < scrollController.position.pixels + tabBarSize.width;
    }
    return scrollController.position.pixels < startOffset.dy &&
        startOffset.dy < scrollController.position.pixels + tabBarSize.height;
  }

  int lastIndex = 0;

  ///滚动目标索引的项到中间位置
  void scrollTargetToCenter(Size tabCenterSize, int targetIndex,
      List<Size>? sizeList, ScrollController? scrollController,
      {Duration? duration}) {
    if (targetIndex == lastIndex) return;
    var targetItemScrollOffset =
        getTargetItemScrollEndOffset(sizeList, targetIndex);
    var tabBarSize = getTabBarSize(sizeList);

    double animateToOffset = 0;

    if (direction == Axis.horizontal) {
      animateToOffset = targetItemScrollOffset.dx -
          sizeList![targetIndex].width / 2 -
          tabCenterSize.width;
    } else {
      animateToOffset = targetItemScrollOffset.dy -
          sizeList![targetIndex].height / 2 -
          tabCenterSize.height;
    }

    if (animateToOffset <= 0) {
      animateToOffset = 0;
    } else {
      if (direction == Axis.horizontal) {
        if (animateToOffset + tabCenterSize.width >
            tabBarSize.width - tabCenterSize.width) {
          if (tabBarSize.width > tabCenterSize.width * 2) {
            animateToOffset = tabBarSize.width - tabCenterSize.width * 2;
          } else {
            animateToOffset = 0;
          }
        }
      } else {
        if (animateToOffset + tabCenterSize.height >
            tabBarSize.height - tabCenterSize.height) {
          if (tabBarSize.height > tabCenterSize.height * 2) {
            animateToOffset = tabBarSize.height - tabCenterSize.height * 2;
          } else {
            animateToOffset = 0;
          }
        }
      }
    }

    lastIndex = targetIndex;

    if (duration == null) {
      scrollController?.jumpTo(animateToOffset);
    } else {
      scrollController?.animateTo(animateToOffset,
          duration: duration, curve: Curves.easeIn);
    }
  }

  Offset getTargetItemScrollEndOffset(List<Size>? sizeList, int index) {
    double width = 0;
    double height = 0;
    for (int i = 0; i <= index; i++) {
      width += sizeList![i].width;
      height += sizeList[i].height;
    }
    return Offset(width, height);
  }

  Offset getTargetItemScrollStartOffset(List<Size>? sizeList, int index) {
    double width = 0;
    double height = 0;

    for (int i = 0; i < index; i++) {
      width += sizeList![i].width;
      height += sizeList[i].height;
    }

    return Offset(width, height);
  }

  Size getTabBarSize(List<Size>? sizeList) {
    double width = 0;
    double height = 0;
    sizeList?.forEach((item) {
      width += item.width;
      height += item.height;
    });

    return Size(width, height);
  }

  double getTabIndicatorCenterX(double width) {
    return width / 2;
  }
}

abstract class CustomIndicator {
  final Color color;
  final double left;
  final double right;
  final double? top;
  final double bottom;
  final double height;
  final double? width;
  final BorderRadius? radius;
  late CustomTabBarController controller;

  CustomIndicator(
      {this.bottom = 0,
      this.top,
      this.right = 0,
      this.left = 0,
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
