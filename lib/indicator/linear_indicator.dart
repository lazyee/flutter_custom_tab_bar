import 'package:flutter/material.dart';

import '../custom_tab_bar.dart';
import '../tab_bar_item_info.dart';
import '../tab_bar_item_row.dart';

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
  void updateScrollIndicator(double scrollProgress,
      List<TabBarItemInfo> tabbarItemInfoList, Duration duration) {
    if (isJumpPage) return;

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
    double currenIndexScrollX =
        getTargetItemScrollEndX(tabbarItemInfoList, currentIndex);
    //所有内容的宽度
    double tabContentInsert = getTabsContentInsetWidth(tabbarItemInfoList);
    double left = 0;
    double right = 0;

    //当前Item的宽度
    double currentIndexWidth = tabbarItemInfoList[currentIndex].size.width;

    //获取下一个Item的宽度
    double nextIndexWidth = 0;
    if (currentIndex < tabbarItemInfoList.length - 1) {
      nextIndexWidth = tabbarItemInfoList[currentIndex + 1].size.width;
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
      int index, List<TabBarItemInfo> tabbarItemInfoList, Duration duration) {
    // isJumpPage = true;

    double left = state.left;
    double right = state.right;
    double width = getTabsContentInsetWidth(tabbarItemInfoList) - right - left;
    double targetLeft = getTargetItemScrollStartX(tabbarItemInfoList, index);
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
        targetRight = getTabsContentInsetWidth(tabbarItemInfoList) -
            _animation.value -
            width -
            (tabbarItemInfoList[index].size.width - width) * rate;
      } else {
        rate = (_animation.value - left) / (targetLeft - left);
        targetRight = getTabsContentInsetWidth(tabbarItemInfoList) -
            _animation.value -
            width -
            (tabbarItemInfoList[index].size.width - width) * rate;
      }
      state.update(_animation.value, targetRight);
    });
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isJumpPage = false;
      }
    });

    _animationController.forward();
  }

  @override
  void updateSelectedIndex(TabBarItemRowState state) {}
}
