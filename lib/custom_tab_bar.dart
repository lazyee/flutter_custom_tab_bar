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
  final int initPage;
  final CustomTabIndicator? indicator;
  final PageController pageController;
  final CustomTabBarController controller;
  final Color backgroundColor;

  final double? height;
  final double? width;
  final Alignment alignment;
  final ScrollPhysics physics;

  const CustomTabBar(
      {required this.builder,
      required this.itemCount,
      required this.pageController,
      required this.controller,
      this.indicator,
      this.backgroundColor = Colors.transparent,
      this.initPage = 0,
      this.width,
      this.height,
      this.alignment = Alignment.center,
      this.physics = const AlwaysScrollableScrollPhysics(),
      Key? key})
      : assert((physics is NeverScrollableScrollPhysics && height == null) ||
            !(physics is NeverScrollableScrollPhysics) && height != null),
        super(key: key);

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  late List<TabBarItemInfo> tabBarItemInfoList;
  ScrollController? _scrollController;
  GlobalKey<TabBarItemRowState> _tabItemListState =
      GlobalKey<TabBarItemRowState>();
  final Duration animDuration = Duration(milliseconds: 300);
  final Duration tabBarScrollDuration = Duration(milliseconds: 300);
  int currentIndex = 0;

  double get getControllerPage => widget.pageController.positions.isNotEmpty
      ? widget.pageController.page ?? 0
      : 0;
  @override
  void initState() {
    super.initState();

    if (!(widget.physics is NeverScrollableScrollPhysics)) {
      _scrollController = ScrollController();
    }

    tabBarItemInfoList =
        List.generate(widget.itemCount, (i) => TabBarItemInfo.create());

    widget.pageController.addListener(() {
      _tabItemListState.currentState!.updateSelectedIndex();
      widget.controller.scroll(getViewportWidth() / 2, tabBarItemInfoList,
          _scrollController, widget.pageController);
      _tabItemListState.currentState!.notifyUpdate(getControllerPage);
      currentIndex = getControllerPage.toInt();

      widget.indicator?.controller.updateScrollIndicator(
          getControllerPage, tabBarItemInfoList, animDuration);
    });

    ///延迟一下获取具体的size
    Future.delayed(Duration(milliseconds: 0), () {
      widget.pageController.jumpToPage(widget.initPage);
      widget.indicator?.controller.updateScrollIndicator(
          getControllerPage, tabBarItemInfoList, animDuration);
    });
  }

  double getViewportWidth() {
    if (widget.width != null) {
      return widget.width!;
    }

    if (_viewportWidth == 0) {
      return MediaQuery.of(context).size.width;
    }
    return _viewportWidth;
  }

  double _viewportWidth = 0;
  double? getViewportHeight() {
    if (widget.physics is NeverScrollableScrollPhysics) {
      return null;
    }
    return widget.height;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: widget.alignment,
        height: getViewportHeight(),
        width: getViewportWidth(),
        decoration: BoxDecoration(color: widget.backgroundColor),
        child: widget.physics is NeverScrollableScrollPhysics
            ? _buildTabBarItemRow()
            : MeasureSizeBox(
                onSizeCallback: (size) {
                  _viewportWidth = size.width;
                },
                child: Scrollable(
                  controller: _scrollController,
                  viewportBuilder: _buildViewport,
                  axisDirection: AxisDirection.right,
                  physics: widget.physics,
                )));
  }

  Widget _buildViewport(BuildContext context, ViewportOffset offset) {
    return Viewport(
      offset: offset,
      axisDirection: AxisDirection.right,
      slivers: [_buildSlivers()],
    );
  }

  ///点击tabbar Item
  void _onTapItem(int index) {
    if (widget.controller.isJumpPage) return;
    tabBarItemInfoList.forEach((element) {
      element.jumpPageIndex = index;
    });
    widget.controller.scrollTargetIndexTarBarItemToCenter(
        getViewportWidth() / 2,
        index,
        tabBarItemInfoList,
        _scrollController,
        tabBarScrollDuration);

    if (widget.indicator != null) {
      widget.indicator!.controller
          .indicatorScrollToIndex(index, tabBarItemInfoList, animDuration);
    }

    widget.pageController
        .animateToPage(index, duration: animDuration, curve: Curves.ease);
  }

  Widget _buildTabBarItemRow() {
    return Stack(children: [
      if (widget.indicator != null) widget.indicator!,
      TabBarItemRow(
        viewPortWidth: widget.physics is NeverScrollableScrollPhysics
            ? getViewportWidth()
            : null,
        physics: widget.physics,
        key: _tabItemListState,
        controller: widget.controller,
        builder: (context, index) {
          tabBarItemInfoList[index]
            ..currentIndex = currentIndex
            ..isJumpPage = widget.controller.isJumpPage
            ..itemIndex = index
            ..page = getControllerPage;
          return widget.builder(context, tabBarItemInfoList[index]);
        },
        onTapItem: _onTapItem,
        itemCount: widget.itemCount,
        tabBarItemInfoList: tabBarItemInfoList,
      )
    ]);
  }

  Widget _buildSlivers() {
    return SliverList(
        delegate: SliverChildListDelegate([_buildTabBarItemRow()]));
  }
}

