import 'dart:async';
import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/shared/widgets/custom_button_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_form_field_widget.dart';
import 'package:curemate/src/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../const/app_strings.dart';
import '../../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../utils/app_utils.dart';
import '../../signin/providers/auth_provider.dart';
import '../providers/password_reset_providers.dart';
final inSheetNotificationProvider = StateProvider.autoDispose<String?>((ref) => null);

class ForgetPasswordBottomSheet extends ConsumerStatefulWidget {
  final FocusNode emailFocus;

  const ForgetPasswordBottomSheet({super.key, required this.emailFocus});

  @override
  ConsumerState<ForgetPasswordBottomSheet> createState() => _ForgetPasswordBottomSheetState();
  static void show(BuildContext context, FocusNode emailFocus) {
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => ForgetPasswordBottomSheet(emailFocus: emailFocus),
    );
  }

}

class _ForgetPasswordBottomSheetState extends ConsumerState<ForgetPasswordBottomSheet> {
  Timer? _notificationTimer;

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  void _showNotification(String message) {
    _notificationTimer?.cancel();
    ref.read(inSheetNotificationProvider.notifier).state = message;
    _notificationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        ref.read(inSheetNotificationProvider.notifier).state = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(forgotPasswordEmailProvider);
    final isEmailSent = ref.watch(isEmailSentProvider);
    final notification = ref.watch(inSheetNotificationProvider);

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const CustomTextWidget(
              text: 'Forgot Password',
              textStyle: TextStyle(
                fontFamily: AppFonts.rubik,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            10.height,

            const CustomTextWidget(
              text:
              'Enter your email for the verification process, we will send a password reset link to your email.',
              softWrap: true,
              textAlignment: TextAlign.center,
              textStyle: TextStyle(
                fontFamily: AppFonts.rubik,
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: AppColors.subTextColor,
              ),
            ),
            20.height,
            CustomTextFormFieldWidget(
              label: 'Email',
              hintText: 'Enter your email',
              focusNode: widget.emailFocus,
              onChanged: (value) => ref.read(forgotPasswordEmailProvider.notifier).state = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                const pattern =
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

                final regex = RegExp(pattern);
                if (!regex.hasMatch(value)) {
                  return AppStrings.enterValidEmail;
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
              textStyle: TextStyle(
                fontFamily: AppFonts.rubik,
                fontWeight: FontWeight.w400,
                fontSize: FontSizes(context).size14,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: AppColors.grey),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: AppColors.grey),
              ),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                fontFamily: AppFonts.rubik,
                color: AppColors.subTextColor,
              ),
            ),
            30.height,

            Row(
              children: [
                Expanded(
                  child: CustomButtonWidget(
                    text: 'Send',
                    height: 54,
                    backgroundColor: isEmailSent
                        ? AppColors.grey.withOpacity(0.4)
                        : AppColors.gradientGreen,
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size18,
                    fontWeight: FontWeight.w900,
                    textColor: AppColors.gradientWhite,
                    onPressed: isEmailSent
                        ? null
                        : () async {
                      FocusScope.of(context).unfocus();
                      final trimmedEmail = email.trim();
                      if (trimmedEmail.isEmpty) {
                        _showNotification('Please enter your email address');
                        return;
                      }
                      final isConnected = await ref.read(checkInternetConnectionProvider.future);
                      if (!isConnected) {
                        if (!context.mounted) return;
                        _showNotification('Please check your internet connection and try again');
                        return;
                      }
                      if (!context.mounted) return;
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const AlertDialog(
                            content: Row(
                              children: [
                                CircularProgressIndicator(color: AppColors.gradientGreen,),
                                SizedBox(width: 20),
                                Text('Sending reset link...'),
                              ],
                            ),
                          );
                        },
                      );
                      final result = await ref.read(authProvider).resetPassword();
                      if (!context.mounted) return;
                      Navigator.pop(context); // Close loading dialog
                      _showNotification(result['message']);
                      if (result['success']) {
                        ref.read(isEmailSentProvider.notifier).state = true;
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButtonWidget(
                    text: 'Open Email',
                    height: 54,
                    backgroundColor: isEmailSent
                        ? AppColors.gradientGreen
                        : AppColors.grey.withOpacity(0.4),
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size18,
                    fontWeight: FontWeight.w900,
                    textColor: AppColors.gradientWhite,
                    onPressed: isEmailSent
                        ? () async {
                      FocusScope.of(context).unfocus();
                      final isConnected = await ref.read(checkInternetConnectionProvider.future);
                      if (!isConnected) {
                        if (!context.mounted) return;
                        _showNotification('Please check your internet connection to access your email');
                        return;
                      }
                      try {
                        await AppUtils.openLink(
                          'https://mail.google.com',
                        );
                        if (!context.mounted) return;
                        _showNotification('Please check your inbox for the password reset link');
                      } catch (_) {
                        if (!context.mounted) return;
                        _showNotification('Unable to open email client. Please check your inbox manually.');
                      }
                    }
                        : null,
                  ),
                ),
              ],
            ),
            if (notification != null) ...[
              16.height,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.gradientGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomTextWidget(
                  text: notification,
                  textAlignment: TextAlign.center,
                  textStyle: const TextStyle(
                    fontFamily: AppFonts.rubik,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              16.height,
            ],
          ],
        ),
      ),
    );
  }

}









