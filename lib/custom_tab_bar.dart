library flutter_custom_tab_bar;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'tab_item_data.dart';

typedef IndexedTabItemBuilder = Widget Function(
    BuildContext context, TabItemData controller);

class CustomTabBar extends StatefulWidget {
  final IndexedTabItemBuilder builder;
  final int itemCount;
  final int defaultPage;
  final CustomTabIndicator tabIndicator;
  final PageController pageController;
  final CustomTabbarController tabbarController;

  const CustomTabBar(
      {@required this.builder,
      @required this.itemCount,
      @required this.pageController,
      @required this.tabbarController,
      this.tabIndicator,
      this.defaultPage = 0,
      Key key})
      : super(key: key);

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  List<Size> sizeList;
  ScrollController _scrollController = ScrollController();
  GlobalKey _scrollableKey = GlobalKey();
  GlobalKey<TabItemListState> _tabItemListState = GlobalKey<TabItemListState>();
  final Duration animDuration = Duration(milliseconds: 300);
  final Duration tabBarScrollDuration = Duration(milliseconds: 300);
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    sizeList = List(widget.itemCount);

    widget.pageController.addListener(() {
      _tabItemListState.currentState.updateSelectedIndex();
      widget.tabbarController.scroll(
          _scrollableKey.currentContext.size.width / 2,
          sizeList,
          _scrollController,
          widget.pageController);
      if (widget.pageController.page % 1.0 == 0) {
        _tabItemListState.currentState.notifyUpdate();
        currentIndex = widget.pageController.page.toInt();

        // widget.tabbarController.scrollTargetIndexTarBarItemToCenter(
        //     _scrollableKey.currentContext.size.width / 2,
        //     currentIndex,
        //     sizeList,
        //     _scrollController,
        //     tabBarScrollDuration);
      }
      if (widget.tabIndicator != null) {
        widget.tabIndicator.controller.updateScrollIndicator(
            widget.pageController.page, sizeList, animDuration);
      }
    });

    ///延迟一下获取具体的size
    Future.delayed(Duration(milliseconds: 0), () {
      widget.pageController.jumpToPage(widget.defaultPage);

      if (widget.tabIndicator != null) {
        widget.tabIndicator.controller.updateScrollIndicator(
            widget.pageController.page, sizeList, animDuration);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scrollable(
      key: _scrollableKey,
      controller: _scrollController,
      viewportBuilder: _buildViewport,
      axisDirection: AxisDirection.right,
      physics: AlwaysScrollableScrollPhysics(),
    );
  }

  Widget _buildViewport(BuildContext context, ViewportOffset offset) {
    return Viewport(
      offset: offset,
      axisDirection: AxisDirection.right,
      slivers: [_buildSlivers()],
    );
  }

  void _onTapTabItem(int index) {
    currentIndex = index;
    widget.tabbarController.scrollTargetIndexTarBarItemToCenter(
        _scrollableKey.currentContext.size.width / 2,
        index,
        sizeList,
        _scrollController,
        tabBarScrollDuration);

    if (widget.tabIndicator != null) {
      widget.tabIndicator.controller
          .indicatorScrollToIndex(index, sizeList, animDuration);
    }

    widget.pageController
        .animateToPage(index, duration: animDuration, curve: Curves.ease);
  }

  Widget _buildSlivers() {
    var listView = TabItemList(
      key: _tabItemListState,
      controller: widget.tabbarController,
      builder: (context, index) {
        var tabItemData = TabItemData.create(
            itemIndex: index,
            currentIndex: currentIndex,
            isTapJumpPage: widget.tabbarController.isIndicatorAnimPlaying,
            page: widget.pageController.page ?? 0);
        return widget.builder(context, tabItemData);
      },
      onTapTabItem: _onTapTabItem,
      itemCount: widget.itemCount,
      sizeList: sizeList,
    );

    var child = Stack(
      children: [
        if (widget.tabIndicator != null) widget.tabIndicator,
        listView,
      ],
    );
    return SliverList(delegate: SliverChildListDelegate([child]));
  }
}

class TabItemList extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder builder;
  final List<Size> sizeList;
  final void Function(int index) onTapTabItem;
  final CustomTabbarController controller;
  TabItemList(
      {@required this.itemCount,
      @required this.builder,
      @required this.sizeList,
      @required this.onTapTabItem,
      @required this.controller,
      key})
      : super(key: key);

  @override
  TabItemListState createState() => TabItemListState();
}

class TabItemListState extends State<TabItemList> {
  void updateSelectedIndex() {
    if (widget.controller != null) {
      widget.controller.updateSelectedIndex(this);
    }
  }

