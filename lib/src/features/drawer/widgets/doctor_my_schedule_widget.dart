import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/shared/widgets/custom_appbar_header_widget.dart';
import 'package:curemate/src/shared/widgets/custom_button_widget.dart';
import 'package:curemate/src/shared/widgets/custom_confirmation_dialog_widget.dart';
import 'package:curemate/src/shared/widgets/custom_snackbar_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../theme/app_colors.dart';
import '../helpers/doctor_schedule_services.dart';
import '../providers/doctor_schedule_providers.dart';
import 'doctor_add_slot_form_widget.dart';
import 'doctor_schedule_header_widget.dart';
import 'doctor_schedule_list_widget.dart';

class DoctorMyScheduleViewWidget extends ConsumerStatefulWidget {
  const DoctorMyScheduleViewWidget({super.key});

  @override
  ConsumerState<DoctorMyScheduleViewWidget> createState() => _DoctorMyScheduleViewWidgetState();
}

class _DoctorMyScheduleViewWidgetState extends ConsumerState<DoctorMyScheduleViewWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = DoctorScheduleService(ref);
      if (mounted) {
        service.loadAvailability();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final service = DoctorScheduleService(ref);
    final isShowInputUI = ref.watch(showInputUIProvider);
    return Scaffold(
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Column(
                children: [
                  const CustomAppBarHeaderWidget(title: 'My Schedule'),
                  25.height,
                  Expanded(
                    child: Form(
                      key: formKey,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final availabilityAsync = ref.watch(doctorAvailabilityProvider);
                          return availabilityAsync.when(
                            data: (data) {
                              return _buildContent(context, ref, service, formKey);
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (error, _) => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomTextWidget(
                                    text: 'Failed to load schedule. Please try again.',
                                    textStyle: TextStyle(
                                      fontFamily: AppFonts.rubik,
                                      fontSize: FontSizes(context).size14,
                                      color: Colors.red,
                                    ),
                                  ),
                                  10.height,
                                  CustomButtonWidget(
                                    text: 'Retry',
                                    height: ScreenUtil.scaleHeight(context, 40),
                                    width: ScreenUtil.scaleWidth(context, 150),
                                    backgroundColor: AppColors.gradientGreen,
                                    fontFamily: AppFonts.rubik,
                                    fontSize: FontSizes(context).size14,
                                    fontWeight: FontWeight.w600,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      ref.invalidate(doctorAvailabilityProvider);
                                      if (mounted) {
                                        service.loadAvailability();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: ScreenUtil.scaleHeight(context, 90),
            right: ScreenUtil.scaleHeight(context, 10),
            child: FloatingActionButton(
              onPressed: () {
                if (isShowInputUI) {
                  ref.read(showInputUIProvider.notifier).state = false;
                  service.resetTempProviders();
                } else {
                  ref.read(showInputUIProvider.notifier).state = true;
                }
                ref.read(editingDayProvider.notifier).state = null;
                service.resetTempProviders();
              },
              backgroundColor: AppColors.gradientGreen,
              mini: true,
              child: Icon(
                isShowInputUI ? Icons.close : Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, DoctorScheduleService service, GlobalKey<FormState> formKey) {
    final showInputUI = ref.watch(showInputUIProvider);
    final editingDay = ref.watch(editingDayProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DoctorScheduleHeaderWidget(),
          10.height,
          DoctorScheduleListWidget(
            onEdit: (config) {
              ref.read(showInputUIProvider.notifier).state = true;
              ref.read(editingDayProvider.notifier).state = config['day']?.toString();
              service.loadConfigForEdit(config);
            },
            onDelete: (day) { _showDeleteConfirmationDialog(context, ref, service, day);},
          ),
          20.height,
          if (showInputUI) ...[
            23.height,
            DoctorAddSlotFormWidget(
              isEditing: editingDay != null,
              onAddOrUpdate: () async {
                final error = service.addOrUpdateConfig(editingDay: editingDay);
                if (error != null) {
                  CustomSnackBarWidget.show(context: context, text: error.toString());
                } else {
                  CustomSnackBarWidget.show(
                    context: context,
                    text: editingDay != null
                        ? '$editingDay updated successfully'
                        : 'Slot added successfully',
                  );
                  ref.read(showInputUIProvider.notifier).state = false;
                  ref.read(editingDayProvider.notifier).state = null;
                }
              },
              formKey: formKey,
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, WidgetRef ref, DoctorScheduleService service, String day) {
    showDialog(
      context: context,
      builder: (context) => CustomConfirmationDialogWidget(
        title: 'Confirm Deletion',
        content: 'Are you sure you want to remove $day\'s availability?',
        confirmText: 'Remove',
        cancelText: 'Cancel',
        onConfirm: () async {
          final editingDay = ref.read(editingDayProvider);
          final error = await service.deleteConfig(day, editingDay: editingDay);
          if (error != null) {
            CustomSnackBarWidget.show(context: context, text: error);
          } else {
            CustomSnackBarWidget.show(context: context, text: '$day removed successfully');
            if (editingDay == day) {
              ref.read(showInputUIProvider.notifier).state = false;
              ref.read(editingDayProvider.notifier).state = null;
            }
          }
        },
        onCancel: () {},
      ),
    );
  }
}







