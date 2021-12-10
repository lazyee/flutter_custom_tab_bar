import 'package:example/pinned_linear_tab_bar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'linear_tab_bar_page.dart';
import 'round_tab_bar_page.dart';
import 'standard_tab_bar_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _buildItem(BuildContext context, String title, Widget widget) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => widget));
      },
      child: Container(
        padding: EdgeInsets.all(10),
        child: Text(title),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title!),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildItem(context, "Standard Tab Bar", StandardTabBarPage()),
          _buildItem(context, "Linear Tab Bar", LinearTabBarPage()),
          _buildItem(
              context, "Pinned Linear Tab Bar", PinnedLinearTabBarPage()),
          _buildItem(context, "Round Tab Bar", RoundTabBarPage()),
        ]));
  }
}
