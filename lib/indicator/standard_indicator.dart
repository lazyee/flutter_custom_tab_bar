import 'package:flutter/material.dart';

import '../custom_tab_bar.dart';
import '../tab_bar_item_info.dart';
import '../tab_bar_item_row.dart';

class StandardIndicator extends CustomTabIndicator {
  final double indicatorWidth;
  final Color indicatorColor;
  final StandardIndicatorController controller;

  StandardIndicator({
    required this.indicatorWidth,
    required this.indicatorColor,
    required this.controller,
    Key? key,
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
    widget.controller.dispose();
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

class StandardIndicatorController extends CustomTabBarController {
  late _StandardIndicatorState state;
  double indicatorWidth = 0;
  late TickerProvider tickerProvider;

  double getTabIndicatorCenterX(double width) {
    return width / 2;
  }

  @override
  void dispose() {
    if (_animationController != null) {
      _animationController!.stop(canceled: true);
    }
  }

  double? lastScrollProgress = 0;
  @override
  void updateScrollIndicator(double? scrollProgress,
      List<TabBarItemInfo>? tabbarItemInfoList, Duration duration) {
    if (isJumpPage) return;
    double percent = scrollProgress! % 1.0;

    ///确定当前索引值位置
    int currentIndex = 0;
    if (scrollProgress > lastScrollProgress!) {
      if (scrollProgress.toInt() > lastScrollProgress!.toInt()) {
        currentIndex = scrollProgress.toInt();
      } else {
        currentIndex = lastScrollProgress!.toInt();
        percent = percent == 0 ? 1 : percent;
      }
    } else {
      currentIndex = scrollProgress.toInt();
    }

    double currenIndexScrollX =
        getTargetItemScrollEndX(tabbarItemInfoList, currentIndex);
    double tabContentInsert = getTabsContentInsetWidth(tabbarItemInfoList);
    double left = 0;
    double right = 0;

    double currentIndexItemWidth =
        tabbarItemInfoList![currentIndex].size!.width;
    double nextIndexItemWidth = 0;
    if (currentIndex <= tabbarItemInfoList.length - 1) {
      nextIndexItemWidth = tabbarItemInfoList[currentIndex + 1].size!.width;
    } else {
      return;
    }

    if (percent <= 0.5) {
      left =
          currenIndexScrollX - (currentIndexItemWidth + indicatorWidth) * 0.5;
      right = tabContentInsert -
          currenIndexScrollX +
          currentIndexItemWidth * (0.5 - percent) -
          indicatorWidth * 0.5 -
          nextIndexItemWidth * percent;
    } else {
      left = currenIndexScrollX -
          indicatorWidth * 0.5 -
          nextIndexItemWidth * (0.5 - percent) -
          currentIndexItemWidth * (1 - percent);

      right = tabContentInsert -
          currenIndexScrollX -
          (nextIndexItemWidth + indicatorWidth) / 2;
    }

    lastScrollProgress = scrollProgress;
    state.update(left, right);
  }

  AnimationController? _animationController;
  late Animation _animation;

  @override
  void indicatorScrollToIndex(
      int index, List<TabBarItemInfo>? tabbarItemInfoList, Duration duration) {
    double left = state.left;
    double targetLeft = getTargetItemScrollEndX(tabbarItemInfoList, index) -
        (tabbarItemInfoList![index].size!.width + indicatorWidth) / 2;

    _animationController =
        AnimationController(duration: duration, vsync: tickerProvider);

    _animation =
        Tween(begin: left, end: targetLeft).animate(_animationController!);
    _animation.addListener(() {
      double right = getTabsContentInsetWidth(tabbarItemInfoList) -
          _animation.value -
          indicatorWidth;
      state.update(_animation.value, right);
    });

    _animationController!.forward();
  }

  @override
  void updateSelectedIndex(TabBarItemRowState state) {
    state.notifyUpdate(0.0);
  }
}
