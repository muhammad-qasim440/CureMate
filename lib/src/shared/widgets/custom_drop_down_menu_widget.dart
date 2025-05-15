import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../../../const/app_fonts.dart';
import '../../../const/font_sizes.dart';
import '../../theme/app_colors.dart';
import '../providers/drop_down_provider/custom_drop_down_provider.dart';

class CustomDropdown extends ConsumerWidget {
  final List<String> items;
  final String label;
  final String? initialValue;
  final String? validatorText;
  final void Function(String)? onChanged;

  final TextStyle? labelStyle;
  final TextStyle? itemTextStyle;
  final BoxDecoration? dropdownDecoration;
  final double? borderRadius;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? dropdownMaxHeight;
  final ScrollbarThemeData? scrollbarThemeData;
  final Color? backgroundColor;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.label,
    this.initialValue,
    this.validatorText,
    this.onChanged,
    this.labelStyle,
    this.itemTextStyle,
    this.dropdownDecoration,
    this.borderRadius,
    this.borderColor,
    this.focusedBorderColor,
    this.dropdownMaxHeight,
    this.scrollbarThemeData,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = customDropDownProvider(items);
    final state = ref.watch(provider);
    final radius = borderRadius ?? 12;

    return DropdownButtonFormField2<String>(
      isExpanded: true,
      value: initialValue != null && items.contains(initialValue) ? initialValue :  state.selected,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: labelStyle ??
            TextStyle(
              fontFamily: AppFonts.rubik,
              fontWeight: FontWeight.w400,
              fontSize: FontSizes(context).size14,
              color: AppColors.subTextColor,
            ),
        contentPadding: EdgeInsets.zero,
        filled: true,
        fillColor: backgroundColor ?? Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: borderColor ?? Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: focusedBorderColor ?? Colors.grey),
        ),
      ),
      hint: const Icon(Icons.keyboard_arrow_down_rounded),
      dropdownStyleData: DropdownStyleData(
        maxHeight: dropdownMaxHeight ?? 250,
        scrollbarTheme: scrollbarThemeData ??
            ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(AppColors.gradientGreen),
              trackColor: MaterialStateProperty.all(AppColors.subTextColor),
              thickness: MaterialStateProperty.all(4),
              radius: const Radius.circular(8),
            ),
        decoration: dropdownDecoration ??
            BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: backgroundColor ?? Colors.white, // 👈 NEW for dropdown popup
            ),
        elevation: 4,
        offset: const Offset(0, -4),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            overflow: TextOverflow.ellipsis,
            style: itemTextStyle ??
                const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  fontFamily: AppFonts.rubik,
                  color: AppColors.subTextColor,
                ),
          ),
        ),
      )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          ref.read(provider.notifier).setSelected(value);
          onChanged?.call(value);
        }
      },
      validator: (value) {
        if ((value == null || value.isEmpty) && validatorText != null) {
          return validatorText;
        }
        return null;
      },
    );
  }
}

