import 'package:flutter/material.dart';

class Subscription {
  final String text1;
  final String text2;
  final String text3;
  final String text4;
  final String lottiePath;
  final List<Perk> perks;
  final Color color;

  const Subscription({
    required this.text1,
    required this.text2,
    required this.text3,
    required this.text4,
    required this.lottiePath,
    required this.perks,
    required this.color,
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