//
// import 'package:curemate/const/app_fonts.dart';
// import 'package:curemate/const/font_sizes.dart';
// import 'package:curemate/extentions/widget_extension.dart';
// import 'package:curemate/src/shared/widgets/custom_button_widget.dart';
// import 'package:curemate/src/shared/widgets/custom_snackbar_widget.dart';
// import 'package:curemate/src/shared/widgets/custom_text_form_field_widget.dart';
// import 'package:curemate/src/theme/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../shared/providers/check_internet_connectivity_provider.dart';
// import '../../../shared/widgets/custom_text_widget.dart';
// import '../../../utils/app_utils.dart';
// import '../../signin/providers/auth_provider.dart';
// import '../providers/password_reset_providers.dart';
//
// class ForgetPasswordBottomSheet extends ConsumerWidget {
//   final FocusNode emailFocus;
//
//   const ForgetPasswordBottomSheet({super.key, required this.emailFocus});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final email = ref.watch(forgotPasswordEmailProvider);
//     final isEmailSent = ref.watch(isEmailSentProvider);
//
//     return Padding(
//       padding: MediaQuery.of(context).viewInsets,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Title
//             const CustomTextWidget(
//               text: 'Forgot Password',
//               textStyle: TextStyle(
//                 fontFamily: AppFonts.rubik,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 18,
//                 color: Colors.black,
//               ),
//             ),
//             10.height,
//
//             // Description
//             const CustomTextWidget(
//               text:
//               'Enter your email for the verification process, we will send a password reset link to your email.',
//               softWrap: true,
//               textAlignment: TextAlign.center,
//               textStyle: TextStyle(
//                 fontFamily: AppFonts.rubik,
//                 fontWeight: FontWeight.w400,
//                 fontSize: 14,
//                 color: AppColors.subtextcolor,
//               ),
//             ),
//             20.height,
//
//             // Email field
//             CustomTextFormFieldWidget(
//               label: 'Email',
//               hintText: 'Enter your email',
//               focusNode: emailFocus,
//               onChanged:
//                   (value) =>
//               ref.read(forgotPasswordEmailProvider.notifier).state =
//                   value,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your email';
//                 }
//                 return null;
//               },
//               keyboardType: TextInputType.emailAddress,
//               textStyle: TextStyle(
//                 fontFamily: AppFonts.rubik,
//                 fontWeight: FontWeight.w400,
//                 fontSize: FontSizes(context).size14,
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(30),
//                 borderSide: const BorderSide(color: AppColors.grey),
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(30),
//                 borderSide: const BorderSide(color: AppColors.grey),
//               ),
//               labelStyle: const TextStyle(
//                 fontWeight: FontWeight.w400,
//                 fontSize: 14,
//                 fontFamily: AppFonts.rubik,
//                 color: AppColors.subtextcolor,
//               ),
//             ),
//             30.height,
//
//             Row(
//               children: [
//                 Expanded(
//                   child: CustomButtonWidget(
//                     text: 'Send',
//                     height: 54,
//                     backgroundColor:
//                     isEmailSent
//                         ? AppColors.grey.withOpacity(0.4)
//                         : AppColors.gradientGreen,
//                     fontFamily: AppFonts.rubik,
//                     fontSize: FontSizes(context).size18,
//                     fontWeight: FontWeight.w900,
//                     textColor: AppColors.gradientWhite,
//                     onPressed:
//                     isEmailSent
//                         ? null
//                         : () async {
//                       FocusScope.of(context).unfocus();
//                       final trimmedEmail = email.trim();
//
//                       // Validate email
//                       if (trimmedEmail.isEmpty) {
//                         CustomSnackBarWidget.show(
//                           context: context,
//                           text: 'Please enter your email address',
//                         );
//                         return;
//                       }
//
//                       // Check for internet connectivity using your provider
//                       final isConnected = await ref.read(checkInternetConnectionProvider.future);
//                       if (!isConnected) {
//                         if (!context.mounted) return;
//                         CustomSnackBarWidget.show(
//                           context: context,
//                           text: 'Please check your internet connection and try again',
//                         );
//                         return;
//                       }
//
//                       // Show loading indicator
//                       if (!context.mounted) return;
//                       showDialog(
//                         context: context,
//                         barrierDismissible: false,
//                         builder: (BuildContext context) {
//                           return const AlertDialog(
//                             content: Row(
//                               children: [
//                                 CircularProgressIndicator(color: AppColors.gradientGreen,),
//                                 SizedBox(width: 20),
//                                 Text('Sending reset link...'),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//
//                       // Send password reset request
//                       final result = await ref.read(authProvider).resetPassword();
//
//                       // Hide loading indicator
//                       if (!context.mounted) return;
//                       Navigator.pop(context); // Close loading dialog
//
//                       // Show result message
//                       CustomSnackBarWidget.show(
//                         context: context,
//                         text: result['message'],
//                         backgroundColor: result['success']
//                             ? AppColors.gradientGreen
//                             : Colors.red,
//                       );
//
//                       // Update state if successful
//                       if (result['success']) {
//                         ref.read(isEmailSentProvider.notifier).state = true;
//                       }
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//
//                 // Open Gmail Button
//                 Expanded(
//                   child: CustomButtonWidget(
//                     text: 'Open Email',
//                     height: 54,
//                     backgroundColor:
//                     isEmailSent
//                         ? AppColors.gradientGreen
//                         : AppColors.grey.withOpacity(0.4),
//                     fontFamily: AppFonts.rubik,
//                     fontSize: FontSizes(context).size18,
//                     fontWeight: FontWeight.w900,
//                     textColor: AppColors.gradientWhite,
//                     onPressed:
//                     isEmailSent
//                         ? () async {
//                       FocusScope.of(context).unfocus();
//                       final isConnected = await ref.read(checkInternetConnectionProvider.future);
//                       if (!isConnected) {
//                         if (!context.mounted) return;
//                         CustomSnackBarWidget.show(
//                           context: context,
//                           text: 'Please check your internet connection to access your email',
//                         );
//                         return;
//                       }
//
//                       try {
//                         await AppUtils.openLink(
//                           'https://mail.google.com',
//                         );
//
//                         if (!context.mounted) return;
//                         CustomSnackBarWidget.show(
//                           context: context,
//                           text: 'Please check your inbox for the password reset link',
//                         );
//                       } catch (_) {
//                         if (!context.mounted) return;
//                         CustomSnackBarWidget.show(
//                           context: context,
//                           text: 'Unable to open email client. Please check your inbox manually.',
//                         );
//                       }
//                     }
//                         : null,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   static void show(BuildContext context, FocusNode emailFocus) {
//     showModalBottomSheet(
//       isScrollControlled: true,
//       enableDrag: true,
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       builder: (context) => ForgetPasswordBottomSheet(emailFocus: emailFocus),
//     );
//   }
// }