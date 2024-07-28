import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/screens/tabs.dart';
import 'package:google_fonts/google_fonts.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
      home: const TabsScreen(),
      navigatorObservers: [routeObserver],
    );
  }
}
