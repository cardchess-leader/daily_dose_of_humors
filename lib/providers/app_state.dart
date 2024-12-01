import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod/riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:daily_dose_of_humors/data/subscription_data.dart';
import 'package:daily_dose_of_humors/util/global_var.dart';
import 'package:daily_dose_of_humors/models/subscription.dart';
import 'package:daily_dose_of_humors/db/db.dart';
import 'package:daily_dose_of_humors/models/humor.dart';
import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/models/bundle_set.dart';
import 'package:daily_dose_of_humors/models/bundle.dart';

class SubscriptionStatusNotifier extends StateNotifier<Subscription> {
  final Ref ref;

  SubscriptionStatusNotifier(this.ref) : super(freeSubscription);

  /// Updates the subscription status by checking active purchases or entitlements.
  Future<void> updateSubscriptionStatus() async {
    try {
      // Check if the lifetime subscription SKU is purchased
      if (ref
          .read(iapProvider.notifier)
          .isSkuPurchased('subscription_lifetime')) {
        state = Subscription.getSubscriptionByCode(SubscriptionCode.LIFETIME);
        return;
      }

      // Retrieve customer info from Purchases SDK
      final CustomerInfo customerInfo = await Purchases.getCustomerInfo();

      // Get active entitlements
      final List<String> activeSubscriptionList = customerInfo
          .entitlements.all.entries
          .where((entry) => entry.value.isActive)
          .map((entry) => entry.key)
          .toList();

      // Update state based on active subscriptions
      if (activeSubscriptionList.contains('subscription:yearly')) {
        state = Subscription.getSubscriptionByCode(SubscriptionCode.YEARLY);
      } else if (activeSubscriptionList.contains('subscription:monthly')) {
        state = Subscription.getSubscriptionByCode(SubscriptionCode.MONTHLY);
      } else {
        state = freeSubscription; // Fallback to free subscription if no match
      }
    } catch (e, stackTrace) {
      print("Error loading entitlements: $e");
      print(stackTrace);
      state = freeSubscription; // Ensure the state falls back to FREE on errors
    }
  }

  /// Checks if the user is subscribed to any paid plan.
  bool isSubscribed() => state.subscriptionCode != SubscriptionCode.FREE;
}

