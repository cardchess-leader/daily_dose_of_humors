import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod/riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:daily_dose_of_humors/data/subscription_data.dart';
import 'package:daily_dose_of_humors/util/global_var.dart';
import 'package:daily_dose_of_humors/models/subscription.dart';
import 'package:daily_dose_of_humors/db/db.dart';
import 'package:daily_dose_of_humors/models/humor.dart';
import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/models/bundle_set.dart';
import 'package:daily_dose_of_humors/models/bundle.dart';

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

  Future<bool> updateSubscription(SubscriptionCode code) async {
    final prefs = await SharedPreferences.getInstance();
    final newSubscription = Subscription.getSubscriptionByCode(code);
    state = newSubscription;
    await prefs.setInt(
        'subscriptionStatus', newSubscription.subscriptionCode.index);
    return true;
  }

  bool isSubscribed() {
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
          'notification': false,
        }) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if it's the first launch
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    if (isFirstLaunch) {
      // Ask for notification user permission permission
      final notificationSettings =
          await FirebaseMessaging.instance.requestPermission();
      if (notificationSettings.authorizationStatus ==
          AuthorizationStatus.authorized) {
        state['notification'] = true;
        FirebaseMessaging.instance.subscribeToTopic("daily_humor");
        FirebaseMessaging.instance.subscribeToTopic("promotion");
      }

      // Set default preferences
      await prefs.setBool('darkMode', state['darkMode']!);
      await prefs.setBool('vibration', state['vibration']!);
      await prefs.setBool('notification', state['notification']!);
      await prefs.setBool('isFirstLaunch', false);
      await prefs.setString('uuid', GLOBAL.uuid.v4());
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
    if (key == 'notification') {
      if (state['notification'] == true) {
        FirebaseMessaging.instance.subscribeToTopic("daily_humor");
        FirebaseMessaging.instance.subscribeToTopic("promotion");
      } else {
        FirebaseMessaging.instance.unsubscribeFromTopic("daily_humor");
        FirebaseMessaging.instance.unsubscribeFromTopic("promotion");
      }
    }
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
    BookmarkHumor humorToAdd = humor is BookmarkHumor
        ? humor
        : BookmarkHumor.convertFromDailyHumor(humor as DailyHumor);
    return await DatabaseHelper().addBookmark(humorToAdd);
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

class LibraryNotifier extends StateNotifier<void> {
  LibraryNotifier() : super(null);

  Future<bool> saveBundleHumorsIntoLibrary(
      Bundle bundle, List<Humor> bundleHumors) async {
    return await DatabaseHelper().saveBundleIntoLibrary(bundle, bundleHumors);
  }

  Future<List<Bundle>> getAllBundles() async {
    return await DatabaseHelper().getAllBundles();
  }

  Future<List<Humor>> getAllBundleHumors(Bundle bundle) async {
    return await DatabaseHelper().getAllBundleHumors(bundle);
  }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, void>((ref) {
  return LibraryNotifier(); // Pass ref to BookmarkNotifier
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
    if (_counter >= GLOBAL.SHOW_AD_FREQUENCY) {
      showAd();
      _counter = 0; // Reset counter after showing the ad
    }
  }
}

final adProvider = StateNotifierProvider<AdNotifier, void>((ref) {
  return AdNotifier();
});

class ServerNotifier extends StateNotifier<void> {
  final Ref ref;
  ServerNotifier(this.ref) : super(null);

  Future<List<DailyHumor>> loadDailyHumors(Category humorCategory) async {
    try {
      // Construct the full URL with query parameters
      final Uri url = Uri.parse(
          '${GLOBAL.serverPath()}/getDailyHumors?category=${humorCategory.categoryCode.name}');

      // Send a GET request to the Firebase function
      final response = await http.get(url);
      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response
        final data = jsonDecode(response.body);

        // Handle the data as needed
        return data['humorList']
            .map<DailyHumor>((json) => DailyHumor.loadFromServer(
                {...json, 'source_name': 'Daily Dose of Humors'}))
            .toList();
      } else {
        // Handle errors
        return [];
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      return [];
    }
  }

  Future<String?> submitUserHumors(BookmarkHumor humor) async {
    try {
      if ((ref.read(appStateProvider)['submit_count_remaining'] ?? 0) <= 0) {
        return 'You can submit upto ${GLOBAL.MAX_SUBMIT_COUNT} humors daily!\nPlease try again tomorrow!';
      }
      // Construct the full URL with query parameters
      final Uri url = Uri.parse('${GLOBAL.serverPath()}/userSubmitDailyHumors');
      // Send a GET request to the Firebase function
      String appUuid =
          (await SharedPreferences.getInstance()).getString('uuid') ?? '';
      final response = await http.post(url, body: {
        'nickname': humor.sender,
        'context': humor.context,
        'punchline': humor.punchline,
        'humor_uuid': humor.uuid,
        'subscription_type':
            ref.read(subscriptionStatusProvider).subscriptionName,
        'app_uuid': appUuid,
      });
      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response
        ref.read(appStateProvider.notifier).submitUserHumors();
        return null;
      } else {
        return jsonDecode(response.body)['error'];
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      return 'Unexpected error. Please try again later.';
    }
  }

  Future<dynamic> resetAppStateFromServer(String lastResetDate) async {
    try {
      final Uri url = Uri.parse(
          '${GLOBAL.serverPath()}/resetAppState?lastResetDate=$lastResetDate');
      // Send a GET request to the Firebase function
      final response = await http.get(url);
      // Check if the request was successful
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['last_reset_date'];
      } else {
        return false;
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      return false;
    }
  }

  Future<List<BundleSet>> fetchHumorBundleSets() async {
    try {
      // Construct the full URL with query parameters
      final Uri url = Uri.parse('${GLOBAL.serverPath()}/getBundleSetList');

      // Send a GET request to the Firebase function
      final response = await http.get(url);

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response
        final data = jsonDecode(response.body);

        // Handle the data as needed
        return data['bundleSetList']
            .map<BundleSet>((json) => BundleSet.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      return [];
    }
  }

  Future<List<Bundle>> getBundleListInSet(BundleSet bundleSet) async {
    try {
      // Construct the full URL with query parameters
      final Uri url = Uri.parse(
          '${GLOBAL.serverPath()}/getBundleListInSet?uuid=${bundleSet.uuid}');

      // Send a GET request to the Firebase function
      final response = await http.get(url);
      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response
        final data = jsonDecode(response.body);
        return data['bundleList']
            .map<Bundle>((json) => Bundle.fromJson(json))
            .toList();
      } else {
        // Handle errors
        return [];
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      return [];
    }
  }

  Future<Bundle?> getBundleDetail(String uuid) async {
    try {
      // Construct the full URL with query parameters
      final Uri url =
          Uri.parse('${GLOBAL.serverPath()}/getBundleDetail?uuid=$uuid');

      // Send a GET request to the Firebase function
      final response = await http.get(url);
      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response
        final data = jsonDecode(response.body);
        return Bundle.fromJson(data['bundle']);
      } else {
        // Handle errors
        return null;
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      return null;
    }
  }

  Future<List<Humor>> downloadHumorBundle(Bundle bundle) async {
    try {
      // Construct the full URL with query parameters
      final Uri url = Uri.parse(
          '${GLOBAL.serverPath()}/downloadHumorBundle?uuid=${bundle.uuid}');

      // Send a GET request to the Firebase function
      final response = await http.get(url);
      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response
        final data = jsonDecode(response.body);
        return data['humorList']
            .map<Humor>((json) => DailyHumor.loadFromServer(
                {...json, 'source_name': bundle.title}))
            .toList();
      } else {
        // Handle errors
        return [];
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      return [];
    }
  }

  Future<List<Humor>> previewHumorBundle(Bundle bundle) async {
    try {
      // Construct the full URL with query parameters
      final Uri url = Uri.parse(
          '${GLOBAL.serverPath()}/previewHumorBundle?uuid=${bundle.uuid}');

      // Send a GET request to the Firebase function
      final response = await http.get(url);
      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response
        final data = jsonDecode(response.body);
        return data['humorList']
            .map<Humor>((json) => DailyHumor.loadFromServer(
                {...json, 'source_name': bundle.title}))
            .toList();
      } else {
        // Handle errors
        return [];
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      return [];
    }
  }

  Future<List<String>> getAvailableSkuList() async {
    // Construct the full URL with query parameters
    final Uri url = Uri.parse('${GLOBAL.serverPath()}/getAvailableSkuList');

    // Send a GET request to the Firebase function
    final response = await http.get(url);

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Decode the JSON response
      final data = jsonDecode(response.body);

      return (data['availableSkuList'] as List<dynamic>)
          .map((sku) => sku.toString())
          .toList();
    } else {
      // Handle errors
      return [];
    }
  }
}

final serverProvider = StateNotifierProvider<ServerNotifier, void>((ref) {
  return ServerNotifier(ref);
});

class AppStateNotifier extends StateNotifier<Map<String, dynamic>> {
  final Ref ref;
  final showAppReviewPopupArray = [
    2,
    8,
    16,
    24,
    32,
    40,
    50,
    60,
    70,
    80,
    90,
    100
  ];
  var _initialized = false;

  AppStateNotifier(this.ref)
      : super({
          'likes_count_remaining': 0,
          'submit_count_remaining': 0,
          'last_reset_date': '0000-00-00',
          'app_open_count': 0,
        });

  Future<void> initializeAppState() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    print('_initializeAppState');
    final prefs = await SharedPreferences.getInstance();
    state = {
      ...state,
      'likes_count_remaining': prefs.getInt('likes_count_remaining') ?? 0,
      'submit_count_remaining': prefs.getInt('submit_count_remaining') ?? 0,
      'last_reset_date': prefs.getString('last_reset_date') ?? '0000-00-00',
      'app_open_count': prefs.getInt('app_open_count') ?? 0,
    };

    final resetAppStateFromServerResult = await ref
        .read(serverProvider.notifier)
        .resetAppStateFromServer(state['last_reset_date']);
    if (resetAppStateFromServerResult != false) {
      state = {
        ...state,
        'likes_count_remaining': GLOBAL.MAX_THUMBSUP_COUNT,
        'submit_count_remaining': GLOBAL.MAX_SUBMIT_COUNT,
        'last_reset_date': resetAppStateFromServerResult,
      };
    }
    state = {
      ...state,
      'app_open_count': state['app_open_count'] + 1,
    };
    syncAppState();
    showAppReviewPopup();
  }

  Future<void> showAppReviewPopup() async {
    final InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable() &&
        showAppReviewPopupArray.contains(state['app_open_count'])) {
      inAppReview.requestReview();
    }
    inAppReview.requestReview();
  }

  Future<bool> hitThumbsUpFab() async {
    if (state['likes_count_remaining'] <= 0) {
      return false;
    }
    state = {
      ...state,
      'likes_count_remaining': state['likes_count_remaining'] - 1,
    };
    syncAppState();
    return true;
  }

  void submitUserHumors() async {
    if (state['submit_count_remaining'] <= 0) {
      return;
    }
    state = {
      ...state,
      'submit_count_remaining': state['submit_count_remaining'] - 1,
    };
    syncAppState();
  }

  Future<void> syncAppState() async {
    final prefs = await SharedPreferences.getInstance();
    for (final stateKey in state.keys) {
      if (state[stateKey] is int) {
        await prefs.setInt(stateKey, state[stateKey]);
      } else if (state[stateKey] is String) {
        await prefs.setString(stateKey, state[stateKey]);
      }
    }
  }
}

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, Map<String, dynamic>>((ref) {
  return AppStateNotifier(ref);
});

