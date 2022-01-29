import 'dart:ui';

class ScrollItemInfo {
  final double progress;
  final Size nextItemSize;
  final int currentIndex;
  final Size currentItemSize;
  final Offset currentItemScrollEndOffset;
  final Size tabBarSize;
  final int tabsLength;

  bool get isLast => tabsLength - 1 == currentIndex;

  const ScrollItemInfo.obtain(
      this.currentIndex,
      this.currentItemScrollEndOffset,
      this.currentItemSize,
      this.nextItemSize,
      this.progress,
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
