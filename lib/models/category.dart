import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/data/category_data.dart';
import 'package:daily_dose_of_humors/models/manual.dart';

enum CategoryCode {
  DAD_JOKES,
  KNOCK_KNOCK_JOKES,
  ONE_LINERS,
  DARK_HUMORS,
  TRICKY_RIDDLES,
  OX_QUIZ,
  FUNNY_QUOTES,
  STORY_JOKES,
  DETECTIVE_PUZZLES,
  YOUR_HUMORS,
}

class Category {
  final String title;
  final String description;
  final String imgPath;
  final double imgSize;
  final int animDuration;
  final int numDailyNew;
  final bool subscriberOnly;
  final bool isDaily;
  final Color themeColor;
  final Color themeColor2;
  final CategoryCode categoryCode;
  final List<ManualItem> manualList;

  // final List<Color> themeColorGradient;
  const Category({
    required this.title,
    required this.description,
    required this.imgPath,
    this.imgSize = 200,
    this.animDuration = 1000,
    required this.numDailyNew,
    this.subscriberOnly = false,
    this.isDaily = true,
    required this.themeColor,
    this.themeColor2 = Colors.white,
    // required this.themeColorGradient,
    required this.categoryCode,
    this.manualList = const [
      ManualItem(
          lottiePath: 'assets/lottie/swipe-right.json',
          text: 'Swipe to view next jokes.'),
      ManualItem(
          lottiePath: 'assets/lottie/double-tap.json',
          text: 'Double-tap to view the punchline.'),
    ],
  });

  static Category getCategoryByCode(CategoryCode code) {
    return humorCategoryList.firstWhere(
      (category) => category.categoryCode == code,
      orElse: () => humorCategoryList[0],
    );
  }

  static List<Category> getDailyCategories() {
    return humorCategoryList.where((category) => category.isDaily).toList();
  }
}
