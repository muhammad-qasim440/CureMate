import 'package:curemate/src/features/splash/views/splash_view.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const/app_strings.dart';
import '../databases/local/hive/initialize_and_open_hive_db.dart';
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
class App extends ConsumerStatefulWidget {
  const App._();

  static void initilizationAndRun() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
   await initializeHiveDB();
    await openBoxShowOnBoardingViewsDb();
    runApp(const ProviderScope(overrides: [
    ], child: App._()));
  }

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.noScaling,
      ),
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver],
        navigatorKey: AppNavigation.navigatorKey,
        home: const SplashView(),
      ),
    );
  }
}
