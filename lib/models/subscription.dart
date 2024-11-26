import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/data/subscription_data.dart';

enum SubscriptionCode {
  FREE,
  MONTHLY,
  YEARLY,
  LIFETIME,
}

/// Represents a subscription plan.
class Subscription {
  final SubscriptionCode subscriptionCode;
  final String subscriptionName;
  final String? productId; // Null if no product ID is associated
  final String text1;
  final String text2;
  final String text3;
  final String text4;
  final String lottiePath;
  final List<Perk> perks;
  final Color color;
  final int maxBookmarks;

  const Subscription({
    required this.subscriptionCode,
    required this.subscriptionName,
    this.productId,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.text4,
    required this.lottiePath,
    required this.perks,
    required this.color,
    required this.maxBookmarks,
  });

  /// Retrieves a [Subscription] by its [SubscriptionCode].
  static Subscription getSubscriptionByCode(SubscriptionCode code) {
    try {
      return subscriptionTypes.firstWhere(
        (subscription) => subscription.subscriptionCode == code,
      );
    } catch (e) {
      print('Error retrieving subscription for code $code: $e');
      return freeSubscription; // Fallback to FREE subscription
    }
  }
}

/// Represents a subscription perk.
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