  ///通知更新
  void notifyUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return InkWell(
              onTap: () => widget.onTapTabItem(index),
              child: _TabItem(
                child: widget.builder(context, index),
                sizeList: widget.sizeList,
                index: index,
              ));
        },
        shrinkWrap: true,
        itemCount: widget.itemCount);
  }
}

class _TabItem extends SingleChildRenderObjectWidget {
  final Widget child;
  final List<Size> sizeList;
  final int index;
  _TabItem({
    @required this.child,
    @required this.index,
    @required this.sizeList,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _TabRenderObj(index: this.index, sizeList: this.sizeList);
  }
}

class _TabRenderObj extends RenderConstrainedBox {
  final List<Size> sizeList;
  final int index;
  _TabRenderObj({@required this.index, @required this.sizeList})
      : super(additionalConstraints: BoxConstraints());

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    super.layout(constraints, parentUsesSize: parentUsesSize);

    sizeList[index] = Size.copy(size);
  }
}

class CustomTabIndicator extends StatefulWidget {
  final CustomTabbarController controller;
  CustomTabIndicator({@required this.controller, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => null;
}

abstract class CustomTabbarController {
  void updateSelectedIndex(TabItemListState state);

  ///根据pageController来设置偏移量
  void scroll(double tabCenterX, List<Size> sizeList,
      ScrollController scrollController, PageController pageController) {
    if (isIndicatorAnimPlaying) return;
    var index = pageController.page.ceil();
    var preIndex = pageController.page.floor();
    var offsetPercent = pageController.page % 1;
    var total = sizeList[index].width / 2 + sizeList[preIndex].width / 2;

    var endX = getTargetItemScrollStartX(sizeList, preIndex) +
        sizeList[preIndex].width / 2;
    var offsetX = 0.0;
    var contentInsertWidth = getTabsContentInsetWidth(sizeList);
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
  }

  int lastIndex = 0;

  ///滚动目标索引的项到中间位置
  void scrollTargetIndexTarBarItemToCenter(
      double tabCenterX,
      int currentIndex,
      List<Size> sizeList,
      ScrollController scrollController,
      Duration duration) {
    {
      if (isIndicatorAnimPlaying) return;
      if (currentIndex == lastIndex) return;

      var targetItemScrollX = getTargetItemScrollEndX(sizeList, currentIndex);
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
  }

  void updateScrollIndicator(
    double scrollProgress,
    List<Size> sizeList,
    Duration duration,
  );
  void indicatorScrollToIndex(
    int index,
    List<Size> sizeList,
    Duration duration,
  );

  void dispose();

  bool isIndicatorAnimPlaying = false;

  double getTargetItemScrollEndX(List<Size> sizeList, int index) {
    double totalX = 0;
    for (int i = 0; i <= index; i++) {
      totalX += sizeList[i].width;
    }
    return totalX;
  }

  double getTargetItemScrollStartX(List<Size> sizeList, int index) {
    double totalX = 0;
    for (int i = 0; i < index; i++) {
      totalX += sizeList[i].width;
    }
    return totalX;
  }

  double tabsContentInsetWidth = 0;
  double getTabsContentInsetWidth(List<Size> sizeList) {
    if (tabsContentInsetWidth == 0) {
      sizeList.forEach((item) {
        if (item != null) {
          tabsContentInsetWidth += item.width;
        }
      });
    }
    return tabsContentInsetWidth;
  }
}
