// import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

// class DarkModeNotifier extends ChangeNotifier {
//   bool _isDarkMode;

//   DarkModeNotifier(this._isDarkMode);

//   bool get isDarkMode => _isDarkMode;

//   void toggleDarkMode() {
//     _isDarkMode = !_isDarkMode;
//     notifyListeners();
//   }
// }

class DarkModeNotifier extends StateNotifier<bool> {
  DarkModeNotifier() : super(false);

  void toggleDarkMode() {
    state = !state;
    // Perform any side effects here if needed
    print('Dark mode toggled: $state');
  }

  void initDarkMode(bool darkMode) {
    state = darkMode;
  }
}

final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  // Initially set the dark mode to false, it will be updated in the widget
  return DarkModeNotifier();
});
