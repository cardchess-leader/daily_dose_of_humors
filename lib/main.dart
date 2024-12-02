import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upgrader/upgrader.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:daily_dose_of_humors/providers/app_state.dart';
import 'package:daily_dose_of_humors/screens/tabs.dart';
import 'package:daily_dose_of_humors/util/global_var.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Preserve the splash screen until resources are fully loaded
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Set preferred screen orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialize Firebase with error handling
  await initializeFirebase();

  // Initialize RevenueCat with error handling
  await initializeRevenueCat();

  // Initialize Remote Config Values
  RemoteConfigService.initialize();

  // Initialize Mobile Ads
  MobileAds.instance.initialize();

  // Optimize image cache
  PaintingBinding.instance.imageCache
    ..maximumSize = 100 // Number of images
    ..maximumSizeBytes = 200 << 20; // 100MB cache size

  removeSplashAfterDuration(700);

  // Run the app
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> removeSplashAfterDuration(int duration) async {
  await Future.delayed(Duration(
      milliseconds: duration)); // Simulate extended loading time for stability

  FlutterNativeSplash.remove(); // Remove splash screen after setup is complete
}

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully.');
  } catch (e, stackTrace) {
    debugPrint('Failed to initialize Firebase: $e\n$stackTrace');
    // Consider notifying the user or logging to a service like Firebase Crashlytics
  }
}

Future<void> initializeRevenueCat() async {
  try {
    await Purchases.configure(
      PurchasesConfiguration(GLOBAL.getRevCatApiKey()),
    );
    print('RevenueCat configured successfully.');
  } catch (e, stackTrace) {
    debugPrint('Failed to configure RevenueCat: $e\n$stackTrace');
    // Handle errors gracefully, maybe disable IAP features
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // Utility method to get text theme based on brightness
  TextTheme _getTextTheme(BuildContext context, Brightness brightness) {
    final baseTextTheme = Theme.of(context).textTheme;
    return GoogleFonts.patrickHandTextTheme(
      brightness == Brightness.light
          ? baseTextTheme
          : baseTextTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
              decorationColor: Colors.white,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch for dark mode settings
    final isDarkMode = ref.watch(userSettingsProvider)['darkMode'] ?? false;

    // Initialize firebase auth
    ref.read(authProvider.notifier).initializeAuth();

    // Initialize application state
    ref.read(appStateProvider.notifier).initializeAppState();

    // Load IAP SKUs
    ref.read(iapProvider.notifier).loadAllIapSkuList();

    return MaterialApp(
      title: 'Daily Dose of Humor',
      theme: ThemeData(
        textTheme: _getTextTheme(context, Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey.shade900,
        colorScheme: ColorScheme.dark(
          surface: Colors.grey.shade900,
          onSurface: Colors.white,
        ),
        textTheme: _getTextTheme(context, Brightness.dark),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: UpgradeAlert(
        showIgnore: false,
        showLater: false,
        child: const TabsScreen(),
      ),
      navigatorObservers: [routeObserver],
    );
  }
}
