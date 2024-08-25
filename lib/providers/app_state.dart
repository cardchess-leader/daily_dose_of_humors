import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod/riverpod.dart';
import 'package:daily_dose_of_humors/util/global_var.dart';

class UserSettingsNotifier extends StateNotifier<Map<String, bool>> {
  UserSettingsNotifier()
      : super({
          'darkMode': false,
          'vibration': true,
          'notification': true,
        }) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if it's the first launch
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    if (isFirstLaunch) {
      // Set default preferences
      await prefs.setBool('darkMode', state['darkMode']!);
      await prefs.setBool('vibration', state['vibration']!);
      await prefs.setBool('notification', state['notification']!);
      await prefs.setBool('isFirstLaunch', false);
    } else {
      // Load existing preferences
      state = {
        'darkMode': prefs.getBool('darkMode') ?? false,
        'vibration': prefs.getBool('vibration') ?? true,
        'notification': prefs.getBool('notification') ?? true,
      };
    }
  }

  Future<void> toggleSettings(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final currentValue = state[key] ?? false;
    state = {
      ...state,
      key: !currentValue,
    };
    await prefs.setBool(key, !currentValue);
  }
}

final userSettingsProvider =
    StateNotifierProvider<UserSettingsNotifier, Map<String, bool>>((ref) {
  return UserSettingsNotifier();
});

class AdNotifier extends StateNotifier<void> {
  AdNotifier() : super(null) {
    loadAd();
  }

  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  InterstitialAd? _interstitialAd;
  int _counter = 0;

  void loadAd() {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {},
            onAdImpression: (ad) {},
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              loadAd();
            },
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              loadAd();
            },
            onAdClicked: (ad) {},
          );
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
          loadAd();
        },
      ),
    );
  }

  void showAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      print('Interstitial ad is not ready yet.');
    }
  }

  void incrementCounter() {
    _counter++;
    print('counter is: $_counter');
    if (_counter >= GLOBAL.SHOW_AD_FREQUENCY) {
      showAd();
      _counter = 0; // Reset counter after showing the ad
    }
  }
}

final adProvider = StateNotifierProvider<AdNotifier, void>((ref) {
  return AdNotifier();
});

// Require another provider for subscription management