import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_text_form_field_widget.dart';
import '../../../shared/widgets/custom_button_widget.dart';
import '../../../theme/app_colors.dart';

class SymptomsInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final bool isLoading;

  const SymptomsInputWidget({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomTextFormFieldWidget(
              controller: controller,
              hintText: 'Enter your symptoms (e.g., fever, cough)',
              keyboardType: TextInputType.multiline,
              textStyle: TextStyle(
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size16,
                color: AppColors.subTextColor,
              ),
              onFieldSubmitted: (val){
                 FocusScope.of(context).unfocus();
              },
            ),
          ),
          const SizedBox(width: 8),
          CustomButtonWidget(
            backgroundColor: AppColors.gradientGreen,
            onPressed: isLoading ? null : onSubmit,
            justSelfDefinedChildNothingOther: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
} 