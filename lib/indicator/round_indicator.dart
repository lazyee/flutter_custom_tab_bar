import 'package:flutter/material.dart';

import '../models.dart';
import 'custom_indicator.dart';

class RoundIndicator extends CustomIndicator {
  final Color color;
  final BorderRadius? radius;
  final double height;
  final double top;
  final double bottom;
  final double left;
  final double right;
  RoundIndicator(
      {required this.color,
      this.top = 0,
      this.bottom = 0,
      this.left = 0,
      this.right = 0,
      this.height = 3,
      this.radius})
      : super(bottom: bottom, color: color, height: height, radius: radius);
  double getTabIndicatorCenterX(double width) {
    return width / 2;
  }

  @override
  void updateScrollIndicator(double? page, List<Size>? sizeList,
      Duration duration, ValueNotifier<IndicatorPosition> notifier) {
    ScrollItemInfo info =
        controller.calculateScrollTabbarItemInfo(page, sizeList!);

    // if (info.nextItemWidth == -1 && !info.isLast) return;
    if (info.nextItemSize.width == -1 &&
        info.nextItemSize.width == -1 &&
        !info.isLast) return;

    double left = 0;
    double right = 0;
    double top = 0;
    double bottom = 0;

    if (controller.direction == Axis.horizontal) {
      left = info.currentItemScrollEndOffset.dx -
          info.currentItemSize.width +
          info.currentItemSize.width * info.progress;
      right = info.tabBarSize.width -
          info.currentItemScrollEndOffset.dx -
          info.nextItemSize.width * info.progress;
    } else {
      top = info.currentItemScrollEndOffset.dy -
          info.currentItemSize.height +
          info.currentItemSize.height * info.progress;
      bottom = info.tabBarSize.height -
          info.currentItemScrollEndOffset.dy -
          info.nextItemSize.height * info.progress;
    }

    notifier.value = IndicatorPosition(left, right, top, bottom);
    controller.forEachListenerCallback();
  }

  AnimationController? _animationController;
  late Animation _animation;

  @override
  void dispose() {
    _animationController?.stop(canceled: true);
  }

  @override
  void indicatorScrollToIndex(
      int index,
      List<Size>? sizeList,
      Duration duration,
      TickerProvider vsync,
      ValueNotifier<IndicatorPosition> notifier) {
    double left = notifier.value.left;
    double right = notifier.value.right;
    double top = notifier.value.top;
    double bottom = notifier.value.bottom;

    if (controller.direction == Axis.horizontal) {
      double width = controller.getTabBarSize(sizeList).width - right - left;
      double targetLeft =
          controller.getTargetItemScrollStartOffset(sizeList, index).dx;
      if (targetLeft == left) return;

      _animationController =
          AnimationController(duration: duration, vsync: vsync);

      _animation =
          Tween(begin: left, end: targetLeft).animate(_animationController!);

      _animation.addListener(() {
        double? rate = 0;
        double targetRight = 0;
        if (left > targetLeft) {
          rate = 1 - (targetLeft - _animation.value) / (targetLeft - left);
          targetRight = controller.getTabBarSize(sizeList).width -
              _animation.value -
              width -
              (sizeList![index].width - width) * rate;
        } else {
          rate = (_animation.value - left) / (targetLeft - left);
          targetRight = controller.getTabBarSize(sizeList).width -
              _animation.value -
              width -
              (sizeList![index].width - width) * rate!;
        }

        notifier.value = IndicatorPosition(_animation.value, targetRight, 0, 0);
        controller.forEachListenerCallback();
      });
    } else {
      double height = controller.getTabBarSize(sizeList).height - bottom - top;
      double targetTop =
          controller.getTargetItemScrollStartOffset(sizeList, index).dy;
      if (targetTop == top) return;

      _animationController =
          AnimationController(duration: duration, vsync: vsync);

      _animation =
          Tween(begin: top, end: targetTop).animate(_animationController!);

      _animation.addListener(() {
        double? rate = 0;
        double targetBottom = 0;
        if (top > targetTop) {
          rate = 1 - (targetTop - _animation.value) / (targetTop - top);
          targetBottom = controller.getTabBarSize(sizeList).height -
              _animation.value -
              height -
              (sizeList![index].height - height) * rate;
        } else {
          rate = (_animation.value - top) / (targetTop - top);
          targetBottom = controller.getTabBarSize(sizeList).height -
              _animation.value -
              height -
              (sizeList![index].height - height) * rate!;
        }

        notifier.value =
            IndicatorPosition(0, 0, _animation.value, targetBottom);
        controller.forEachListenerCallback();
      });
    }

    _animationController!.forward();
  }
}