final subscriptionStatusProvider =
    StateNotifierProvider<SubscriptionStatusNotifier, Subscription>((ref) {
  return SubscriptionStatusNotifier(ref);
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

  /// Loads preferences from `SharedPreferences` or sets defaults for the first launch.
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if it's the first launch
      final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
      if (isFirstLaunch) {
        await _handleFirstLaunch(prefs);
      } else {
        // Load existing preferences
        state = {
          'darkMode': prefs.getBool('darkMode') ?? false,
          'vibration': prefs.getBool('vibration') ?? true,
          'notification': prefs.getBool('notification') ?? false,
        };
      }
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }

  /// Handles first launch logic, including setting default preferences and requesting notification permissions.
  Future<void> _handleFirstLaunch(SharedPreferences prefs) async {
    try {
      // Request notification permissions
      final notificationSettings =
          await FirebaseMessaging.instance.requestPermission();

      if (notificationSettings.authorizationStatus ==
          AuthorizationStatus.authorized) {
        state['notification'] = true;
        await FirebaseMessaging.instance.subscribeToTopic("daily_humor");
        await FirebaseMessaging.instance.subscribeToTopic("promotion");
      }

      // Save default preferences
      await prefs.setBool('darkMode', state['darkMode']!);
      await prefs.setBool('vibration', state['vibration']!);
      await prefs.setBool('notification', state['notification']!);
      await prefs.setBool('isFirstLaunch', false);
      await prefs.setString('uuid', GLOBAL.uuid.v4());
    } catch (e) {
      print('Error during first launch setup: $e');
    }
  }

  /// Toggles a user setting and updates `SharedPreferences`.
  Future<void> toggleSettings(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentValue = state[key] ?? false;

      // Update local state
      state = {
        ...state,
        key: !currentValue,
      };

      // Save updated preference
      await prefs.setBool(key, !currentValue);

      // Handle notification subscription changes
      if (key == 'notification') {
        await _handleNotificationSubscription(state['notification']!);
      }
    } catch (e) {
      print('Error toggling setting for $key: $e');
    }
  }

  /// Manages notification topic subscriptions based on the user's preference.
  Future<void> _handleNotificationSubscription(bool enable) async {
    try {
      if (enable) {
        await FirebaseMessaging.instance.subscribeToTopic("daily_humor");
        await FirebaseMessaging.instance.subscribeToTopic("promotion");
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic("daily_humor");
        await FirebaseMessaging.instance.unsubscribeFromTopic("promotion");
      }
    } catch (e) {
      print('Error managing notification subscriptions: $e');
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

  /// Gets the total count of bookmarks.
  Future<int> getBookmarkCount() async {
    try {
      return await DatabaseHelper().getBookmarkCount();
    } catch (e) {
      print('Error getting bookmark count: $e');
      return 0;
    }
  }

  /// Retrieves all bookmarks from the database.
  Future<List<Humor>> getAllBookmarks() async {
    try {
      return await DatabaseHelper().getAllBookmarks();
    } catch (e) {
      print('Error getting all bookmarks: $e');
      return [];
    }
  }

  /// Searches bookmarks by keyword.
  Future<List<Humor>> getBookmarksByKeyword(String keyword) async {
    try {
      return await DatabaseHelper().getBookmarksByKeyword(keyword);
    } catch (e) {
      print('Error searching bookmarks by keyword "$keyword": $e');
      return [];
    }
  }

  /// Checks if a specific humor is bookmarked.
  Future<bool> isHumorBookmarked(Humor humor) async {
    try {
      return await DatabaseHelper().isBookmarked(humor);
    } catch (e) {
      print('Error checking if humor is bookmarked: $e');
      return false;
    }
  }

  /// Removes a bookmark for the given humor.
  Future<bool> removeBookmark(Humor humor) async {
    try {
      return await DatabaseHelper().removeBookmark(humor);
    } catch (e) {
      print('Error removing bookmark for humor: $e');
      return false;
    }
  }

  /// Adds a bookmark for the given humor.
  Future<bool> addBookmark(Humor humor) async {
    try {
      final BookmarkHumor humorToAdd = humor is BookmarkHumor
          ? humor
          : BookmarkHumor.convertFromDailyHumor(humor as DailyHumor);
      return await DatabaseHelper().addBookmark(humorToAdd);
    } catch (e) {
      print('Error adding bookmark for humor: $e');
      return false;
    }
  }

  /// Toggles the bookmark status of a humor.
  ///
  /// Status Codes:
  /// - 1: Remove Success
  /// - 2: Remove Fail
  /// - 3: Add Success
  /// - 4: Add Fail (Due to max limit reached)
  /// - 5: Add Fail (Other issues)
  Future<int> toggleBookmark(Humor humor) async {
    try {
      final subscription = ref.read(subscriptionStatusProvider);
      final int maxBookmarkCount = subscription.maxBookmarks;

      // Check if humor is already bookmarked
      if (await isHumorBookmarked(humor)) {
        // Attempt to remove bookmark
        return (await removeBookmark(humor)) ? 1 : 2;
      } else {
        // Check if max bookmark limit is reached
        if (await getBookmarkCount() >= maxBookmarkCount) {
          return 4; // Max limit reached
        }

        // Attempt to add bookmark
        return (await addBookmark(humor)) ? 3 : 5;
      }
    } catch (e) {
      print('Error toggling bookmark for humor: $e');
      return 5; // Default to add fail (other issues)
    }
  }
}

final bookmarkProvider = StateNotifierProvider<BookmarkNotifier, void>((ref) {
  return BookmarkNotifier(ref); // Pass ref to BookmarkNotifier
});

class LibraryNotifier extends StateNotifier<void> {
  LibraryNotifier() : super(null);

  /// Saves a bundle and its associated humors into the library.
  Future<bool> saveBundleHumorsIntoLibrary(
      Bundle bundle, List<Humor> bundleHumors) async {
    try {
      return await DatabaseHelper().saveBundleIntoLibrary(bundle, bundleHumors);
    } catch (e) {
      print('Error saving bundle into library: $e');
      return false;
    }
  }

  /// Retrieves all bundles stored in the library.
  Future<List<Bundle>> getAllBundles() async {
    try {
      return await DatabaseHelper().getAllBundles();
    } catch (e) {
      print('Error retrieving all bundles: $e');
      return [];
    }
  }

  /// Retrieves all humors associated with a specific bundle.
  Future<List<Humor>> getAllBundleHumors(Bundle bundle) async {
    try {
      return await DatabaseHelper().getAllBundleHumors(bundle);
    } catch (e) {
      print('Error retrieving bundle humors for ${bundle.title}: $e');
      return [];
    }
  }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, void>((ref) {
  return LibraryNotifier();
});

class AdNotifier extends StateNotifier<void> {
  AdNotifier() : super(null) {
    _loadAd();
  }

  final String adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  InterstitialAd? _interstitialAd;
  int _counter = 0;

  /// Loads an interstitial ad.
  void _loadAd() {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('Interstitial ad loaded.');
          _interstitialAd = ad;
          _setAdCallbacks(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Failed to load interstitial ad: $error');
          _interstitialAd = null; // Ensure no stale references
          // Retry loading the ad after a delay
          Future.delayed(const Duration(seconds: 5), _loadAd);
        },
      ),
    );
  }

  /// Sets callbacks for the interstitial ad lifecycle events.
  void _setAdCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('Ad showed full-screen content.');
      },
      onAdImpression: (ad) {
        print('Ad impression recorded.');
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        print('Ad failed to show full-screen content: $err');
        ad.dispose();
        _loadAd();
      },
      onAdDismissedFullScreenContent: (ad) {
        print('Ad dismissed.');
        ad.dispose();
        _loadAd();
      },
      onAdClicked: (ad) {
        print('Ad clicked.');
      },
    );
  }

  /// Shows the interstitial ad if it's ready.
  void showAd() {
    if (_interstitialAd != null) {
      print('Showing interstitial ad.');
      _interstitialAd!.show();
      _interstitialAd = null; // Clear the reference after showing
    } else {
      print('Interstitial ad is not ready yet.');
    }
  }

  /// Increments the ad counter and shows an ad if the frequency is met.
  void incrementCounter() {
    _counter++;
    if (_counter >= GLOBAL.SHOW_AD_FREQUENCY) {
      print('Ad frequency reached. Attempting to show ad.');
      showAd();
      _counter = 0; // Reset counter after showing the ad
    }
  }

  /// Disposes of the interstitial ad.
  void disposeAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}

