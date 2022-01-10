import 'package:flutter/material.dart';
import 'package:flutter_custom_tab_bar/library.dart';

class LinearIndicator extends CustomIndicator {
  final Color color;
  final double bottom;
  final BorderRadius? radius;
  final double height;
  final double? width;

  LinearIndicator(
      {required this.color,
      required this.bottom,
      this.height = 3,
      this.radius,
      this.width})
      : super(
            bottom: bottom,
            color: color,
            height: height,
            radius: radius,
            width: width);

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
    if (this.width == null) {
      left = info.currentItemScrollEndX -
          info.currentItemWidth +
          info.currentItemWidth * info.progress;
      right = info.tabbarWidth -
          info.currentItemScrollEndX -
          info.nextItemWidth * info.progress;
    } else {
      left = info.currentItemScrollEndX -
          (info.currentItemWidth + this.width!) / 2 +
          (info.currentItemWidth + info.nextItemWidth) / 2 * info.progress;

      right = info.tabbarWidth - left - this.width!;
    }

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
    double width =
        this.width ?? controller.getTabbarWidth(sizeList) - right - left;

    double targetLeft = controller.getTargetItemScrollStartX(sizeList, index);

    if (this.width != null) {
      targetLeft = targetLeft +
          (sizeList?[index].width ?? 0 - this.width!) / 2 -
          this.width! / 2;
    }
    if (targetLeft == left) return;

    _animationController =
        AnimationController(duration: duration, vsync: vsync);
    _animation =
        Tween(begin: left, end: targetLeft).animate(_animationController!);

    _animation.addListener(() {
      double rate = 0;
      double targetRight = 0;
      if (left > targetLeft) {
        rate = 1 - (targetLeft - _animation.value) / (targetLeft - left);
      } else {
        rate = (_animation.value - left) / (targetLeft - left);
      }

      if (this.width == null) {
        targetRight = controller.getTabbarWidth(sizeList) -
            _animation.value -
            width -
            (sizeList![index].width - width) * rate;
      } else {
        targetRight =
            controller.getTabbarWidth(sizeList) - _animation.value - width;
      }

      notifier.value = IndicatorPosition(_animation.value, targetRight);
      controller.forEachListenerCallback();
    });
    _animationController!.forward();
  }
}
