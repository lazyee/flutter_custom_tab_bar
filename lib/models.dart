class ScrollItemInfo {
  double percent = 0;
  double nextItemWidth = -1;
  int currentIndex = -1;
  double currentItemWidth = -1;
  double currentItemScrollX = -1;
  double tabbarWidth = -1;
}

class IndicatorPosition {
  final double left;
  final double right;
  const IndicatorPosition(this.left, this.right);
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
