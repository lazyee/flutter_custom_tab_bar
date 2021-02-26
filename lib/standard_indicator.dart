import 'package:flutter/material.dart';

import 'custom_tab_bar.dart';

class StandardTabItem extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final bool isTapJumpPage;
  final int index;
  final double page;
  StandardTabItem({
    @required this.child,
    @required this.currentIndex,
    @required this.isTapJumpPage,
    @required this.index,
    @required this.page,
    Key key,
  }) : super(key: key);

  @override
  _StandardTabItemState createState() => _StandardTabItemState();
}

class _StandardTabItemState extends State<StandardTabItem> {
  double scalePercent = 0;

  void _calculateScalePercent() {
    scalePercent = widget.page % 1.0;

    if (widget.isTapJumpPage) {
      scalePercent = widget.currentIndex == widget.index ? 1 : 0;
    } else {
      var itemIndex = widget.page.ceil();
      if (widget.index != itemIndex) {
        itemIndex = widget.page.floor();
      }

      if (itemIndex == widget.index) {
        if (widget.page.floor() == itemIndex) {
          scalePercent = 1 - scalePercent;
        }
      } else {
        scalePercent = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _calculateScalePercent();
    return Transform.scale(
      scale: 1 + (0.2 * scalePercent),
      child: widget.child,
    );
  }
}

class StandardIndicator extends CustomTabIndicator {
  final double indicatorWidth;
  final Color indicatorColor;
  final StandardIndicatorController indicatorController;

  StandardIndicator({
    @required this.indicatorController,
    @required this.indicatorWidth,
    @required this.indicatorColor,
    Key key,
  }) : super(controller: indicatorController, key: key);

  @override
  _StandardIndicatorState createState() => _StandardIndicatorState();
}

class _StandardIndicatorState extends State<StandardIndicator>
    with TickerProviderStateMixin {
  double left = 0;
  double right = 0;

  @override
  void initState() {
    super.initState();
    widget.indicatorController.indicatorWidth = widget.indicatorWidth;
    widget.indicatorController.state = this;
    widget.indicatorController.tickerProvider = this;
  }

  void update(double left, double right) {
    setState(() {
      this.left = left;
      this.right = right;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (left == right && left == 0) {
      return SizedBox();
    }
    return Positioned(
      key: widget.key,
      left: left,
      right: right,
      bottom: 0,
      child: Container(
        width: widget.indicatorWidth,
        height: 3,
        decoration: BoxDecoration(
          color: widget.indicatorColor,
          borderRadius: BorderRadius.circular(1.75),
        ),
      ),
    );
  }
}

class StandardIndicatorController with CustomTabIndicatorMixin {
  _StandardIndicatorState state;
  double indicatorWidth = 0;
  int lastIndex = 0;
  TickerProvider tickerProvider;

  double getTargetItemScrollX(List<Size> sizeList, int index) {
    double totalX = 0;
    for (int i = 0; i <= index; i++) {
      totalX += sizeList[i].width;
    }
    return totalX;
  }

  double tabsContentInsetWidth = 0;
  double getTabsContentInsetWidth(List<Size> sizeList) {
    if (tabsContentInsetWidth == 0) {
      sizeList.forEach((item) {
        tabsContentInsetWidth += item.width;
      });
    }
    return tabsContentInsetWidth;
  }

  double getTabIndicatorCenterX(double width) {
    return width / 2;
  }

  @override
  void scrollTargetIndexTarBarItemToCenter(
      double tabCenterX,
      int currentIndex,
      List<Size> sizeList,
      ScrollController scrollController,
      Duration duration) {
    if (isIndicatorAnimPlaying) return;
    if (currentIndex == lastIndex) return;

    var targetItemScrollX = getTargetItemScrollX(sizeList, currentIndex);
    var contentInsertWidth = getTabsContentInsetWidth(sizeList);

    var animateToOffsetX =
        targetItemScrollX - sizeList[currentIndex].width / 2 - tabCenterX;

    if (animateToOffsetX <= 0) {
      animateToOffsetX = 0;
    } else if (animateToOffsetX + tabCenterX >
        contentInsertWidth - tabCenterX) {
      if (contentInsertWidth > tabCenterX * 2) {
        animateToOffsetX = contentInsertWidth - tabCenterX * 2;
      } else {
        animateToOffsetX = 0;
      }
    }

    scrollController.animateTo(animateToOffsetX,
        duration: duration, curve: Curves.ease);
    lastIndex = currentIndex;
  }

  double lastScrollProgress = 0;
  @override
  void updateScrollIndicator(
      double scrollProgress, List<Size> sizeList, Duration duration) {
    if (isIndicatorAnimPlaying) return;
    double percent = scrollProgress % 1.0;

    ///确定当前索引值位置
    int currentIndex = 0;
    if (scrollProgress > lastScrollProgress) {
      if (scrollProgress.toInt() > lastScrollProgress.toInt()) {
        currentIndex = scrollProgress.toInt();
      } else {
        currentIndex = lastScrollProgress.toInt();
        percent = percent == 0 ? 1 : percent;
      }
    } else {
      currentIndex = scrollProgress.toInt();
    }

    double currenIndexScrollX = getTargetItemScrollX(sizeList, currentIndex);
    double tabContentInsert = getTabsContentInsetWidth(sizeList);
    double left = 0;
    double right = 0;

    double currentIndexWidth = sizeList[currentIndex].width;
    double nextIndexWidth = 0;
    if (currentIndex < sizeList.length - 1) {
      nextIndexWidth = sizeList[currentIndex + 1].width;
    } else {
      return;
    }

    if (percent <= 0.5) {
      left = currenIndexScrollX - (currentIndexWidth + indicatorWidth) * 0.5;
      right = tabContentInsert -
          currenIndexScrollX +
          currentIndexWidth * (0.5 - percent) -
          indicatorWidth * 0.5 -
          nextIndexWidth * percent;
    } else {
      left = currenIndexScrollX -
          indicatorWidth * 0.5 -
          nextIndexWidth * (0.5 - percent) -
          currentIndexWidth * (1 - percent);

      right = tabContentInsert -
          currenIndexScrollX -
          (nextIndexWidth + indicatorWidth) / 2;
    }

    lastScrollProgress = scrollProgress;
    state.update(left, right);
  }

  AnimationController _animationController;
  Animation _animation;

  @override
  void indicatorScrollToIndex(
      int index, List<Size> sizeList, Duration duration) {
    isIndicatorAnimPlaying = true;

    double left = state.left;
    double targetLeft = getTargetItemScrollX(sizeList, index) -
        (sizeList[index].width + indicatorWidth) / 2;

    _animationController =
        AnimationController(duration: duration, vsync: tickerProvider);

    _animation =
        Tween(begin: left, end: targetLeft).animate(_animationController);
    _animation.addListener(() {
      double right = getTabsContentInsetWidth(sizeList) -
          _animation.value -
          indicatorWidth;
      state.update(_animation.value, right);
    });
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isIndicatorAnimPlaying = false;
      }
    });

    _animationController.forward();
  }
}