final adProvider = StateNotifierProvider<AdNotifier, void>((ref) {
  return AdNotifier();
});

class ServerNotifier extends StateNotifier<void> {
  final Ref ref;
  ServerNotifier(this.ref) : super(null);

  /// Generic method to make HTTP GET requests and decode JSON.
  Future<dynamic> _getRequest(Uri url) async {
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
            'GET request failed for ${url.toString()} with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error making GET request to ${url.toString()}: $e');
      return null;
    }
  }

  /// Generic method to make HTTP POST requests and decode JSON.
  Future<dynamic> _postRequest(Uri url, Map<String, dynamic> body) async {
    try {
      final response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
            'POST request failed for ${url.toString()} with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error making POST request to ${url.toString()}: $e');
      return null;
    }
  }

  /// Load daily humors for a specific category.
  Future<List<DailyHumor>> loadDailyHumors(Category humorCategory) async {
    final Uri url = Uri.parse(
        '${GLOBAL.serverPath()}/getDailyHumors?category=${humorCategory.categoryCode.name}');

    final data = await _getRequest(url);

    if (data != null && data['humorList'] != null) {
      return (data['humorList'] as List<dynamic>)
          .map<DailyHumor>((json) => DailyHumor.loadFromServer(
              {...json, 'source_name': 'Daily Dose of Humors'}))
          .toList();
    }

    return [];
  }

  /// Submit user humor.
  Future<String?> submitUserHumors(BookmarkHumor humor) async {
    final remainingSubmissions =
        ref.read(appStateProvider)['submit_count_remaining'] ?? 0;
    if (remainingSubmissions <= 0) {
      return 'You can submit up to ${GLOBAL.MAX_SUBMIT_COUNT} humors daily! Please try again tomorrow.';
    }

    final Uri url = Uri.parse('${GLOBAL.serverPath()}/userSubmitDailyHumors');

    final appUuid =
        (await SharedPreferences.getInstance()).getString('uuid') ?? '';
    final body = {
      'nickname': humor.sender,
      'context': humor.context,
      'punchline': humor.punchline,
      'humor_uuid': humor.uuid,
      'subscription_type':
          ref.read(subscriptionStatusProvider).subscriptionName,
      'app_uuid': appUuid,
    };

    final data = await _postRequest(url, body);

    if (data != null) {
      ref.read(appStateProvider.notifier).submitUserHumors();
      return null;
    }

    return 'Unexpected error. Please try again later.';
  }

  /// Reset app state from server.
  Future<String?> resetAppStateFromServer(String lastResetDate) async {
    final Uri url = Uri.parse(
        '${GLOBAL.serverPath()}/resetAppState?lastResetDate=$lastResetDate');

    final data = await _getRequest(url);

    if (data != null && data['last_reset_date'] != null) {
      return data['last_reset_date'];
    }

    return null;
  }

  /// Fetch humor bundle sets.
  Future<List<BundleSet>> fetchHumorBundleSets() async {
    final Uri url = Uri.parse(
        '${GLOBAL.serverPath()}/getBundleSetList?isAdmin=${GLOBAL.IS_PRODUCTION ? 'false' : 'true'}');

    final data = await _getRequest(url);

    if (data != null && data['bundleSetList'] != null) {
      return (data['bundleSetList'] as List<dynamic>)
          .map<BundleSet>((json) => BundleSet.fromJson(json))
          .toList();
    }

    return [];
  }

  /// Get bundle list in a set.
  Future<List<Bundle>> getBundleListInSet(BundleSet bundleSet) async {
    final Uri url = Uri.parse(
        '${GLOBAL.serverPath()}/getBundleListInSet?uuid=${bundleSet.uuid}');

    final data = await _getRequest(url);

    if (data != null && data['bundleList'] != null) {
      return (data['bundleList'] as List<dynamic>)
          .map<Bundle>((json) => Bundle.fromJson(json))
          .toList();
    }

    return [];
  }

  /// Get bundle details.
  Future<Bundle?> getBundleDetail(String uuid) async {
    final Uri url =
        Uri.parse('${GLOBAL.serverPath()}/getBundleDetail?uuid=$uuid');

    final data = await _getRequest(url);

    if (data != null && data['bundle'] != null) {
      return Bundle.fromJson(data['bundle']);
    }

    return null;
  }

  /// Download humor bundle.
  Future<List<Humor>> downloadHumorBundle(Bundle bundle) async {
    final Uri url = Uri.parse(
        '${GLOBAL.serverPath()}/downloadHumorBundle?uuid=${bundle.uuid}');

    final data = await _getRequest(url);

    if (data != null && data['humorList'] != null) {
      return (data['humorList'] as List<dynamic>)
          .map<Humor>((json) =>
              DailyHumor.loadFromServer({...json, 'source_name': bundle.title}))
          .toList();
    }

    return [];
  }

  /// Preview humor bundle.
  Future<List<Humor>> previewHumorBundle(Bundle bundle) async {
    final Uri url = Uri.parse(
        '${GLOBAL.serverPath()}/previewHumorBundle?uuid=${bundle.uuid}');

    final data = await _getRequest(url);

    if (data != null && data['humorList'] != null) {
      return (data['humorList'] as List<dynamic>)
          .map<Humor>((json) =>
              DailyHumor.loadFromServer({...json, 'source_name': bundle.title}))
          .toList();
    }

    return [];
  }

  /// Get available SKU list.
  Future<List<String>> getAvailableSkuList() async {
    final Uri url = Uri.parse('${GLOBAL.serverPath()}/getAvailableSkuList');

    final data = await _getRequest(url);

    if (data != null && data['availableSkuList'] != null) {
      return (data['availableSkuList'] as List<dynamic>)
          .map<String>((sku) => sku.toString())
          .toList();
    }

    return [];
  }
}

