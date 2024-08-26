import 'package:flutter/material.dart';

// No subscription -> null
class Subscription {
  /* descriptive info */
  final String subscriptionName;
  final String text1;
  final String text2;
  final String text3;
  final String text4;
  final String lottiePath;
  final List<Perk> perks;
  final Color color;
  /* valuewise info */
  final int maxBookmarks;

  const Subscription({
    required this.subscriptionName,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.text4,
    required this.lottiePath,
    required this.perks,
    required this.color,
    required this.maxBookmarks,
  });
}

class Perk {
  final String title;
  final String subtitle;
  final String imgPath;
  final Color color;
  const Perk({
    required this.title,
    required this.subtitle,
    required this.imgPath,
    required this.color,
  });
}
