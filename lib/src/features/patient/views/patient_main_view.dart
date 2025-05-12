
import 'package:curemate/src/features/patient/chat/views/patient_chat_view.dart';
import 'package:curemate/src/features/patient/appointments/views/patient_appointments_view.dart';
import 'package:curemate/src/features/patient/favorites/views/patient_favorite_doctors_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/debug_print.dart';
import '../../../shared/widgets/app_exit_bottom_sheet/exit_app_bottom_sheet.dart';
import '../../../theme/app_colors.dart';
import '../home/views/patient_home_view.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class PatientMainView extends ConsumerStatefulWidget {
  const PatientMainView({super.key});

  @override
  ConsumerState<PatientMainView> createState() => _PatientMainViewState();
}

class _PatientMainViewState extends ConsumerState<PatientMainView> {
  final List<Widget> _screens = const [
    PatientHomeView(),
     PatientFavoriteDoctorsView(),
    PatientAppointmentsView(),
    PatientChatView(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);
    return WillPopScope(
      onWillPop: () async {
        if (selectedIndex != 0) {
          ref.read(bottomNavIndexProvider.notifier).state = 0;
          logDebug('WillPopScope: Set bottomNavIndex to 0 from $selectedIndex');
          return false;
        }
        ExitAppBottomSheet(
          exit: () async {
            await SystemNavigator.pop();
          },
        ).show(context);
        return false;
      },
      child: Scaffold(
        body: _screens[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            ref.read(bottomNavIndexProvider.notifier).state = index;
            logDebug('BottomNavigationBar: Changed index to $index');
          },
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: _buildSelectedIcon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite),
              activeIcon: _buildSelectedIcon(Icons.favorite),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book_outlined),
              activeIcon: _buildSelectedIcon(Icons.menu_book_outlined),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat),
              activeIcon: _buildSelectedIcon(Icons.chat),
              label: '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: AppColors.gradientGreen,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
