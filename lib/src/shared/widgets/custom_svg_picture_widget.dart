import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSvgPictureWidget extends StatelessWidget {
  final String icon;
  final double? width;
  final double? height;

  const CustomSvgPictureWidget({
    super.key,
    required this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon,
      width: width ?? 24.0,
      height: height ?? 24.0,
    );
  }
}
