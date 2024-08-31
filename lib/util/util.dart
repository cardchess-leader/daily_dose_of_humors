import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/util/global_var.dart';

// Function to lighten a color
Color lighten(Color color, [double amount = 0.1]) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return hslLight.toColor();
}

// Function to darken a color
Color darken(Color color, [double amount = 0.1]) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return hslDark.toColor();
}

List<Color> generateRandomColors(int count) {
  return List<Color>.generate(count, (index) {
    return Color.fromARGB(
      255,
      GLOBAL.random.nextInt(256), // Red
      GLOBAL.random.nextInt(256), // Green
      GLOBAL.random.nextInt(256), // Blue
    );
  });
}

int getDifferentRandInt(int maxVal, int prevVal) {
  while (true) {
    int newVal = GLOBAL.random.nextInt(maxVal);
    if (newVal != prevVal) return newVal;
  }
}
