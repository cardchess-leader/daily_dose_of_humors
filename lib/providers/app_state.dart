import 'package:riverpod/riverpod.dart';

enum AppStateKey {
  darkMode,
  vibration,
}

class AppStateNotifier extends StateNotifier<Map<AppStateKey, bool>> {
  AppStateNotifier()
      : super({
          AppStateKey.darkMode: false,
          AppStateKey.vibration: false,
        });

  void toggleDarkMode() {
    state = {
      ...state,
      AppStateKey.darkMode: !state[AppStateKey.darkMode]!,
    };
  }
}

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, Map<AppStateKey, bool>>(
  (ref) => AppStateNotifier(),
);
