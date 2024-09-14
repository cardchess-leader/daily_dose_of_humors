import 'package:uuid/uuid.dart';
import 'dart:math';

class GLOBAL {
  /* DO NOT CHANGE BELOW VALUES */
  static const uuid = Uuid();
  static final random = Random();
  /* EDIT BELOW VALUES FOR APP CONFIG CHANGE */
  static const IS_PRODUCTION = true; // Make this true before build
  static const SHOW_AD_FREQUENCY =
      30; // after how many page swipes the ad should show
  static const SMALL_MAX_INT = 1000000; // max bookmark limit
  /* BELOW ARE STATIC FUNCTIONS */
  static String serverPath() {
    return IS_PRODUCTION
        ? 'https://us-central1-daily-dose-of-humors.cloudfunctions.net'
        : 'http://10.0.2.2:5001/daily-dose-of-humors/us-central1';
  }
}
