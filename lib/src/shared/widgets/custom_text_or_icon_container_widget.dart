import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'custom_text_widget.dart';

class CustomTextORIconContainerWidget extends StatelessWidget {
  final String? text;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final String? icon;
  final FontWeight? fontWeight;
  final double? fontSize;
  final String? fontFamily;

  const CustomTextORIconContainerWidget({
    super.key,
    this.text,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.fontFamily,
    this.fontWeight,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) SvgPicture.asset(icon!),
            if (icon != null && text != null) const SizedBox(width: 8),
            if (text != null)
              CustomTextWidget(
                text: text!,
                textStyle: TextStyle(
                  color: textColor,
                  fontFamily: fontFamily,
                  fontWeight: fontWeight,
                  fontSize: fontSize,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
