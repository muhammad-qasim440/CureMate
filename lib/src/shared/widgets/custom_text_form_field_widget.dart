import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';

class CustomTextFormFieldWidget extends ConsumerStatefulWidget {
  final StateProvider<String>? provider; // Changed to StateProvider<String>
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
  final Color? fillColor;

  const CustomTextFormFieldWidget({
    super.key,
    this.provider,
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
  ConsumerState<CustomTextFormFieldWidget> createState() =>
      _CustomTextFormFieldWidgetState();
}

class _CustomTextFormFieldWidgetState extends ConsumerState<CustomTextFormFieldWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sync with provider if provided
    if (widget.provider != null) {
      final value = ref.watch(widget.provider!);
      if (_controller.text != value) {
        _controller.text = value;
        debugPrint('Updated ${widget.label} controller: $value');
      }
    }

    return TextFormField(
      controller: _controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly ?? false,
      onTap: widget.onTap ?? () {},
      strutStyle: const StrutStyle(height: 0),
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      textAlign: widget.textAlign ?? TextAlign.start,
      onChanged: (value) {
        if (widget.provider != null) {
          ref.read(widget.provider!.notifier).state = value;
        }
        widget.onChanged?.call(value);
        debugPrint('User updated ${widget.label}: $value');
      },
      cursorColor: AppColors.gradientGreen,
      onFieldSubmitted: widget.onFieldSubmitted,
      style: widget.textStyle?.copyWith(
        decoration: widget.decorationStyle,
      ),
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      decoration: InputDecoration(
        fillColor: widget.fillColor,
        filled: widget.fillColor != null,
        labelText: widget.label,
        labelStyle: widget.labelStyle,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        contentPadding: widget.contentPadding,
        border: widget.border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
        focusedBorder: widget.focusedBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
        enabledBorder: widget.enabledBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
        errorBorder: widget.errorBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
      ),
    );
  }
}