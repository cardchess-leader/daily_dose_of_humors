import 'package:uuid/uuid.dart';
import 'dart:math';

// const uuid = Uuid();

class GLOBAL {
  /* DO NOT CHANGE BELOW VALUES */
  static const uuid = Uuid();
  static final random = Random();
  /* EDIT BELOW VALUES FOR APP CONFIG CHANGE */
  static const SHOW_AD_FREQUENCY =
      30; // after how many page swipes the ad should show
  static const SMALL_MAX_INT = 1000000; // max bookmark limit
}
