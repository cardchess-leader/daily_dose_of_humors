import 'dart:io';
import 'dart:math';
import 'package:uuid/uuid.dart';

class GLOBAL {
  /* DO NOT CHANGE BELOW VALUES */
  static const uuid = Uuid();
  static final random = Random();
  static const aspectRatio = 3 / 4.1;
  static const REVENUECAT_ANDROID_API_KEY = 'goog_kUyKgRBqIPMrJTmyjmQYKhGxSCO';
  static const REVENUECAT_IOS_API_KEY = 'appl_nIBTlTrOxElyjKldCIDZWaKhHSj';
  static const PRIVACY_POLICY_URL =
      'https://boardcollie.netlify.app/daily%20dose%20of%20humors/privacy.html';
  static const TERMS_OF_SERVICE_URL =
      'https://boardcollie.netlify.app/daily%20dose%20of%20humors/terms_of_service.html';
  static const EMAIL_ADDRESS = 'support@boardcollie.io';
  /* EDIT BELOW VALUES FOR NEW BUILD */
  static const VERSION_NO = 'v1.0.1';
  static const IS_PRODUCTION = true; // Make this true before build
  /* EDIT BELOW VALUES FOR APP CONFIG CHANGE */
  static const SHOW_AD_FREQUENCY =
      100; // after how many page swipes the ad should show
  static const SMALL_MAX_INT = 1000000; // max bookmark limit
  static const MAX_THUMBSUP_COUNT = 10; // max thumbs up (FAB) limit per day
  static const MAX_SUBMIT_COUNT =
      10; // max user-created humor submission limit per day
  /* BELOW ARE STATIC FUNCTIONS */
  static String serverPath() {
    return IS_PRODUCTION
        ? 'https://us-central1-daily-dose-of-humors.cloudfunctions.net'
        : 'https://us-central1-daily-dose-of-humors.cloudfunctions.net';
  }

  static String getRevCatApiKey() {
    if (Platform.isAndroid) {
      print("IS ANDROID");
      return REVENUECAT_ANDROID_API_KEY;
    } else {
      print("IS IOS");
      return REVENUECAT_IOS_API_KEY;
    }
  }
}
