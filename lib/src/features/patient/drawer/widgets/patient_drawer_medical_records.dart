import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/core/utils/debug_print.dart';
import 'package:curemate/src/features/patient/drawer/helpers/drawer_helpers.dart';
import 'package:curemate/src/features/patient/drawer/widgets/patient_drawer_medical_record_details_view.dart';
import 'package:curemate/src/features/patient/drawer/widgets/patient_drawer_pop_up_menu_button_widget.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/shared/widgets/custom_appbar_header_widget.dart';
import 'package:curemate/src/shared/widgets/custom_button_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../assets/app_icons.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../theme/app_colors.dart';
import '../providers/drawer_providers.dart';
import 'patient_drawer_add_patient_record_view.dart';

class PatientDrawerMedicalRecordsView extends ConsumerStatefulWidget {
  const PatientDrawerMedicalRecordsView({super.key});

  @override
  ConsumerState<PatientDrawerMedicalRecordsView> createState() =>
      _PatientDrawerMedicalRecordsViewState();
}

class _PatientDrawerMedicalRecordsViewState
    extends ConsumerState<PatientDrawerMedicalRecordsView> {
  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(medicalRecordsProvider);
    final drawerHelpers = DrawerHelpers();
    final isRecordsNotEmpty = recordsAsync.when(
      data: (records) => records.isNotEmpty,
      loading: () => false,
      error: (_, __) => false,
    );

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
                  const CustomAppBarHeaderWidget(title: 'All Records'),
                  34.height,
                  Expanded(
                    child: recordsAsync.when(
                      data:
                          (records) =>
                              records.isEmpty
                                  ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SvgPicture.asset(AppIcons.recordIc),
                                        20.height,
                                        const CustomTextWidget(
                                          text: 'Add a medical record.',
                                          textStyle: TextStyle(
                                            fontSize: 22,
                                            fontFamily: AppFonts.rubik,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        10.height,
                                        CustomTextWidget(
                                          text:
                                              'A detailed health history helps a doctor diagnose you better.',
                                          textStyle: TextStyle(
                                            color: AppColors.subTextColor,
                                            fontSize: FontSizes(context).size14,
                                            fontFamily: AppFonts.rubik,
                                          ),
                                          textAlignment: TextAlign.center,
                                        ),
                                        20.height,
                                        CustomButtonWidget(
                                          width: ScreenUtil.scaleWidth(
                                            context,
                                            270,
                                          ),
                                          height: ScreenUtil.scaleHeight(
                                            context,
                                            54,
                                          ),
                                          text: 'Add a record',
                                          onPressed: () {
                                            drawerHelpers
                                                .showImagePickerBottomSheet(
                                                  ref: ref,
                                                 context:  context,
                                                 multiImageProvider:  selectedImagesProvider,
                                                );
                                            AppNavigation.pop(context);
                                            AppNavigation.push(
                                              const PatientDrawerAddPatientRecordView(),
                                            );
                                          },
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white,
                                          borderRadius: 8,
                                        ),
                                      ],
                                    ),
                                  )
                                  : ListView.builder(
                                    itemCount: records.length,
                                    itemBuilder: (context, index) {
                                      final record = records[index];
                                      return GestureDetector(
                                        onTap: () {
                                          AppNavigation.push(
                                            PatientDrawerMedicalRecordDetailsView(
                                              record: record,
                                              recordId: record['id'],
                                            ),
                                          );
                                        },
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: IntrinsicHeight(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  // Leading
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          left: 12,
                                                          right: 12,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                          10,
                                                        ),
                                                    width:
                                                        ScreenUtil.scaleWidth(
                                                          context,
                                                          55,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                      color: Colors.green,
                                                    ),
                                                    child: CustomTextWidget(
                                                      text:
                                                          (record['createdAt']
                                                                  as String)
                                                              .dayMonthDisplay,
                                                      textStyle: TextStyle(
                                                        fontFamily:
                                                            AppFonts.rubik,
                                                        fontSize:
                                                            FontSizes(
                                                              context,
                                                            ).size14,
                                                        color:
                                                            AppColors
                                                                .gradientWhite,
                                                      ),
                                                      textAlignment:
                                                          TextAlign.center,
                                                    ),
                                                  ),

                                                  // Main Content
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        CustomTextWidget(
                                                          text:
                                                              'Record added by you',
                                                          textStyle: TextStyle(
                                                            fontFamily:
                                                                AppFonts.rubik,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize:
                                                                FontSizes(
                                                                  context,
                                                                ).size14,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        CustomTextWidget(
                                                          text:
                                                              'Record for ${record['patientName']}',
                                                          textStyle: TextStyle(
                                                            fontFamily:
                                                                AppFonts.rubik,
                                                            fontSize:
                                                                FontSizes(
                                                                  context,
                                                                ).size12,
                                                            color:
                                                                AppColors
                                                                    .gradientGreen,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        CustomTextWidget(
                                                          text:
                                                              '${record['images'].length} ${record['type']}',
                                                          textStyle:
                                                              const TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          right: 12.0,
                                                        ),
                                                    child: Center(
                                                      child:
                                                          PopupMenuButtonWidget(
                                                            recordId:
                                                                record['id'] ??
                                                                '',
                                                            images:
                                                                record['images'],
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                      loading:
                          () => const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.gradientGreen,
                            ),
                          ),
                      error:
                          (error, stack) => Center(
                            child: Column(
                              children: [
                                const CustomTextWidget(
                                  text: 'Error loading records',
                                ),
                                CustomButtonWidget(
                                  text: 'Retry',
                                  fontSize: FontSizes(context).size16,
                                  fontFamily: AppFonts.rubikMedium,
                                  width: ScreenUtil.scaleWidth(context, 275),
                                  height: ScreenUtil.scaleHeight(context, 54),
                                  backgroundColor: AppColors.gradientGreen,
                                  onPressed: () {
                                    ref.refresh(medicalRecordsProvider);
                                  },
                                ),
                              ],
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isRecordsNotEmpty)
            Positioned(
              bottom: ScreenUtil.scaleHeight(context, 90),
              right: ScreenUtil.scaleHeight(context, 10),
              child: FloatingActionButton(
                onPressed: () {
                  AppNavigation.push(const PatientDrawerAddPatientRecordView());
                },
                backgroundColor: AppColors.gradientGreen,
                mini: true,
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}
