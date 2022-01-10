import 'package:flutter/material.dart';

import '../models.dart';
import 'custom_indicator.dart';

class RoundIndicator extends CustomIndicator {
  final Color color;
  final double bottom;
  final BorderRadius? radius;
  final double height;
  final double top;
  RoundIndicator(
      {required this.color,
      required this.top,
      required this.bottom,
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

    if (info.nextItemWidth == -1 && !info.isLast) return;

    double left = 0;
    double right = 0;

    left = info.currentItemScrollEndX -
        info.currentItemWidth +
        info.currentItemWidth * info.progress;
    right = info.tabbarWidth -
        info.currentItemScrollEndX -
        info.nextItemWidth * info.progress;

    notifier.value = IndicatorPosition(left, right);
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
    double width = controller.getTabbarWidth(sizeList) - right - left;
    double targetLeft = controller.getTargetItemScrollStartX(sizeList, index);
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
        targetRight = controller.getTabbarWidth(sizeList) -
            _animation.value -
            width -
            (sizeList![index].width - width) * rate;
      } else {
        rate = (_animation.value - left) / (targetLeft - left);
        targetRight = controller.getTabbarWidth(sizeList) -
            _animation.value -
            width -
            (sizeList![index].width - width) * rate!;
      }

      notifier.value = IndicatorPosition(_animation.value, targetRight);
      controller.forEachListenerCallback();
    });

    _animationController!.forward();
  }
}
