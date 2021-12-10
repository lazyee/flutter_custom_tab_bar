import 'package:flutter/material.dart';

import '../models.dart';
import 'tab_bar_transform.dart';

class ColorsTransform extends TabBarTransform {
  Color highlightColor;
  Color normalColor;
  Color? transformColor;

  ColorsTransform({
    TabBarTransform? transform,
    TransformBuilder? builder,
    required this.highlightColor,
    required this.normalColor,
  }) : super(transform: transform, builder: builder);

  @override
  Widget build(BuildContext context, int index, ScrollProgressInfo info) {
    calculate(index, info);
    if (builder != null) {
      return builder!(context, transformColor);
    }
    return transform!.build(context, index, info);
  }

  @override
  void calculate(int index, ScrollProgressInfo info) {
    double changeValue = info.progress;
    int alphaValueOffset = highlightColor.alpha - normalColor.alpha;
    int blueValueOffset = highlightColor.blue - normalColor.blue;
    int greenValueOffset = highlightColor.green - normalColor.green;
    int redValueOffset = highlightColor.red - normalColor.red;

    if (info.currentIndex == index) {
      transformColor = highlightColor
          .withAlpha(
              highlightColor.alpha - (alphaValueOffset * changeValue).toInt())
          .withBlue(
              highlightColor.blue - (blueValueOffset * changeValue).toInt())
          .withGreen(
              highlightColor.green - (greenValueOffset * changeValue).toInt())
          .withRed(highlightColor.red - (redValueOffset * changeValue).toInt());
    } else if (info.targetIndex == index) {
      transformColor = normalColor
          .withAlpha(
              normalColor.alpha + (alphaValueOffset * changeValue).toInt())
          .withBlue(normalColor.blue + (blueValueOffset * changeValue).toInt())
          .withGreen(
              normalColor.green + (greenValueOffset * changeValue).toInt())
          .withRed(normalColor.red + (redValueOffset * changeValue).toInt());
    } else {
      transformColor = normalColor;
      return;
    }
  }
}
