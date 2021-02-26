# custom_tab_bar

a custom tabbar

![]()
<img src="https://raw.githubusercontent.com/lazyee/ImageHosting/master/img/bh0im-enjiw.gif" width="187" height="333">

```dart
class _MyHomePageState extends State<MyHomePage> {
  final int pageCount = 20;
  final PageController _controller = PageController();
  final StandardIndicatorController _indicatorController =
      StandardIndicatorController();

  Widget getTabbarChild(BuildContext context, int index, double page,
      bool isTapJumpPage, int currentIndex) {
    return StandardTabItem(
        child: Container(
          padding: EdgeInsets.all(2),
          alignment: Alignment.center,
          constraints: BoxConstraints(minWidth: 60),
          child: (Text(
            'Tab$index',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          )),
        ),
        currentIndex: currentIndex,
        isTapJumpPage: isTapJumpPage,
        index: index,
        page: page);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(children: [
          Container(
            height: 35,
            child: CustomTabBar(
              defaultPage: 0,
              itemCount: pageCount,
              builder: getTabbarChild,
              tabIndicator: StandardIndicator(
                indicatorWidth: 20,
                indicatorColor: Colors.blue,
                indicatorController: _indicatorController,
              ),
              pageController: _controller,
            ),
          ),
          Expanded(
              child: PageView.builder(
                  controller: _controller,
                  itemCount: pageCount,
                  // onPageChanged: ,
                  itemBuilder: (context, index) {
                    return PageItem(index);
                  }))
        ]));
  }
}

class PageItem extends StatefulWidget {
  final int index;
  PageItem(this.index, {Key key}) : super(key: key);

  @override
  _PageItemState createState() => _PageItemState();
}

class _PageItemState extends State<PageItem>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('build index:${widget.index} page');
    return Container(
      // color: Colors.pink,
      child: Text('index:${widget.index}'),
      alignment: Alignment.center,
    );
  }

  @override
  // bool get wantKeepAlive => false;
  bool get wantKeepAlive => true;
}


```


