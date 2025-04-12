import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

Future<void> initializeHiveDB()async {
   await Hive.initFlutter();
}


Future<void> openBoxShowOnBoardingViewsDb() async{
  await Hive.openBox('showOnBoardingViewDbBox');
}
