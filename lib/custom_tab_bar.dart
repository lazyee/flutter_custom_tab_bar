library flutter_custom_tab_bar;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'tab_bar_item_info.dart';
import 'tab_bar_item_row.dart';

typedef IndexedTabItemBuilder = Widget Function(
    BuildContext context, TabBarItemInfo controller);

class CustomTabBar extends StatefulWidget {
  final IndexedTabItemBuilder builder;
  final int itemCount;
  final int defaultPage;
  final CustomTabIndicator indicator;
  final PageController pageController;
  final CustomTabbarController tabbarController;
  final Color backgroundColor;
  final EdgeInsets padding;
  final double height;
  final double width;

  const CustomTabBar(
      {@required this.builder,
      @required this.itemCount,
      @required this.pageController,
      @required this.tabbarController,
      this.indicator,
      this.backgroundColor = Colors.transparent,
      this.padding,
      this.defaultPage = 0,
      this.width,
      this.height = 35,
      Key key})
      : super(key: key);

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  List<TabBarItemInfo> tabbarItemInfoList;
  ScrollController _scrollController = ScrollController();
  GlobalKey _scrollableKey = GlobalKey();
  GlobalKey<TabBarItemRowState> _tabItemListState =
      GlobalKey<TabBarItemRowState>();
  final Duration animDuration = Duration(milliseconds: 300);
  final Duration tabBarScrollDuration = Duration(milliseconds: 300);
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    tabbarItemInfoList = List(widget.itemCount);

    widget.pageController.addListener(() {
      _tabItemListState.currentState.updateSelectedIndex();
      widget.tabbarController.scroll(
          _scrollableKey.currentContext.size.width / 2,
          tabbarItemInfoList,
          _scrollController,
          widget.pageController);
      _tabItemListState.currentState.notifyUpdate(widget.pageController.page);
      currentIndex = widget.pageController.page.toInt();
      if (widget.indicator != null) {
        widget.indicator.controller.updateScrollIndicator(
            widget.pageController.page, tabbarItemInfoList, animDuration);
      }
    });

