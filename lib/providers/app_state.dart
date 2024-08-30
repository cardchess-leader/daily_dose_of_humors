import 'dart:io';
import 'package:daily_dose_of_humors/data/subscription_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod/riverpod.dart';
import 'package:daily_dose_of_humors/util/global_var.dart';
import 'package:daily_dose_of_humors/models/subscription.dart';
import 'package:daily_dose_of_humors/db/db.dart';
import 'package:daily_dose_of_humors/models/humor.dart';

class SubscriptionStatusNotifier extends StateNotifier<Subscription> {
  SubscriptionStatusNotifier() : super(freeSubscription) {
    _loadSubscriptionStatus();
  }
  Future<void> _loadSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // there should be get from the server (Google Get Subscription Status) part to check for subscription status
    final subscriptionCode = prefs.getInt('subscriptionStatus') ??
        0; // check this with server subscription value
    state = Subscription.getSubscriptionByCode(
        SubscriptionCode.values[subscriptionCode]);
  }

  Future<void> updateSubscription(SubscriptionCode code) async {
    final prefs = await SharedPreferences.getInstance();
    final newSubscription = Subscription.getSubscriptionByCode(code);
    state = newSubscription;
    await prefs.setInt(
        'subscriptionStatus', newSubscription.subscriptionCode.index);
  }

  bool isSubscriptionAdFree() {
    return state.subscriptionCode != SubscriptionCode.FREE &&
        state.subscriptionCode != SubscriptionCode.MONTHLY;
  }
}

final subscriptionStatusProvider =
    StateNotifierProvider<SubscriptionStatusNotifier, Subscription>((ref) {
  return SubscriptionStatusNotifier();
});

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

class BookmarkNotifier extends StateNotifier<void> {
  final Ref ref;
  BookmarkNotifier(this.ref) : super(null);

  Future<int> getBookmarkCount() async {
    return await DatabaseHelper().getBookmarkCount();
  }

  Future<List<Humor>> getAllBookmarks() async {
    return await DatabaseHelper().getAllBookmarks();
  }

  Future<List<Humor>> getBookmarksByKeyword(String keyword) async {
    return await DatabaseHelper().getBookmarksByKeyword(keyword);
  }

  Future<bool> isHumorBookmarked(Humor humor) async {
    return await DatabaseHelper().isBookmarked(humor);
  }

  Future<bool> removeBookmark(Humor humor) async {
    return await DatabaseHelper().removeBookmark(humor); // Is remove success?
  }

  Future<bool> addBookmark(Humor humor) async {
    return await DatabaseHelper().addBookmark(humor);
  }

  Future<int> toggleBookmark(Humor humor) async {
    /**
     * Status Code:
     * 1: Remove Success
     * 2: Remove Fail
     * 3: Add Success
     * 4: Add Fail (Due to max limit reached)
     * 5: Add Fail (Other issues)
     */
    Subscription subscription = ref.read(subscriptionStatusProvider);
    int maxBookmarkCount = subscription.maxBookmarks;
    if (await isHumorBookmarked(humor)) {
      // Try removing bookmark
      return (await removeBookmark(humor)) ? 1 : 2;
    } else {
      // Try adding bookmark
      if (maxBookmarkCount <= await getBookmarkCount()) {
        return 4;
      } else {
        return ((await addBookmark(humor)) ? 3 : 5);
      }
    }
  }
}

final bookmarkProvider = StateNotifierProvider<BookmarkNotifier, void>((ref) {
  return BookmarkNotifier(ref); // Pass ref to BookmarkNotifier
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