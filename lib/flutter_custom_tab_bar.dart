library flutter_custom_tab_bar;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef IndexedTabItemBuilder = Widget Function(
    BuildContext context, int index, double page);

class CustomTabBar extends StatefulWidget {
  final IndexedTabItemBuilder builder;
  final int itemCount;
  final CustomTabIndicator tabIndicator;
  final PageController pageController;

  const CustomTabBar(
      {@required this.builder,
      @required this.itemCount,
      @required this.pageController,
      @required this.tabIndicator,
      Key key})
      : super(key: key);

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  List<Size> sizeList;
  ScrollController _scrollController = ScrollController();
  GlobalKey _scrollableKey = GlobalKey();
  GlobalKey<__TabItemListState> _tabItemListState =
      GlobalKey<__TabItemListState>();
  final Duration animDuration = Duration(milliseconds: 300);
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    sizeList = List(widget.itemCount);
    // sizeList = List(widget.children.length);

    widget.pageController.addListener(() {
      if (widget.pageController.page % 1.0 == 0) {
        _tabItemListState.currentState.updateSelectedIndex();

        widget.tabIndicator.controller.scrollTargetIndexTarBarItemToCenter(
            _scrollableKey.currentContext.size.width / 2,
            widget.pageController.page.toInt(),
            sizeList,
            _scrollController,
            animDuration);
      }
      widget.tabIndicator.controller.updateScrollIndicator(
          widget.pageController.page, sizeList, animDuration);
    });

    ///延迟一下获取具体的size
    Future.delayed(Duration(milliseconds: 50), () {
      widget.tabIndicator.controller.updateScrollIndicator(
          widget.pageController.page, sizeList, animDuration);
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
    widget.tabIndicator.controller.scrollTargetIndexTarBarItemToCenter(
        _scrollableKey.currentContext.size.width / 2,
        index,
        sizeList,
        _scrollController,
        animDuration);

    widget.tabIndicator.controller
        .indicatorScrollToIndex(index, sizeList, animDuration);

    widget.pageController
        .animateToPage(index, duration: animDuration, curve: Curves.ease);
  }

  Widget _buildSlivers() {
    var listView = _TabItemList(
      key: _tabItemListState,
      builder: (context, index) =>
          widget.builder(context, index, widget.pageController.page ?? 0),
      onTapTabItem: _onTapTabItem,
      itemCount: widget.itemCount,
      sizeList: sizeList,
    );

    var child = Stack(
      children: [
        listView,
        widget.tabIndicator,
      ],
    );
    return SliverList(delegate: SliverChildListDelegate([child]));
  }
}

class _TabItemList extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder builder;
  final List<Size> sizeList;
  final void Function(int index) onTapTabItem;
  _TabItemList(
      {@required this.itemCount,
      @required this.builder,
      @required this.sizeList,
      @required this.onTapTabItem,
      key})
      : super(key: key);

  @override
  __TabItemListState createState() => __TabItemListState();
}

class __TabItemListState extends State<_TabItemList> {
  void updateSelectedIndex() {
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
                // widget.builder(context, index, widget.pageController.page),
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
  final CustomTabIndicatorMixin controller;
  CustomTabIndicator({@required this.controller, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => null;
}

mixin CustomTabIndicatorMixin {
  ///滚动目标索引的项到中间位置
  void scrollTargetIndexTarBarItemToCenter(
    double tabCenterX,
    int currentIndex,
    List<Size> sizeList,
    ScrollController scrollController,
    Duration duration,
  );
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
}
