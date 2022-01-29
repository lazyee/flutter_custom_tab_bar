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
    if (info.nextItemSize.width == -1 &&
        info.nextItemSize.height == -1 &&
        !info.isLast) return;

    double left = 0;
    double right = 0;
    double top = 0;
    double bottom = 0;
    if (this.width == null) {
      // left = info.currentItemScrollEndX -
      left = info.currentItemScrollEndOffset.dx -
          // info.currentItemWidth +
          info.currentItemSize.width +
          // info.currentItemWidth * info.progress;
          info.currentItemSize.width * info.progress;
      // right = info.tabbarWidth -
      right = info.tabBarSize.width -
          // info.currentItemScrollEndX -
          info.currentItemScrollEndOffset.dx -
          // info.nextItemWidth * info.progress;
          info.nextItemSize.width * info.progress;
    } else {
      // left = info.currentItemScrollEndX -
      left = info.currentItemScrollEndOffset.dx -
          // (info.currentItemWidth + this.width!) / 2 +
          (info.currentItemSize.width + this.width!) / 2 +
          // (info.currentItemWidth + info.nextItemWidth) / 2 * info.progress;
          (info.currentItemSize.width + info.nextItemSize.width) /
              2 *
              info.progress;

      // right = info.tabbarWidth - left - this.width!;
      right = info.tabBarSize.width - left - this.width!;
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
    double width =
        this.width ?? controller.getTabBarSize(sizeList).width - right - left;

    double targetLeft =
        controller.getTargetItemScrollStartOffset(sizeList, index).dx;

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
        targetRight = controller.getTabBarSize(sizeList).width -
            _animation.value -
            width -
            (sizeList![index].width - width) * rate;
      } else {
        targetRight =
            controller.getTabBarSize(sizeList).width - _animation.value - width;
      }

      notifier.value = IndicatorPosition(_animation.value, targetRight, 0, 0);
      controller.forEachListenerCallback();
    });
    _animationController!.forward();
  }
}
