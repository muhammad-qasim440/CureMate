
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../shared/widgets/custom_snackbar_widget.dart';

abstract class AppUtils {
  static final _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  static FormFieldValidator<String>? email({
    String message = 'This is not a valid email address.',
  }) {
    return (String? value) {
      if (value?.isEmpty ?? true) return 'Email is required.';
      if (_emailRegExp.hasMatch(value ?? '')) return null;
      return 'Please provide a valid email.';
    };
  }

  static Future<void> openInEmail(String email, String subject,
      String emailBody, BuildContext context) async {
    final params = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=$subject&body=$emailBody',
    );

    try {
      await launchUrlString(
        params.toString(),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      // FirebaseCrashlytics.instance
      //     .recordError(e, StackTrace.current, reason: 'Error in sending e-mail ');
      if(context.mounted) {
        CustomSnackBarWidget.show(
          context: context,
          text: 'Unable to send email. Please try again later.',
        );
      }
      rethrow;

    }

    await launchUrlString(
      params.toString(),
      mode: LaunchMode.externalApplication,
    );
  }

  static Future<void> openPhone(String phone) async {
    final params = Uri(scheme: 'tel', path: phone);
    await launchUrlString(
      params.toString(),
      mode: LaunchMode.externalApplication,
    );
  }

  static Future<void> openLink(String url) async {
    if (!await launchUrl(Uri.parse(formatUrl(url)))) {

      throw Exception('Cannot access this link');
    }
  }

  static String formatUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    return url;
  }




// static Future<void> openLink(String url) async {
//   try {
//     if (await canLaunchUrlString(url)) {
//       await launchUrlString(
//         url,
//         // mode: LaunchMode.externalApplication,
//       );
//     } else {
//       $showErrorSnackBar('Cannot access this link');
//     }
//   } catch (_) {
//     $showErrorSnackBar('Cannot access this link');
//   }
// }
}
