library flutter_custom_tab_bar;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomTabBar extends StatefulWidget {
  final List<Widget> children;
  final CustomTabIndicator tabIndicator;
  final PageController pageController;

  const CustomTabBar(
      {@required this.children,
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
  final Duration animDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    sizeList = List(widget.children.length);

    widget.pageController.addListener(() {
      if (widget.pageController.page % 1.0 == 0) {
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

  Widget _buildSlivers() {
    List<Widget> slivers = [];
    List<Widget> tabItems = [];

    for (int i = 0; i < widget.children.length; i++) {
      tabItems.add(InkWell(
          onTap: () {
            widget.tabIndicator.controller.scrollTargetIndexTarBarItemToCenter(
                _scrollableKey.currentContext.size.width / 2,
                i,
                sizeList,
                _scrollController,
                animDuration);

            widget.tabIndicator.controller
                .indicatorScrollToIndex(i, sizeList, animDuration);

            widget.pageController
                .animateToPage(i, duration: animDuration, curve: Curves.ease);
          },
          child: _TabItem(
              child: widget.children[i], index: i, sizeList: sizeList)));
    }

    slivers.add(Stack(
      children: [
        Row(children: tabItems),
        widget.tabIndicator,
      ],
    ));
    return SliverList(delegate: SliverChildListDelegate(slivers));
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