abstract class CustomTabIndicator extends StatefulWidget {
  final CustomTabBarController controller;
  CustomTabIndicator({required this.controller, Key? key}) : super(key: key);
}

abstract class CustomTabBarController {
  void updateSelectedIndex(TabBarItemRowState state);

  ///根据pageController来设置偏移量
  void scroll(double tabCenterX, List<TabBarItemInfo>? tabbarItemInfoList,
      ScrollController? scrollController, PageController pageController) {
    if (isJumpPage) return;
    if (scrollController == null) return;
    var index = pageController.page!.ceil();
    var preIndex = pageController.page!.floor();
    var offsetPercent = pageController.page! % 1;
    var total = tabbarItemInfoList![index].size!.width / 2 +
        tabbarItemInfoList[preIndex].size!.width / 2;
    var startX = getTargetItemScrollStartX(tabbarItemInfoList, preIndex);
    var endX = startX + tabbarItemInfoList[preIndex].size!.width / 2;
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
      List<TabBarItemInfo>? tabbarItemInfoList, double tabbarWidth) {
    var startX = getTargetItemScrollStartX(tabbarItemInfoList, index);
    return scrollController.position.pixels < startX &&
        startX < scrollController.position.pixels + tabbarWidth;
  }

  int lastIndex = 0;

  ///滚动目标索引的项到中间位置
  void scrollTargetIndexTarBarItemToCenter(
      double tabCenterX,
      int currentIndex,
      List<TabBarItemInfo>? tabbarItemInfoList,
      ScrollController? scrollController,
      Duration duration) {
    if (isJumpPage) return;
    if (currentIndex == lastIndex) return;

    // print(tabbarItemInfoList![currentIndex].size);

    var targetItemScrollX =
        getTargetItemScrollEndX(tabbarItemInfoList, currentIndex);
    var contentInsertWidth = getTabsContentInsetWidth(tabbarItemInfoList);

    var animateToOffsetX = targetItemScrollX -
        tabbarItemInfoList![currentIndex].size!.width / 2 -
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

    scrollController?.animateTo(animateToOffsetX,
        duration: duration, curve: Curves.ease);

    Future.delayed(duration, () {
      isJumpPage = false;
    }).catchError((e) {});
  }

  void updateScrollIndicator(
    double? scrollProgress,
    List<TabBarItemInfo>? tabbarItemInfoList,
    Duration duration,
  );
  void indicatorScrollToIndex(
    int index,
    List<TabBarItemInfo>? tabbarItemInfoList,
    Duration duration,
  );

  void dispose();

  bool isJumpPage = false;

  double getTargetItemScrollEndX(
      List<TabBarItemInfo>? tabbarItemInfoList, int index) {
    double totalX = 0;
    for (int i = 0; i <= index; i++) {
      totalX += tabbarItemInfoList![i].size!.width;
    }
    return totalX;
  }

  double getTargetItemScrollStartX(
      List<TabBarItemInfo>? tabbarItemInfoList, int index) {
    double totalX = 0;
    for (int i = 0; i < index; i++) {
      totalX += tabbarItemInfoList![i].size!.width;
    }
    return totalX;
  }

  double tabsContentInsetWidth = 0;
  double getTabsContentInsetWidth(List<TabBarItemInfo>? tabbarItemInfoList) {
    if (tabsContentInsetWidth == 0) {
      tabbarItemInfoList!.forEach((item) {
        tabsContentInsetWidth += item.size!.width;
      });
    }
    return tabsContentInsetWidth;
  }
}
