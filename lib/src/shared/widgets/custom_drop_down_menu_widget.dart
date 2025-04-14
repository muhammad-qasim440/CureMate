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
  final String? validatorText;
  final void Function(String)? onChanged;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.label,
    this.validatorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = customDropDownProvider(items);
    final state = ref.watch(provider);

    return DropdownButtonFormField2<String>(
      isExpanded: true,
      value: state.selected,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: AppFonts.rubik,
          fontWeight: FontWeight.w400,
          fontSize: FontSizes(context).size14,
          color: AppColors.subtextcolor,
        ),
        contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:  BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey,),
        ),
      ),
      hint: const Icon(Icons.keyboard_arrow_down_rounded),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 150,
        width: null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        offset: const Offset(0, -4),
      ),
      items:
          items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      fontFamily: AppFonts.rubik,
                      color: AppColors.subtextcolor,
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
