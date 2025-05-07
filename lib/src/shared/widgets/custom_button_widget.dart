import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  final Icon? icon;
  final Color? iconColor;
  final Color? shadowColor;
  final double? iconSize;
  final double? width;
  final double? height;
  final BorderSide? border;
  final Color? borderColor; // <-- New addition
  final double? elevation;
  final bool isEnabled;
  final LinearGradient? gradient;
  final bool? isLoading;

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
    this.icon,
    this.iconColor,
    this.shadowColor,
    this.iconSize = 24,
    this.width,
    this.height,
    this.border,
    this.borderColor, // <-- Added here
    this.elevation = 4.0,
    this.isEnabled = true,
    this.gradient,
    this.isLoading=false,
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
        color: widget.gradient == null ? widget.backgroundColor : null,
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
        boxShadow: [
          BoxShadow(
            color: widget.shadowColor ?? Colors.transparent,
            blurRadius: widget.elevation ?? 9.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: widget.isEnabled ? widget.onPressed : null,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          foregroundColor: widget.textColor ?? Colors.white,
          padding: widget.padding ?? EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
            side: widget.border ?? BorderSide(
              color: widget.borderColor ?? Colors.transparent, // <-- Now handled here
              width: 1,
            ),
          ),
          elevation: 0,
        ),
        child: Center(
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.svgIcon != null || widget.icon != null)
                Flexible(
                  child: Padding(
                    padding: widget.text != null
                        ? const EdgeInsets.only(right: 8.0)
                        : EdgeInsets.zero,
                    child: widget.svgIcon != null
                        ? SvgPicture.asset(
                      widget.svgIcon!,
                      width: widget.iconSize,
                      height: widget.iconSize,
                      colorFilter: widget.iconColor != null
                          ? ColorFilter.mode(widget.iconColor!, BlendMode.srcIn)
                          : null,
                    )
                        : IconTheme(
                      data: IconThemeData(
                        size: widget.iconSize,
                        color: widget.iconColor ?? widget.textColor,
                      ),
                      child: widget.icon!,
                    ),
                  ),
                ),
              if (widget.text != null)
                Flexible(
                  child:widget.isLoading == true
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : CustomTextWidget(
                    text: widget.text!,
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