class IAPNotifier extends StateNotifier<Map<String, dynamic>> {
  var _initialized = false;
  final Ref ref;
  final purchasedSkuList = <String>{};
  IAPNotifier(this.ref)
      : super({
          'product_details': {},
        }) {
    setupPurchaseUpdateListener();
    restorePurchases();
  }

  Future<void> restorePurchases() async {
    await InAppPurchase.instance.restorePurchases();
  }

  Future<void> loadAllIapSkuList() async {
    if (_initialized) {
      return;
    }
    // Fetch all available sku lists
    final availSkuSet =
        (await ref.read(serverProvider.notifier).getAvailableSkuList()).toSet();
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(availSkuSet);
    if (response.notFoundIDs.isNotEmpty) {
      // Handle the error.
    }
    List<ProductDetails> productDetails = response.productDetails;

    // Convert product details into a Map<String, String> where key is the product ID, and value is the price.
    final productDetailsMap = {
      for (var productDetail in productDetails) productDetail.id: productDetail,
    };
    state = {
      ...state,
      'product_details': productDetailsMap,
    };

    _initialized = true;
  }

  Future<void> setupPurchaseUpdateListener() async {
    final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;

    purchaseUpdated.listen((purchaseDetailsList) {
      for (final purchaseDetail in purchaseDetailsList) {
        final status = purchaseDetail.status;
        if (status == PurchaseStatus.purchased ||
            status == PurchaseStatus.restored) {
          purchasedSkuList.add(purchaseDetail.productId);
        }
      }
    });
  }

  bool isSkuPurchased(String sku) {
    return purchasedSkuList.contains(sku);
  }
}

final iapProvider =
    StateNotifierProvider<IAPNotifier, Map<String, dynamic>>((ref) {
  return IAPNotifier(ref);
});
