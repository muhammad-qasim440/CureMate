import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'custom_text_widget.dart';

class CustomButtonWidget extends StatefulWidget {
  final String? text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final String? svgIcon;
  final Color? iconColor;
  final Color? shadowColor;
  final double? iconSize;
  final double? width;
  final double? height;
  final BorderSide? border;
  final double? elevation;
  final bool isEnabled;
  final LinearGradient? gradient;

  const CustomButtonWidget({
    super.key,
    this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontFamily,
    this.fontWeight,
    this.padding,
    this.borderRadius,
    this.svgIcon,
    this.iconColor,
    this.shadowColor,
    this.iconSize = 24,
    this.width,
    this.height,
    this.border,
    this.elevation = 4.0,
    this.isEnabled = true,
    this.gradient,
  });

  @override
  _CustomButtonWidgetState createState() => _CustomButtonWidgetState();
}
class _CustomButtonWidgetState extends State<CustomButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.gradient == null ? widget.backgroundColor : null, // Apply background color if no gradient
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
        boxShadow: [
          BoxShadow(
            color: widget.shadowColor ?? Colors.black.withOpacity(0.3),
            blurRadius: widget.elevation ?? 9.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: widget.isEnabled ? widget.onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Keep transparent since Container handles color/gradient
          foregroundColor: widget.textColor ?? Colors.white,
          padding: widget.padding ?? EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
            side: widget.border ?? BorderSide.none,
          ),
          elevation: 0,
        ),
        child: Center(
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.svgIcon != null)
                Flexible(
                  child: Padding(
                    padding: widget.text != null
                        ? const EdgeInsets.only(right: 8.0)
                        : EdgeInsets.zero,
                    child: SvgPicture.asset(
                      widget.svgIcon!,
                      width: widget.iconSize,
                      height: widget.iconSize,
                      colorFilter: widget.iconColor != null
                          ? ColorFilter.mode(widget.iconColor!, BlendMode.srcIn)
                          : null,
                    ),
                  ),
                ),
              if (widget.text != null)
                Flexible(
                  child: CustomTextWidget(
                    text: widget.text!,
                    applyShadow: true,
                    strokeColors: const [Colors.black],
                    borderColor: Colors.black,
                    textStyle: TextStyle(
                      fontSize: widget.fontSize ?? 16,
                      fontWeight: widget.fontWeight ?? FontWeight.w500,
                      fontFamily: widget.fontFamily,
                      color: widget.textColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
