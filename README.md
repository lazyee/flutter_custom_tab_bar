# custom_tab_bar

a custom tabbar
![](https://raw.githubusercontent.com/lazyee/ImageHosting/master/img/standard.gif)
```dart
class _StandardTabBarPageState extends State<StandardTabBarPage> {
  final int pageCount = 20;
  final PageController _controller = PageController();
  StandardIndicatorController controller = StandardIndicatorController();

  Widget getTabbarChild(BuildContext context, TabItemData data) {
    return StandardTabItem(
        child: Container(
          padding: EdgeInsets.all(2),
          alignment: Alignment.center,
          constraints: BoxConstraints(minWidth: 60),
          child: (Text(
            'Tab${data.itemIndex}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          )),
        ),
        data: data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Standard Indicator')),
      body: Column(
        children: [
          Container(
            height: 35,
            child: CustomTabBar(
              defaultPage: 0,
              itemCount: pageCount,
              builder: getTabbarChild,
              tabIndicator: StandardIndicator(
                indicatorWidth: 20,
                indicatorColor: Colors.green,
                controller: controller,
              ),
              pageController: _controller,
            ),
          ),
          Expanded(
              child: PageView.builder(
                  controller: _controller,
                  itemCount: pageCount,
                  itemBuilder: (context, index) {
                    return PageItem(index);
                  }))
        ],
      ),
    );
  }
}

```
![](https://raw.githubusercontent.com/lazyee/ImageHosting/master/img/linear.gif)
```dart
class _LinearTabBarPageState extends State<LinearTabBarPage> {
  final int pageCount = 20;
  final PageController _controller = PageController();
  final LinearIndicatorController _linearIndicatorController =
      LinearIndicatorController();

  Widget getTabbarChild(BuildContext context, TabItemData data) {
    return LinearTabItem(
        child: Container(
          padding: EdgeInsets.all(2),
          alignment: Alignment.center,
          constraints: BoxConstraints(minWidth: 60),
          child: (Text(
            data.itemIndex == 5 ? 'Tab555555555555' : 'Tab${data.itemIndex}',
            style: TextStyle(
              fontSize: 14,
              color: data.currentIndex == data.itemIndex
                  ? Colors.pink
                  : Colors.black,
            ),
          )),
        ),
        data: data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Linear Indicator')),
      body: Column(
        children: [
          Container(
            height: 35,
            child: CustomTabBar(
              defaultPage: 0,
              itemCount: pageCount,
              builder: getTabbarChild,
              tabIndicator: LinearIndicator(
                indicatorColor: Colors.pink,
                controller: _linearIndicatorController,
              ),
              pageController: _controller,
            ),
          ),
          Expanded(
              child: PageView.builder(
                  controller: _controller,
                  itemCount: pageCount,
                  itemBuilder: (context, index) {
                    return PageItem(index);
                  }))
        ],
      ),
    );
  }
}

```
![](https://raw.githubusercontent.com/lazyee/ImageHosting/master/img/round.gif)
```dart

class _RoundTabBarPageState extends State<RoundTabBarPage> {
  final int pageCount = 20;
  final PageController _controller = PageController();
  final RoundIndicatorController _roundIndicatorController =
      RoundIndicatorController();

  Widget getTabbarChild(BuildContext context, TabItemData data) {
    return RoundTabItem(
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
          alignment: Alignment.center,
          constraints: BoxConstraints(minWidth: 60),
          child: (Text(
            data.itemIndex == 5 ? 'Tab555555555555' : 'Tab${data.itemIndex}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          )),
        ),
        data: data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Round Indicator')),
      body: Column(
        children: [
          Container(
            height: 35,
            child: CustomTabBar(
              defaultPage: 0,
              itemCount: pageCount,
              builder: getTabbarChild,
              tabIndicator: RoundIndicator(
                indicatorColor: Colors.red,
                top: 2.5,
                bottom: 2.5,
                radius: 15,
                controller: _roundIndicatorController,
              ),
              pageController: _controller,
            ),
          ),
          Expanded(
              child: PageView.builder(
                  controller: _controller,
                  itemCount: pageCount,
                  itemBuilder: (context, index) {
                    return PageItem(index);
                  }))
        ],
      ),
    );
  }
}
```

