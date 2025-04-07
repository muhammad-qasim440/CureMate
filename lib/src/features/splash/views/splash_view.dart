import 'package:curemate/assets/app_assets.dart';
import 'package:curemate/src/features/signin/views/login_view.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:curemate/src/utils/delay_utils.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../const/app_strings.dart';
import '../../doctor/home/views/doctor_home_view.dart';
import '../../patient/home/views/patient_home_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _checkAuthUser();
  }

  Future<void> _checkAuthUser() async {
    User? user = _auth.currentUser;
    if (user == null) {
      await wait(const Duration(seconds: 3));
      AppNavigation.push(SignInView());
    } else {
      DatabaseReference userRef = _database.child("Doctor").child(user.uid);
      DataSnapshot snapshot = await userRef.get();
      if (snapshot.exists) {
        await wait(const Duration(seconds: 3));
        AppNavigation.push(const DoctorHomeView());
      } else {
        userRef = _database.child("Patient").child(user.uid);
        DataSnapshot snapshot = await userRef.get();
        if (snapshot.exists) {
          await wait(const Duration(seconds: 3));
          AppNavigation.push(const PatientHomeView());
        } else {
          await wait(const Duration(seconds: 3));
          AppNavigation.push(SignInView());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:()async=>false,
      child: Scaffold(
        body: Container(
          width: ScreenUtil.baseWidth,
          height: ScreenUtil.baseHeight,
          color: Color(0xff0064FA),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: ScreenUtil.scaleHeight(context, 100),
                  right: ScreenUtil.scaleWidth(context, 10),
                ),
                child: CustomTextWidget(
                  text: AppStrings.appName,
                  textStyle: TextStyle(
                    fontSize: 48,
                    fontFamily: GoogleFonts.bangers.toString(),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: ScreenUtil.scaleHeight(context, 10),
                ),
                child: CustomTextWidget(
                  text: 'A Smart Health\n      Solution',
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontFamily: GoogleFonts.poppins.toString(),
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: ScreenUtil.scaleHeight(context, 150),),
              Image.asset(AppAssets.dnaImage),
            ],
          ),
        ),
      ),
    );
  }
}
