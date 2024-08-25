import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:daily_dose_of_humors/providers/app_state.dart';
import 'package:daily_dose_of_humors/screens/tabs.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure the WidgetsBinding is initialized
  MobileAds.instance.initialize();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  TextTheme _getTextTheme(BuildContext context, Brightness brightness) {
    final textTheme = Theme.of(context).textTheme;
    return GoogleFonts.patrickHandTextTheme(
      brightness == Brightness.light
          ? textTheme
          : textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
              decorationColor: Colors.white,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(userSettingsProvider)['darkMode'] ?? false;

    return MaterialApp(
      title: 'Flutter Demo',
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
      home: const TabsScreen(),
      navigatorObservers: [routeObserver],
    );
  }
}
