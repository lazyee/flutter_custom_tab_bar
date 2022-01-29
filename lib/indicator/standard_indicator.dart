import 'package:flutter/material.dart';

import '../models.dart';
import 'custom_indicator.dart';

class StandardIndicator extends CustomIndicator {
  final Color color;
  final double bottom;
  final BorderRadius? radius;
  final double width;
  final double height;

  StandardIndicator(
      {required this.width,
      required this.color,
      this.bottom = 0,
      this.height = 3,
      this.radius})
      : super(bottom: bottom, color: color, height: height, radius: radius);

  @override
  void dispose() {
    _animationController?.stop(canceled: true);
  }

  AnimationController? _animationController;
  late Animation _animation;

  @override
  void updateScrollIndicator(double? page, List<Size>? sizeList,
      Duration duration, ValueNotifier<IndicatorPosition> notifier) {
    ScrollItemInfo info =
        controller.calculateScrollTabbarItemInfo(page, sizeList!);
    if (info.nextItemSize.width == -1 &&
        info.nextItemSize.height == -1 &&
        !info.isLast) return;

    double left = 0;
    double right = 0;
    double top = 0;
    double bottom = 0;

    if (info.progress <= 0.5) {
      left = info.currentItemScrollEndOffset.dx -
          (info.currentItemSize.width + width) * 0.5;
      right = info.tabBarSize.width -
          info.currentItemScrollEndOffset.dx +
          info.currentItemSize.width * (0.5 - info.progress) -
          width * 0.5 -
          info.nextItemSize.width * info.progress;
    } else {
      left = info.currentItemScrollEndOffset.dx -
          width * 0.5 -
          info.nextItemSize.width * (0.5 - info.progress) -
          info.currentItemSize.width * (1 - info.progress);

      right = info.tabBarSize.width -
          info.currentItemScrollEndOffset.dx -
          (info.nextItemSize.width + width) * 0.5;
    }
    notifier.value = IndicatorPosition(left, right, top, bottom);
    controller.forEachListenerCallback();
  }

  @override
  void indicatorScrollToIndex(
      int index,
      List<Size>? sizeList,
      Duration duration,
      TickerProvider vsync,
      ValueNotifier<IndicatorPosition> notifier) {
    double left = notifier.value.left;

    double targetLeft =
        controller.getTargetItemScrollEndOffset(sizeList, index).dx -
            (sizeList![index].width + width) / 2;

    _animationController =
        AnimationController(duration: duration, vsync: vsync);

    _animation =
        Tween(begin: left, end: targetLeft).animate(_animationController!);
    _animation.addListener(() {
      double right =
          controller.getTabBarSize(sizeList).width - _animation.value - width;

      notifier.value = IndicatorPosition(_animation.value, right, 0, 0);
      controller.forEachListenerCallback();
    });

    _animationController!.forward();
  }
}