final serverProvider = StateNotifierProvider<ServerNotifier, void>((ref) {
  return ServerNotifier(ref);
});

class AppStateNotifier extends StateNotifier<Map<String, dynamic>> {
  final Ref ref;
  final List<int> showAppReviewPopupArray = [
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
  bool _initialized = false;

  AppStateNotifier(this.ref)
      : super({
          'likes_count_remaining': 0,
          'submit_count_remaining': 0,
          'last_reset_date': '0000-00-00',
          'app_open_count': 0,
        });

  /// Initializes the app state by loading preferences and resetting state if needed.
  Future<void> initializeAppState() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      state = {
        ...state,
        'likes_count_remaining': prefs.getInt('likes_count_remaining') ?? 0,
        'submit_count_remaining': prefs.getInt('submit_count_remaining') ?? 0,
        'last_reset_date': prefs.getString('last_reset_date') ?? '0000-00-00',
        'app_open_count': prefs.getInt('app_open_count') ?? 0,
      };

      final dynamic resetResult = await ref
          .read(serverProvider.notifier)
          .resetAppStateFromServer(state['last_reset_date']);
      if (resetResult != null) {
        state = {
          ...state,
          'likes_count_remaining': GLOBAL.MAX_THUMBSUP_COUNT,
          'submit_count_remaining': GLOBAL.MAX_SUBMIT_COUNT,
          'last_reset_date': resetResult,
        };
      }

      state = {
        ...state,
        'app_open_count': state['app_open_count'] + 1,
      };

      await syncAppState();
      await showAppReviewPopup();
    } catch (e) {
      print('Error initializing app state: $e');
    }
  }

  /// Shows the in-app review popup if conditions are met.
  Future<void> showAppReviewPopup() async {
    try {
      final InAppReview inAppReview = InAppReview.instance;

      if (await inAppReview.isAvailable() &&
          showAppReviewPopupArray.contains(state['app_open_count'])) {
        await inAppReview.requestReview();
      }
    } catch (e) {
      print('Error showing app review popup: $e');
    }
  }

  /// Handles the thumbs-up button logic.
  Future<bool> hitThumbsUpFab() async {
    if (state['likes_count_remaining'] <= 0) return false;

    try {
      state = {
        ...state,
        'likes_count_remaining': state['likes_count_remaining'] - 1,
      };
      await syncAppState();
      return true;
    } catch (e) {
      print('Error handling thumbs-up action: $e');
      return false;
    }
  }

  /// Reduces the user's remaining submission count.
  void submitUserHumors() async {
    if (state['submit_count_remaining'] <= 0) return;

    try {
      state = {
        ...state,
        'submit_count_remaining': state['submit_count_remaining'] - 1,
      };
      await syncAppState();
    } catch (e) {
      print('Error submitting user humor: $e');
    }
  }

  /// Synchronizes the app state with `SharedPreferences`.
  Future<void> syncAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      for (final stateKey in state.keys) {
        final value = state[stateKey];
        if (value is int) {
          await prefs.setInt(stateKey, value);
        } else if (value is String) {
          await prefs.setString(stateKey, value);
        }
      }
    } catch (e) {
      print('Error syncing app state: $e');
    }
  }
}

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, Map<String, dynamic>>((ref) {
  return AppStateNotifier(ref);
});

