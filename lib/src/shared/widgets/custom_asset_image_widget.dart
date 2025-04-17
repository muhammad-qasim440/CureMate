import 'package:flutter/material.dart';

class CustomAssetImageWidget extends StatelessWidget {
  final String img;
  final double? width;
  final double? height;

  const CustomAssetImageWidget({
    super.key,
    required this.img,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      img,
      width: width ?? 24.0,
      height: height ?? 24.0,
    );
  }
}
