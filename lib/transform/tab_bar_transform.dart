import 'package:flutter/material.dart';
import 'package:flutter_custom_tab_bar/library.dart';

typedef TransformBuilder = Widget Function(
    BuildContext context, dynamic transform);

abstract class TabBarTransform {
  TabBarTransform? transform;
  TransformBuilder? builder;
  TabBarTransform({
    this.transform,
    this.builder,
  });

  void calculate(int index, ScrollProgressInfo info);

  Widget build(BuildContext context, int index, ScrollProgressInfo info);
}
