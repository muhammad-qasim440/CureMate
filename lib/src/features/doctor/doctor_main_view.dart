import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/src/features/doctor/chat/views/doctor_chat_view.dart';
import 'package:curemate/src/features/patient/chat/views/chat_view.dart';
import 'package:curemate/src/shared/widgets/custom_snackbar_widget.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/check_internet_connectivity_provider.dart';
import '../../shared/widgets/app_exit_bottom_sheet/exit_app_bottom_sheet.dart';
import '../../shared/widgets/custom_button_widget.dart';
import '../../theme/app_colors.dart';
import '../authentication/signin/providers/auth-provider.dart';
import 'home/views/doctor_home_view.dart';


final doctorBottomNavIndexProvider = StateProvider<int>((ref) => 0);

class DoctorMainView extends ConsumerStatefulWidget {
  const DoctorMainView({super.key});

  @override
  ConsumerState<DoctorMainView> createState() => _DoctorMainViewState();
}

class _DoctorMainViewState extends ConsumerState<DoctorMainView> {
  final List<Widget> _screens = const [
    DoctorHomeView(),
    DummyScreen(title: 'Bookings'),
    DummyScreen(title: 'Profile'),
    DoctorChatView(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(doctorBottomNavIndexProvider);
    return WillPopScope(
      onWillPop: () async {
        if (selectedIndex != 0) {
          ref.read(doctorBottomNavIndexProvider.notifier).state = 0;
          print('WillPopScope: Set bottomNavIndex to 0 from $selectedIndex');
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
            ref.read(doctorBottomNavIndexProvider.notifier).state = index;
            print('BottomNavigationBar: Changed index to $index');
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
              icon: const Icon(Icons.menu_book_outlined),
              activeIcon: _buildSelectedIcon(Icons.menu_book_outlined),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat),
              activeIcon: _buildSelectedIcon(Icons.chat),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              activeIcon: _buildSelectedIcon(Icons.person),
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

class DummyScreen extends ConsumerWidget {
  final String title;

  const DummyScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$title screen', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          CustomButtonWidget(
            text: 'logout',
            height: ScreenUtil.scaleHeight(context, 45),
            backgroundColor: AppColors.btnBgColor,
            fontFamily: AppFonts.rubik,
            fontSize: FontSizes(context).size18,
            fontWeight: FontWeight.w900,
            textColor: AppColors.gradientWhite,
            width: ScreenUtil.scaleWidth(context, 320),
            onPressed: () async {
              final isNetworkAvailable = ref.read(
                checkInternetConnectionProvider,
              );
              final isConnected =
                  await isNetworkAvailable.whenData((value) => value).value ??
                      false;

              if (!isConnected) {
                CustomSnackBarWidget.show(
                  context: context,
                  backgroundColor: AppColors.gradientGreen,
                  text: "No Internet Connection",
                );
                return;
              }
              try {
                await ref.read(authProvider).logout(context);
              } catch (e) {
                CustomSnackBarWidget.show(context: context, text: "$e");
              }
            },
          ),
        ],
      ),
    );
  }
}