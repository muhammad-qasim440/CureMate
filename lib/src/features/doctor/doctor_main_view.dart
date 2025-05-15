import 'package:curemate/src/features/doctor/chat/views/doctor_chat_view.dart';
import 'package:curemate/src/features/doctor/dashboard/views/doctor_dashboard_view.dart';
import 'package:curemate/src/features/doctor/home/views/doctor_home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/app_exit_bottom_sheet/exit_app_bottom_sheet.dart';
import '../../theme/app_colors.dart';
import '../bookings/providers/booking_providers.dart';
import 'bookings/views/doctor_booking_view.dart';

final doctorBottomNavIndexProvider = StateProvider<int>((ref) => 0);

class DoctorMainView extends ConsumerWidget {
  const DoctorMainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(doctorBottomNavIndexProvider);

    return WillPopScope(
      onWillPop: () async {
        if (selectedIndex != 0) {
          ref.read(doctorBottomNavIndexProvider.notifier).state = 0;
          return false;
        }
        ExitAppBottomSheet(
          exit: () async => await SystemNavigator.pop(),
        ).show(context);
        return false;
      },
      child: Scaffold(
        body: IndexedStack(
          index: selectedIndex,
          children: const [
            DoctorHomeView(),
            DoctorBookingsView(),
            DoctorChatView(),
            DoctorDashboardView(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            ref.read(doctorBottomNavIndexProvider.notifier).state = index;
            ref.read(appointmentsFilterOptionProvider.notifier).state = 'All';
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            _bottomNavItem(Icons.home_outlined, selectedIndex == 0),
            _bottomNavItem(Icons.menu_book_outlined, selectedIndex == 1),
            _bottomNavItem(Icons.chat, selectedIndex == 2),
            _bottomNavItem(Icons.dashboard, selectedIndex == 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _bottomNavItem(IconData icon, bool isSelected) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gradientGreen : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey,
        ),
      ),
      label: '',
    );
  }
}

