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
import '../const/app_strings.dart';
import '../core/lifecycle/observers/app_lifecycle_observer.dart';
import '../core/utils/cache_network_image_utils.dart';
import '../databases/local/hive/initialize_and_open_hive_db.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'features/patient/views/patient_main_view.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class App extends ConsumerStatefulWidget {
  const App._();

  static void initilizationAndRun() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FirebaseDatabase.instance.setLoggingEnabled(true);
    FirebaseAuth.instance.authStateChanges().listen((user) {});

    tz.initializeTimeZones();

    /// Initialize flutter_local_notifications
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    /// Handle tap when app is in foreground/background
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );

    /// Handle tap when app is launched from terminated state
    final details = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      _handleNotificationTap(details!.notificationResponse?.payload);
    }

    /// Ask for notification permission
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await initializeHiveDB();
    await openBoxShowOnBoardingViewsDb();
    await CacheUtils.clearCache();
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
