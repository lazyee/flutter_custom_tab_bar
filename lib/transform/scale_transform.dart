import 'package:flutter/material.dart';

import '../models.dart';
import 'tab_bar_transform.dart';

class ScaleTransform extends TabBarTransform {
  double maxScale;
  ScaleTransform({
    TabBarTransform? transform,
    TransformBuilder? builder,
    this.maxScale = 1.2,
  })  : assert(maxScale >= 1),
        super(transform: transform, builder: builder);

  double scale = 0;

  @override
  void calculate(int index, ScrollProgressInfo info) {
    if (info.currentIndex == index) {
      scale = 1.0 - info.progress;

      return;
    }
    if (info.targetIndex == index) {
      scale = info.progress;
      return;
    }
    scale = 0;
  }

  @override
  Widget build(BuildContext context, int index, ScrollProgressInfo info) {
    calculate(index, info);

    return Transform.scale(
      scale: 1 + ((maxScale - 1) * scale),
      child: builder == null
          ? transform!.build(context, index, info)
          : builder!(context, scale),
    );
  }
}
