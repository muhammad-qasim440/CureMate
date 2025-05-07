import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CustomTextFormFieldWidget extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;
  final TextDecoration? decorationStyle;
  final double? minHeight;
  final double? minWidth;
  final String? hintText;
  final String? initialValue;
  final bool obscureText;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final int minLines;
  final int? maxLength;
  final EdgeInsetsGeometry contentPadding;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final InputBorder? errorBorder;
   final FocusNode? focusNode;
   final TextAlign? textAlign;
   final bool? readOnly;
   final VoidCallback? onTap;
   final Color?fillColor;
  const CustomTextFormFieldWidget({
    super.key,
     this.controller,
    this.label,
    this.labelStyle,
    this.textStyle,
    this.decorationStyle,
    this.hintText,
    this.initialValue,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.border,
    this.focusedBorder,
    this.enabledBorder,
    this.errorBorder,
    this.focusNode,
    this.minHeight,
    this.minWidth,
    this.textAlign,
    this.readOnly,
    this.onTap,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly??false,
      onTap: onTap??(){},
      strutStyle: const StrutStyle(height: 0),
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      textAlign: textAlign??TextAlign.start,
      onChanged: onChanged,
      focusNode: focusNode,
      cursorColor: AppColors.gradientGreen,
      onFieldSubmitted: onFieldSubmitted,
      style: textStyle?.copyWith(
        decoration: decorationStyle,
      ),
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      initialValue: initialValue,
      decoration: InputDecoration(
         fillColor: fillColor,
        labelText: label,
        labelStyle: labelStyle,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding,
        border: border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
        focusedBorder: focusedBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
        enabledBorder: enabledBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
        errorBorder: errorBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
      ),
    );
  }
}
