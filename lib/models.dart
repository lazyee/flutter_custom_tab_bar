import 'dart:ui';

class ScrollItemInfo {
  final double progress;
  // final double nextItemWidth;
  final Size nextItemSize;
  final int currentIndex;
  // final double currentItemWidth;
  final Size currentItemSize;
  // final double currentItemScrollEndX;
  final Offset currentItemScrollEndOffset;
  // final double tabbarWidth;
  final Size tabBarSize;
  final int tabsLength;

  bool get isLast => tabsLength - 1 == currentIndex;

  const ScrollItemInfo.obtain(
      this.currentIndex,
      // this.currentItemScrollEndX,
      this.currentItemScrollEndOffset,
      // this.currentItemWidth,
      this.currentItemSize,
      // this.nextItemWidth,
      this.nextItemSize,
      this.progress,
      // this.tabbarWidth,
      this.tabBarSize,
      this.tabsLength);
}

class IndicatorPosition {
  final double left;
  final double right;
  final double top;
  final double bottom;
  const IndicatorPosition(this.left, this.right, this.top, this.bottom);
}

class ScrollProgressInfo {
  final int targetIndex;
  final int currentIndex;
  final double progress;

  const ScrollProgressInfo({
    this.targetIndex = -1,
    this.currentIndex = 0,
    this.progress = 0,
  });
}
