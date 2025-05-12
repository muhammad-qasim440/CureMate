import 'dart:io';
import 'package:curemate/core/extentions/date_time_format_extension.dart';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../const/app_strings.dart';
import '../../../shared/widgets/custom_appbar_header_widget.dart';
import '../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../shared/widgets/lower_background_effects_widgets.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/app_utils.dart';

class PatientDrawerFeedBackWidget extends ConsumerStatefulWidget {
  const PatientDrawerFeedBackWidget({super.key});

  @override
  ConsumerState<PatientDrawerFeedBackWidget> createState() => _PatientDrawerFeedBackWidgetState();
}

class _PatientDrawerFeedBackWidgetState extends ConsumerState<PatientDrawerFeedBackWidget> {
  List<bool> selectedOptions = List.generate(AppStrings.feedbackOptions.length, (index) => false);
  final _otherFeedbackController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.addListener(_scrollListener);
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    _otherFeedbackController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (selectedOptions.last && scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<String> _buildEmailBody() async {
    String body = 'Feedback:\n\n';
    for (int i = 0; i < AppStrings.feedbackOptions.length; i++) {
      if (selectedOptions[i]) {
        body += '- ${AppStrings.feedbackOptions[i]}\n';
      }
    }
    final deviceInfo = await deviceNameAndOSVersion();
    if (selectedOptions.last && _otherFeedbackController.text.isNotEmpty) {
      body += '\nAdditional feedback:\n${_otherFeedbackController.text}';
    }
    body += '\n\nDevice Info:\n$deviceInfo';
    return body;
  }

  Future<String> deviceNameAndOSVersion() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;
      var manufacturer = androidInfo.manufacturer;
      var model = androidInfo.model;
      return 'Android $release (SDK $sdkInt), \n $manufacturer $model';
    }
    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var systemName = iosInfo.systemName;
      var version = iosInfo.systemVersion;
      var name = iosInfo.name;
      var model = iosInfo.model;
      return '$systemName $version, \n $name $model';
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 15.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomAppBarHeaderWidget(title: 'Feed Back'),
                  34.height,
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: AppStrings.feedbackOptions.length,
                      itemBuilder: (context, index) {
                        return CheckboxListTile(
                          title: Text(
                            AppStrings.feedbackOptions[index],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          visualDensity: VisualDensity.compact,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          checkColor: AppColors.gradientWhite,
                          dense: true,
                          checkboxShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                          side: const BorderSide(
                            width: 0.5,
                            color: AppColors.gradientGreen,
                          ),
                          activeColor: AppColors.gradientGreen,
                          value: selectedOptions[index],
                          onChanged: (bool? value) {
                            setState(() {
                              selectedOptions[index] = value ?? false;
                              if (index == selectedOptions.length - 1) {
                                _scrollListener();
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),
                  if (selectedOptions[selectedOptions.length - 1])
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _otherFeedbackController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Please provide more details...',
                          contentPadding: const EdgeInsets.all(10),
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: AppColors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: AppColors.gradientGreen,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 5,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              AppColors.subTextColor,
                            ),
                          ),
                          onPressed: () {
                            selectedOptions = List.generate(
                              AppStrings.feedbackOptions.length,
                                  (index) => false,
                            );
                            _otherFeedbackController.clear();
                            setState(() {});
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        30.width,
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(AppColors.gradientGreen),
                          ),
                          onPressed: () async {
                            if (selectedOptions.every((element) => !element)) {
                              CustomSnackBarWidget.show(
                                context: context,
                                text: 'Please select at least one topic',
                              );
                              return;
                            }
                            var body = await _buildEmailBody();
                            AppUtils.openInEmail(
                              AppStrings.feedbackEmail,
                              'Device App ${AppStrings.appName} Feedback - ${DateTime.now().formattedDate}',
                              body,
                              context,
                            );
                          },
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              color: AppColors.gradientWhite,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}