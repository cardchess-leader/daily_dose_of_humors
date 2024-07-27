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
      darkTheme: ThemeData.dark().copyWith(
        brightness: Brightness.dark,
        primaryColor: Colors.grey[900],
        scaffoldBackgroundColor: Colors.grey[850],
        colorScheme: ColorScheme.dark(
          primary: Colors.grey.shade900,
          secondary: Colors.blueGrey.shade300,
          surface: Colors
              .grey[850]!, // Use surface color for cards and other surfaces
        ),
        // colorScheme: kDarkColorScheme,
        textTheme: GoogleFonts.patrickHandTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const TabsScreen(),
      navigatorObservers: [routeObserver],
    );
  }
}
