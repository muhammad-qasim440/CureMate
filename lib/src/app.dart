import 'dart:async';

import 'package:curemate/src/features/splash/views/splash_view.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import '../const/app_strings.dart';
import '../core/lifecycle/observers/app_lifecycle_observer.dart';
import '../core/utils/cache_network_image_utils.dart';
import '../core/utils/debug_print.dart';
import '../databases/local/hive/initialize_and_open_hive_db.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'features/patient/views/patient_main_view.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class App extends ConsumerStatefulWidget {
  const App._();

  static Future<void> initilizationAndRun() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Future.wait([
      Firebase.initializeApp().then((_) async {
        FirebaseDatabase.instance.setLoggingEnabled(true);
        /// Log auth state for debugging
        FirebaseAuth.instance.authStateChanges().listen((user) {
          logDebug('Auth state changed: ${user?.uid}');
        });
      }),
     Hive.initFlutter().then((_) async {
        /// Check if this is a fresh install
        final box = await Hive.openBox('appConfig');
        final isFirstRun = box.get('isFirstRun', defaultValue: true);
        if (isFirstRun) {
          logDebug('First run detected, clearing Hive and resetting onboarding');
          await Hive.deleteBoxFromDisk('showOnBoardingViewsDb');
          await box.put('isFirstRun', false);
        }
        await initializeHiveDB();
        await openBoxShowOnBoardingViewsDb();
      }),
      CacheUtils.clearCache(),
    ]);

    tz.initializeTimeZones();

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );

    final details = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      _handleNotificationTap(details!.notificationResponse?.payload);
    }


    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      Zone.current.handleUncaughtError(details.exception, details.stack!);
    };

    runApp(const ProviderScope(
      overrides: [],
      child: App._(),
    ));
  }


  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
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
        home: const SplashView(),
      ),
    );
  }
}

void _handleNotificationTap(String? payload) {
  if (payload == null) return;

  if (payload == 'open_tab_2') {
    AppNavigation.navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PatientMainView()),
          (_) => false,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      final context = AppNavigation.navigatorKey.currentContext;
      if (context != null) {
        final container = ProviderScope.containerOf(context, listen: false);
        container.read(patientBottomNavIndexProvider.notifier).state = 2;
      }
    });
  }
}
