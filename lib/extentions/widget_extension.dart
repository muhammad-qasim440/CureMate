import 'package:flutter/material.dart';

extension SizedBoxHelper on num {
  Widget get height {
    return SizedBox(height: toDouble());
  }

  Widget get width {
    return SizedBox(width: toDouble());
  }

  Widget get sliverHeight {
    return height.wrapWithSliver;
  }

  Widget get sliverWidth {
    return width.wrapWithSliver;
  }
}

extension SliverExtension on Widget {
  Widget get wrapWithSliver {
    return SliverToBoxAdapter(child: this);
  }
}
