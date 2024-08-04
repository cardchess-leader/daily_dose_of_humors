import 'dart:io';
import 'package:riverpod/riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
    if (_counter >= 10) {
      showAd();
      _counter = 0; // Reset counter after showing the ad
    }
  }
}

final adProvider = StateNotifierProvider<AdNotifier, void>((ref) {
  return AdNotifier();
});
