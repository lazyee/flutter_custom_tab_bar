import 'package:flutter/material.dart';

import '../tab_bar_item_info.dart';
import 'transform_delegate.dart';

class ColorTransformDelegate extends TransfromDelegate {
  Color highlightColor;
  Color normalColor;
  ColorTransformDelegate({
    TransfromDelegate? delegate,
    TransformBuilder? builder,
    required this.highlightColor,
    required this.normalColor,
  }) : super(delegate: delegate, builder: builder);

  @override
  Widget build(BuildContext context, TabBarItemInfo tabbarItemInfo) {
    calculate(tabbarItemInfo);
    if (builder != null) {
      return builder!(context, transformColor);
    }
    return delegate!.build(context, tabbarItemInfo);
  }

  Color? transformColor;
  @override
  void calculate(TabBarItemInfo tabbarItemInfo) {
    if (tabbarItemInfo.isJumpPage!) {
      transformColor = tabbarItemInfo.jumpPageIndex == tabbarItemInfo.itemIndex
          ? highlightColor
          : normalColor;
      return;
    }

    double changeValue = tabbarItemInfo.page! % 1;
    int alphaValueOffset = highlightColor.alpha - normalColor.alpha;
    int blueValueOffset = highlightColor.blue - normalColor.blue;
    int greenValueOffset = highlightColor.green - normalColor.green;
    int redValueOffset = highlightColor.red - normalColor.red;

    if (tabbarItemInfo.itemIndex == tabbarItemInfo.currentIndex) {
      if (changeValue == 0) {
        transformColor = highlightColor;
        return;
      }
      if (tabbarItemInfo.page! < tabbarItemInfo.currentIndex!) {
        transformColor = normalColor
            .withAlpha(
                normalColor.alpha + (alphaValueOffset * changeValue).toInt())
            .withBlue(
                normalColor.blue + (blueValueOffset * changeValue).toInt())
            .withGreen(
                normalColor.green + (greenValueOffset * changeValue).toInt())
            .withRed(normalColor.red + (redValueOffset * changeValue).toInt());
      } else {
        transformColor = highlightColor
            .withAlpha(
                highlightColor.alpha - (alphaValueOffset * changeValue).toInt())
            .withBlue(
                highlightColor.blue - (blueValueOffset * changeValue).toInt())
            .withGreen(
                highlightColor.green - (greenValueOffset * changeValue).toInt())
            .withRed(
                highlightColor.red - (redValueOffset * changeValue).toInt());
      }
    } else {
      if ((tabbarItemInfo.itemIndex! - tabbarItemInfo.page!).abs() >= 1) {
        transformColor = normalColor;
        return;
      }

      if (tabbarItemInfo.itemIndex! > tabbarItemInfo.page!) {
        transformColor = normalColor
            .withAlpha(
                normalColor.alpha + (alphaValueOffset * changeValue).toInt())
            .withBlue(
                normalColor.blue + (blueValueOffset * changeValue).toInt())
            .withGreen(
                normalColor.green + (greenValueOffset * changeValue).toInt())
            .withRed(normalColor.red + (redValueOffset * changeValue).toInt());
      } else {
        transformColor = normalColor
            .withAlpha(normalColor.alpha +
                (alphaValueOffset * (1 - changeValue)).toInt())
            .withBlue(normalColor.blue +
                (blueValueOffset * (1 - changeValue)).toInt())
            .withGreen(normalColor.green +
                (greenValueOffset * (1 - changeValue)).toInt())
            .withRed(
                normalColor.red + (redValueOffset * (1 - changeValue)).toInt());
      }
    }
  }
}
