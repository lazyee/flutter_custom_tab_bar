import 'package:flutter/material.dart';

import '../custom_tab_bar.dart';
import '../tab_item_data.dart';

class StandardTabItem extends StatefulWidget {
  final Widget child;
  final TabItemData data;
  StandardTabItem({
    @required this.child,
    @required this.data,
    Key key,
  }) : super(key: key);

  @override
  _StandardTabItemState createState() => _StandardTabItemState();
}

class _StandardTabItemState extends State<StandardTabItem> {
  double scalePercent = 0;

  void _calculateScalePercent() {
    var tabItemData = widget.data;
    scalePercent = tabItemData.page % 1.0;

    if (tabItemData.isTapJumpPage) {
      scalePercent = tabItemData.currentIndex == tabItemData.itemIndex ? 1 : 0;
    } else {
      var itemIndex = tabItemData.page.ceil();
      if (tabItemData.itemIndex != itemIndex) {
        itemIndex = tabItemData.page.floor();
      }

      if (itemIndex == tabItemData.itemIndex) {
        if (tabItemData.page.floor() == itemIndex) {
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
  final StandardIndicatorController controller;

  StandardIndicator({
    @required this.indicatorWidth,
    @required this.indicatorColor,
    @required this.controller,
    Key key,
  }) : super(controller: controller, key: key);

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

    widget.controller.indicatorWidth = widget.indicatorWidth;
    widget.controller.state = this;
    widget.controller.tickerProvider = this;
  }

  void update(double left, double right) {
    setState(() {
      this.left = left;
      this.right = right;
    });
  }

  @override
  void dispose() {
    if (widget.controller != null) {
      widget.controller.dispose();
    }
    super.dispose();
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
  TickerProvider tickerProvider;

  double getTabIndicatorCenterX(double width) {
    return width / 2;
  }

  @override
  void dispose() {
    if (_animationController != null) {
      _animationController.stop(canceled: true);
    }
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

    double currenIndexScrollX = getTargetItemScrollEndX(sizeList, currentIndex);
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
    double targetLeft = getTargetItemScrollEndX(sizeList, index) -
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

  @override
  void updateSelectedIndex(TabItemListState state) {
    state.notifyUpdate();
  }
}
