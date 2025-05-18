import 'package:curemate/src/features/disease_diagnosis/views/diagnosis_view.dart';
import 'package:curemate/src/features/patient/chat/views/patient_chat_view.dart';
import 'package:curemate/src/features/patient/appointments/views/patient_appointments_view.dart';
import 'package:curemate/src/features/patient/favorites/views/patient_favorite_doctors_view.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../shared/widgets/app_exit_bottom_sheet/exit_app_bottom_sheet.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../../appointments/providers/appointments_providers.dart';
import '../../doctor/doctor_main_view.dart';
import '../home/views/patient_home_view.dart';

final patientBottomNavIndexProvider = StateProvider<int>((ref) => 0);

class PatientMainView extends ConsumerWidget {
  const PatientMainView({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final selectedIndex = ref.watch(patientBottomNavIndexProvider);
    return WillPopScope(
      onWillPop: () async {
        if (selectedIndex != 0) {
          ref.read(patientBottomNavIndexProvider.notifier).state = 0;
          return false;
        }
        ExitAppBottomSheet(
          exit: () async {
            await SystemNavigator.pop();
          },
        ).show(context);
        return false;
      },
      child: Stack(
        children: [
          Scaffold(
            body: IndexedStack(
              index: selectedIndex,
              children: const [
                PatientHomeView(),
                PatientFavoriteDoctorsView(),
                PatientAppointmentsView(),
                PatientChatView(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) {
                ref.read(patientBottomNavIndexProvider.notifier).state = index;
                ref.read(appointmentsFilterOptionProvider.notifier).state = 'All';
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: [
                bottomNavItem(Icons.home_outlined, selectedIndex == 0),
                bottomNavItem(Icons.favorite, selectedIndex == 1),
                bottomNavItem(Icons.menu_book_outlined, selectedIndex == 2),
                bottomNavItem(Icons.chat, selectedIndex == 3),
              ],
            ),
          ),
          Positioned(
            bottom: ScreenUtil.scaleHeight(context, 110),
            right: ScreenUtil.scaleWidth(context, 20),
            child: Material(
              color: Colors.transparent,
              child: CircleAvatar(
                maxRadius: 25,
                backgroundColor: AppColors.black,
                child: InkWell(
                  child:  Lottie.asset(
                    'assets/animations/diagnosis.json',
                    fit: BoxFit.contain,
                  ),
                  onTap: () {
                        AppNavigation.push(const DiagnosisView());
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }
}
