import 'package:curemate/src/features/splash/views/splash_view.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const/app_strings.dart';
import '../core/lifecycle/observers/app_lifecycle_observer.dart';
import '../core/utils/cache_network_image_utils.dart';
import '../databases/local/hive/initialize_and_open_hive_db.dart';
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
class App extends ConsumerStatefulWidget {
  const App._();

  static void initilizationAndRun() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FirebaseDatabase.instance.setLoggingEnabled(true);
    FirebaseAuth.instance.authStateChanges().listen((user) {
      print('Auth state changed: ${user?.uid}');
    });
   await initializeHiveDB();
    await openBoxShowOnBoardingViewsDb();
    await CacheUtils.clearCache();
    runApp(const ProviderScope(overrides: [
    ], child: App._()));
  }

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    // Initialize observer globally
    ref.read(appLifecycleObserverProvider);
  }

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
        home:const SplashView(),
        // home: const AppWithConnectionCheck(
        //   child: SplashView(),
        // ),
      ),
    );
  }
}
