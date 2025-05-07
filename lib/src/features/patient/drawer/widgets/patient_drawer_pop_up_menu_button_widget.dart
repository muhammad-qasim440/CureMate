import 'package:curemate/src/shared/providers/check_internet_connectivity_provider.dart';
import 'package:curemate/src/shared/widgets/custom_confirmation_dialog_widget.dart';
import 'package:curemate/src/shared/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';import '../../../../../const/app_strings.dart';
import '../../../../theme/app_colors.dart';


import '../helpers/drawer_helpers.dart';
import '../providers/drawer_providers.dart';
import '../providers/patient_drawer_medical_records_pop_menu_more_menu_items_provider.dart';


class PopupMenuButtonWidget extends ConsumerWidget {
      final List<Map<String, String>> images;
      final String recordId;

  const PopupMenuButtonWidget(
      {
        super.key,      required this.images,
        required this.recordId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawerHelpers=DrawerHelpers();
    final hasInternetAccess=ref.watch(checkInternetConnectionProvider).value??false;
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      offset: const Offset(0, 40),
      icon: const Icon(Icons.more_vert, size: 20,color:AppColors.subtextcolor ,),
      onSelected: (value) async {
        try {
          if(hasInternetAccess) {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => const CustomConfirmationDialogWidget(
                title: 'Confirm Deletion',
                content: 'Are you sure you want to delete this record?',

              ),
            );

            if (confirm == true) {
            await  drawerHelpers.deleteRecord(images, recordId);
              // ref.invalidate(medicalRecordsProvider);
              CustomSnackBarWidget.show(context: context, text: 'Record deleted successfully');
            }
          }else{
          CustomSnackBarWidget.show(context: context, text: AppStrings.noInternetInSnackBar);
        }} catch (e) {
               CustomSnackBarWidget.show(context: context, text: '$e');
        }
      },
      itemBuilder: (context) => buildPopupMoreMenuItems(),
    );
  }
}
