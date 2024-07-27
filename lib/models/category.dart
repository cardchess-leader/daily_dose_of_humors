import 'package:flutter/material.dart';

class Category {
  final String title;
  final String description;
  final String imgPath;
  final int numDailyNew;
  final bool subscriberOnly;
  final Color themeColor;
  final Color themeColor2;
  // final List<Color> themeColorGradient;
  const Category({
    required this.title,
    required this.description,
    required this.imgPath,
    required this.numDailyNew,
    this.subscriberOnly = false,
    required this.themeColor,
    this.themeColor2 = Colors.white,
    // required this.themeColorGradient,
  });
}
