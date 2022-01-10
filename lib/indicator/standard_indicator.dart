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
    if (info.nextItemWidth == -1 && !info.isLast) return;

    double left = 0;
    double right = 0;

    if (info.progress <= 0.5) {
      left = info.currentItemScrollEndX - (info.currentItemWidth + width) * 0.5;
      right = info.tabbarWidth -
          info.currentItemScrollEndX +
          info.currentItemWidth * (0.5 - info.progress) -
          width * 0.5 -
          info.nextItemWidth * info.progress;
    } else {
      left = info.currentItemScrollEndX -
          width * 0.5 -
          info.nextItemWidth * (0.5 - info.progress) -
          info.currentItemWidth * (1 - info.progress);

      right = info.tabbarWidth -
          info.currentItemScrollEndX -
          (info.nextItemWidth + width) * 0.5;
    }
    notifier.value = IndicatorPosition(left, right);
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
    double targetLeft = controller.getTargetItemScrollEndX(sizeList, index) -
        (sizeList![index].width + width) / 2;

    _animationController =
        AnimationController(duration: duration, vsync: vsync);

    _animation =
        Tween(begin: left, end: targetLeft).animate(_animationController!);
    _animation.addListener(() {
      double right =
          controller.getTabbarWidth(sizeList) - _animation.value - width;

      notifier.value = IndicatorPosition(_animation.value, right);
      controller.forEachListenerCallback();
    });

    _animationController!.forward();
  }
}
