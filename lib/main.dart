import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/screens/tabs.dart';
import 'package:google_fonts/google_fonts.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // scaffoldBackgroundColor: Color.fromARGB(255, 242, 255, 255),
        textTheme: GoogleFonts.patrickHandTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TabsScreen(),
      navigatorObservers: [routeObserver],
    );
  }
}
