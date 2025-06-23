import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../../const/app_fonts.dart';
import '../../../const/font_sizes.dart';
import '../../theme/app_colors.dart';
import '../providers/drop_down_provider/custom_drop_down_provider.dart';

class CustomDropdown extends ConsumerStatefulWidget {
  final List<String> items;
  final String label;
  final String? initialValue; // Added back for compatibility
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
  ConsumerState<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends ConsumerState<CustomDropdown> {
  bool _hasSetInitialValue = false;

  @override
  Widget build(BuildContext context) {
    final provider = customDropDownProvider(widget.items);
    final state = ref.watch(provider);

    // Set initialValue to provider on first build if provider's state is empty
    if (!_hasSetInitialValue &&
        widget.initialValue != null &&
        widget.initialValue!.isNotEmpty &&
        state.selected.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(provider.notifier).setSelected(widget.initialValue!);
        debugPrint('Set initial dropdown value: ${widget.initialValue}');
      });
      _hasSetInitialValue = true;
    }

    final radius = widget.borderRadius ?? 12;

    return DropdownButtonFormField2<String>(
      isExpanded: true,
      value: state.selected.isNotEmpty ? state.selected : null,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: widget.labelStyle ??
            TextStyle(
              fontFamily: AppFonts.rubik,
              fontWeight: FontWeight.w400,
              fontSize: FontSizes(context).size14,
              color: AppColors.subTextColor,
            ),
        contentPadding: EdgeInsets.zero,
        filled: true,
        fillColor: widget.backgroundColor ?? Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: widget.borderColor ?? Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: widget.focusedBorderColor ?? Colors.grey),
        ),
      ),
      hint: const Icon(Icons.keyboard_arrow_down_rounded),
      dropdownStyleData: DropdownStyleData(
        maxHeight: widget.dropdownMaxHeight ?? 250,
        scrollbarTheme: widget.scrollbarThemeData ??
            ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(AppColors.gradientGreen),
              trackColor: MaterialStateProperty.all(AppColors.subTextColor),
              thickness: MaterialStateProperty.all(4),
              radius: const Radius.circular(8),
            ),
        decoration: widget.dropdownDecoration ??
            BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: widget.backgroundColor ?? Colors.white,
            ),
        elevation: 4,
        offset: const Offset(0, -4),
      ),
      items: widget.items
          .map(
            (item) => DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            overflow: TextOverflow.ellipsis,
            style: widget.itemTextStyle ??
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
          widget.onChanged?.call(value);
          debugPrint('Selected dropdown value: $value');
        }
      },
      validator: (value) {
        if ((value == null || value.isEmpty) && widget.validatorText != null) {
          return widget.validatorText;
        }
        return null;
      },
    );
  }
}