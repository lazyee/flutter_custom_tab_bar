import 'package:flutter/material.dart';

class PageItem extends StatefulWidget {
  final int index;
  PageItem(this.index, {Key? key}) : super(key: key);

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