    ///延迟一下获取具体的size
    Future.delayed(Duration(milliseconds: 0), () {
      widget.pageController.jumpToPage(widget.defaultPage);

      if (widget.indicator != null) {
        widget.indicator.controller.updateScrollIndicator(
            widget.pageController.page, tabbarItemInfoList, animDuration);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.width,
        height: widget.height,
        padding: widget.padding ?? EdgeInsets.all(0.0),
        decoration: BoxDecoration(color: widget.backgroundColor),
        child: Scrollable(
          key: _scrollableKey,
          controller: _scrollController,
          viewportBuilder: _buildViewport,
          axisDirection: AxisDirection.right,
          physics: AlwaysScrollableScrollPhysics(),
        ));
  }

  Widget _buildViewport(BuildContext context, ViewportOffset offset) {
    return Viewport(
      offset: offset,
      axisDirection: AxisDirection.right,
      slivers: [_buildSlivers()],
    );
  }

  ///点击tabbar Item
  void _onTapTabbarItem(int index) {
    if (widget.tabbarController.isJumpPage) return;
    tabbarItemInfoList.forEach((element) {
      element.jumpPageIndex = index;
    });
    widget.tabbarController.scrollTargetIndexTarBarItemToCenter(
        _scrollableKey.currentContext.size.width / 2,
        index,
        tabbarItemInfoList,
        _scrollController,
        tabBarScrollDuration);

    if (widget.indicator != null) {
      widget.indicator.controller
          .indicatorScrollToIndex(index, tabbarItemInfoList, animDuration);
    }

    widget.pageController
        .animateToPage(index, duration: animDuration, curve: Curves.ease);
  }

  Widget _buildSlivers() {
    var listView = TabBarItemRow(
      key: _tabItemListState,
      controller: widget.tabbarController,
      builder: (context, index) {
        if (tabbarItemInfoList[index] == null) {
          tabbarItemInfoList[index] = TabBarItemInfo.create();
        }
        tabbarItemInfoList[index]
          ..currentIndex = currentIndex
          ..isJumpPage = widget.tabbarController.isJumpPage
          ..itemIndex = index
          ..page = widget.pageController.page ?? 0;
        return widget.builder(context, tabbarItemInfoList[index]);
      },
      onTapTabItem: _onTapTabbarItem,
      itemCount: widget.itemCount,
      tabbarItemInfoList: tabbarItemInfoList,
    );

    var child = Stack(
      children: [
        if (widget.indicator != null) widget.indicator,
        listView,
      ],
    );
    return SliverList(delegate: SliverChildListDelegate([child]));
  }
}

class CustomTabIndicator extends StatefulWidget {
  final CustomTabbarController controller;
  CustomTabIndicator({@required this.controller, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => null;
}

abstract class CustomTabbarController {
  void updateSelectedIndex(TabBarItemRowState state);

  ///根据pageController来设置偏移量
  void scroll(double tabCenterX, List<TabBarItemInfo> tabbarItemInfoList,
      ScrollController scrollController, PageController pageController) {
    if (isJumpPage) return;
    var index = pageController.page.ceil();
    var preIndex = pageController.page.floor();
    var offsetPercent = pageController.page % 1;
    var total = tabbarItemInfoList[index].size.width / 2 +
        tabbarItemInfoList[preIndex].size.width / 2;
    var startX = getTargetItemScrollStartX(tabbarItemInfoList, preIndex);
    var endX = startX + tabbarItemInfoList[preIndex].size.width / 2;
    var offsetX = 0.0;
    var contentInsertWidth = getTabsContentInsetWidth(tabbarItemInfoList);
    bool isVisible = isItemVisible(
        scrollController, index, tabbarItemInfoList, tabCenterX * 2);
    if (isVisible) {
      if (endX + total > tabCenterX) {
        if (endX > tabCenterX) {
          offsetX = endX - tabCenterX + offsetPercent * (total);
        } else {
          offsetX = offsetPercent * (total + endX - tabCenterX);
        }
        if (contentInsertWidth - offsetX - tabCenterX > tabCenterX) {
          scrollController.jumpTo(offsetX);
        }
      }
    } else {
      if (startX < tabCenterX) {
        scrollController.jumpTo(0);
      } else {
        scrollController.jumpTo(startX - tabCenterX);
      }
    }
  }

  ///判断item是否显示在可见区域
  bool isItemVisible(ScrollController scrollController, index,
      List<TabBarItemInfo> tabbarItemInfoList, double tabbarWidth) {
    var startX = getTargetItemScrollStartX(tabbarItemInfoList, index);
    return scrollController.position.pixels < startX &&
        startX < scrollController.position.pixels + tabbarWidth;
  }

  int lastIndex = 0;

  ///滚动目标索引的项到中间位置
  void scrollTargetIndexTarBarItemToCenter(
      double tabCenterX,
      int currentIndex,
      List<TabBarItemInfo> tabbarItemInfoList,
      ScrollController scrollController,
      Duration duration) {
    if (isJumpPage) return;
    if (currentIndex == lastIndex) return;

    var targetItemScrollX =
        getTargetItemScrollEndX(tabbarItemInfoList, currentIndex);
    var contentInsertWidth = getTabsContentInsetWidth(tabbarItemInfoList);

    var animateToOffsetX = targetItemScrollX -
        tabbarItemInfoList[currentIndex].size.width / 2 -
        tabCenterX;

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
    isJumpPage = true;

    lastIndex = currentIndex;

    scrollController.animateTo(animateToOffsetX,
        duration: duration, curve: Curves.ease);

    Future.delayed(duration, () {
      isJumpPage = false;
    }).catchError((e) {});
  }

  void updateScrollIndicator(
    double scrollProgress,
    List<TabBarItemInfo> tabbarItemInfoList,
    Duration duration,
  );
  void indicatorScrollToIndex(
    int index,
    List<TabBarItemInfo> tabbarItemInfoList,
    Duration duration,
  );

  void dispose();

  bool isJumpPage = false;

  double getTargetItemScrollEndX(
      List<TabBarItemInfo> tabbarItemInfoList, int index) {
    double totalX = 0;
    for (int i = 0; i <= index; i++) {
      totalX += tabbarItemInfoList[i].size.width;
    }
    return totalX;
  }

  double getTargetItemScrollStartX(
      List<TabBarItemInfo> tabbarItemInfoList, int index) {
    double totalX = 0;
    for (int i = 0; i < index; i++) {
      totalX += tabbarItemInfoList[i].size.width;
    }
    return totalX;
  }

  double tabsContentInsetWidth = 0;
  double getTabsContentInsetWidth(List<TabBarItemInfo> tabbarItemInfoList) {
    if (tabsContentInsetWidth == 0) {
      tabbarItemInfoList.forEach((item) {
        if (item != null) {
          tabsContentInsetWidth += item.size.width;
        }
      });
    }
    return tabsContentInsetWidth;
  }
}