class IAPNotifier extends StateNotifier<bool> {
  bool _initialized = false;
  final Ref ref;
  final Set<String> purchasedSkuList = {};
  final Map<String, ProductDetails> iapDetails = {};
  final Map<String, StoreProduct> subscriptionDetails = {};
  late StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;

  IAPNotifier(this.ref) : super(false) {
    _setupPurchaseUpdateListener();
    restorePurchases();
  }

  /// Restores purchases from InAppPurchase.
  Future<bool> restorePurchases() async {
    try {
      await InAppPurchase.instance.restorePurchases();
      return true;
    } catch (e) {
      print('Error restoring purchases: $e');
      return false;
    }
  }

  /// Loads all available IAP SKUs and their details.
  Future<void> loadAllIapSkuList() async {
    if (_initialized) return;

    try {
      // Fetch available SKUs from the backend
      final availableSkuSet =
          (await ref.read(serverProvider.notifier).getAvailableSkuList())
              .toSet();
      availableSkuSet
          .add('subscription_lifetime'); // Add the lifetime subscription SKU

      // Query product details from InAppPurchase
      final response =
          await InAppPurchase.instance.queryProductDetails(availableSkuSet);
      if (response.notFoundIDs.isNotEmpty) {
        print('SKUs not found: ${response.notFoundIDs}');
      }

      // Store product details
      for (final productDetails in response.productDetails) {
        iapDetails[productDetails.id] = productDetails;
      }

      // Query subscription details from RevenueCat
      final productIds = Platform.isAndroid
          ? ['subscription']
          : ['subscription_monthly', 'subscription_yearly'];
      final products = await Purchases.getProducts(
        productIds,
        productCategory: ProductCategory.subscription,
      );

      for (final product in products) {
        subscriptionDetails[product.identifier] = product;
      }

      _initialized = true;
      state = true;
    } catch (e) {
      print('Error loading IAP SKUs: $e');
    }
  }

