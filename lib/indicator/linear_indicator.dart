import 'package:flutter/material.dart';

import '../custom_tab_bar.dart';
import '../tab_item_data.dart';

class LinearTabItem extends StatefulWidget {
  final Widget child;
  final TabItemData data;
  LinearTabItem({
    @required this.child,
    @required this.data,
    Key key,
  }) : super(key: key);

  @override
  _LinearTabItemState createState() => _LinearTabItemState();
}

class _LinearTabItemState extends State<LinearTabItem> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class LinearIndicator extends CustomTabIndicator {
  final Color indicatorColor;
  final LinearIndicatorController controller;
  LinearIndicator({
    @required this.indicatorColor,
    @required this.controller,
    Key key,
  }) : super(controller: LinearIndicatorController(), key: key);

  @override
  _LinearIndicatorState createState() => _LinearIndicatorState();
}

class _LinearIndicatorState extends State<LinearIndicator>
    with TickerProviderStateMixin {
  double left = 0;
  double right = 0;
  @override
  void initState() {
    super.initState();
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
        height: 3,
        color: widget.indicatorColor,
      ),
    );
  }
}

class LinearIndicatorController extends CustomTabbarController {
  _LinearIndicatorState state;
  TickerProvider tickerProvider;

  double getTabIndicatorCenterX(double width) {
    return width / 2;
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

    //当前Item在layout中的X坐标
    double currenIndexScrollX = getTargetItemScrollEndX(sizeList, currentIndex);
    //所有内容的宽度
    double tabContentInsert = getTabsContentInsetWidth(sizeList);
    double left = 0;
    double right = 0;

    //当前Item的宽度
    double currentIndexWidth = sizeList[currentIndex].width;

    //获取下一个Item的宽度
    double nextIndexWidth = 0;
    if (currentIndex < sizeList.length - 1) {
      nextIndexWidth = sizeList[currentIndex + 1].width;
    } else {
      return;
    }

    left = currenIndexScrollX - currentIndexWidth + currentIndexWidth * percent;
    right = tabContentInsert - currenIndexScrollX - nextIndexWidth * percent;

    lastScrollProgress = scrollProgress;
    state.update(left, right);
  }

  AnimationController _animationController;
  Animation _animation;

  @override
  void dispose() {
    if (_animationController != null) {
      _animationController.stop(canceled: true);
    }
  }

  @override
  void indicatorScrollToIndex(
      int index, List<Size> sizeList, Duration duration) {
    isIndicatorAnimPlaying = true;

    double left = state.left;
    double right = state.right;
    double width = getTabsContentInsetWidth(sizeList) - right - left;
    double targetLeft = getTargetItemScrollStartX(sizeList, index);
    if (targetLeft == left) return;

    _animationController =
        AnimationController(duration: duration, vsync: tickerProvider);

    _animation =
        Tween(begin: left, end: targetLeft).animate(_animationController);

    _animation.addListener(() {
      double rate = 0;
      double targetRight = 0;
      if (left > targetLeft) {
        rate = 1 - (targetLeft - _animation.value) / (targetLeft - left);
        targetRight = getTabsContentInsetWidth(sizeList) -
            _animation.value -
            width -
            (sizeList[index].width - width) * rate;
      } else {
        rate = (_animation.value - left) / (targetLeft - left);
        targetRight = getTabsContentInsetWidth(sizeList) -
            _animation.value -
            width -
            (sizeList[index].width - width) * rate;
      }
      state.update(_animation.value, targetRight);
    });
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isIndicatorAnimPlaying = false;
      }
    });

    _animationController.forward();
  }

  @override
  void updateSelectedIndex(TabItemListState state) {}
}