  /// Returns product details for a given SKU.
  ProductDetails? getProductDetails(String productId) => iapDetails[productId];

  /// Returns the price string for a given SKU.
  String? getPriceString(String productId) {
    if (iapDetails[productId] != null) {
      return iapDetails[productId]!.price;
    } else if (subscriptionDetails[productId] != null) {
      return subscriptionDetails[productId]!.priceString;
    }
    return null;
  }

  /// Sets up the purchase update listener to track purchases.
  void _setupPurchaseUpdateListener() {
    final Stream<List<PurchaseDetails>> purchaseUpdates =
        InAppPurchase.instance.purchaseStream;

    _purchaseSubscription = purchaseUpdates.listen((purchaseDetailsList) {
      for (final purchaseDetails in purchaseDetailsList) {
        final status = purchaseDetails.status;

        if (status == PurchaseStatus.purchased ||
            status == PurchaseStatus.restored) {
          purchasedSkuList.add(purchaseDetails.productID);

          // Update subscription status if the purchase is a subscription
          if (purchaseDetails.productID.contains('subscription')) {
            ref
                .read(subscriptionStatusProvider.notifier)
                .updateSubscriptionStatus();
          }
        } else if (status == PurchaseStatus.error) {
          print('Error in purchase: ${purchaseDetails.error}');
        }
      }
    }, onError: (error) {
      print('Error in purchase stream: $error');
    });
  }

  /// Checks if a SKU has been purchased.
  bool isSkuPurchased(String sku) => purchasedSkuList.contains(sku);

  /// Purchases a subscription.
  Future<bool> purchaseSubscription(String productId) async {
    try {
      final product = subscriptionDetails[productId];
      if (product == null) {
        throw ArgumentError('Product not found for ID: $productId');
      }

      final customerInfo = await Purchases.purchaseStoreProduct(product);

      // Verify if the subscription is active
      final entitlements = customerInfo.entitlements.all;
      if (entitlements['subscription:monthly']?.isActive == true ||
          entitlements['subscription:yearly']?.isActive == true) {
        ref
            .read(subscriptionStatusProvider.notifier)
            .updateSubscriptionStatus();
        return true;
      }

      return false;
    } catch (e) {
      print('Error purchasing subscription: $e');
      return false;
    }
  }

  ProductDetails? getIapDetails(String productId) {
    return iapDetails[productId];
  }

  @override
  void dispose() {
    _purchaseSubscription.cancel();
    super.dispose();
  }
}

final iapProvider = StateNotifierProvider<IAPNotifier, bool>((ref) {
  return IAPNotifier(ref);
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Auth notifier to handle user state
class AuthNotifier extends StateNotifier<User?> {
  final FirebaseAuth firebaseAuth;

  AuthNotifier(this.firebaseAuth) : super(null);

  Future<void> initializeAuth() async {
    // Check if a user is already signed in
    firebaseAuth.authStateChanges().listen((user) {
      state = user;
    });

    // Sign in anonymously if no user is signed in
    if (firebaseAuth.currentUser == null) {
      await signInAnonymously();
    }
  }

  Future<void> signInAnonymously() async {
    try {
      final userCredential = await firebaseAuth.signInAnonymously();
      state = userCredential.user; // Update the state with the signed-in user
    } catch (e) {
      print("Error during anonymous sign-in: $e");
    }
  }
}

// Provide AuthNotifier as a Riverpod StateNotifierProvider
final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier(ref.watch(firebaseAuthProvider));
});
