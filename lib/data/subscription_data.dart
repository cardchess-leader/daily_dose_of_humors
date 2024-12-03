import 'dart:io';
import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/models/subscription.dart';
import 'package:daily_dose_of_humors/util/global_var.dart';

const _removeAdsPerk = Perk(
  title: 'Remove All Ads',
  subtitle: 'Remove all annoying ads that are distracting you!',
  imgPath: 'assets/images/remove-ads-color.png',
  color: Colors.red,
);

const _unlockContentsPerk = Perk(
  title: 'Unlock All Daily Contents',
  subtitle: 'Unlock all subscriber-only daily contents!',
  imgPath: 'assets/images/unlock-color.png',
  color: Colors.green,
);

const _aiHumorAnalysis = Perk(
    title: 'AI Humor Analysis',
    subtitle: 'You don\'t get why it\'s funny? AI bot will explain it to you!',
    imgPath: 'assets/images/humor-bot-color.png',
    color: Colors.purple);

const freeSubscription = Subscription(
  subscriptionCode: SubscriptionCode.FREE,
  subscriptionName: 'Free',
  text1: '',
  text2: '',
  text3: '',
  text4: '',
  lottiePath: 'assets/lottie/monthly-face.json',
  maxBookmarks: 5,
  perks: [],
  color: Colors.amberAccent,
);

final monthlySubscription = Subscription(
  subscriptionCode: SubscriptionCode.MONTHLY,
  subscriptionName: 'Monthly',
  productId:
      Platform.isAndroid ? 'subscription:monthly' : 'subscription_monthly',
  text1: 'MOST AFFORDABLE',
  text2: '1 Month',
  text3: 'per month',
  text4: 'Renews every month!',
  lottiePath: 'assets/lottie/monthly-face.json',
  maxBookmarks: 200,
  perks: [
    _removeAdsPerk,
    _unlockContentsPerk,
    Perk(
      title: 'More Bookmarks',
      subtitle: 'Save upto 200 bookmarks', // match this with actual
      imgPath: 'assets/images/bookmark-color.png',
      color: Colors.blue,
    ),
    _aiHumorAnalysis,
    Perk(
      title: 'Higher priority',
      subtitle: 'High priority to show your submitted humors!',
      imgPath: 'assets/images/submit-color.png',
      color: Colors.orange,
    ),
  ],
  color: Colors.red,
);

final yearlySubscription = Subscription(
  subscriptionCode: SubscriptionCode.YEARLY,
  subscriptionName: 'Yearly',
  productId: Platform.isAndroid ? 'subscription:yearly' : 'subscription_yearly',
  text1: 'MOST POPULAR',
  text2: '1 Year',
  text3: 'per year',
  text4: 'Renews every year!',
  lottiePath: 'assets/lottie/yearly-face.json',
  perks: [
    _removeAdsPerk,
    _unlockContentsPerk,
    Perk(
      title: 'Enable Bookmarks',
      subtitle: 'Enable upto 500 bookmarks',
      imgPath: 'assets/images/bookmark-color.png',
      color: Colors.blue,
    ),
    _aiHumorAnalysis,
    Perk(
      title: 'Higher priority',
      subtitle: 'Higher priority to show your submitted humors!',
      imgPath: 'assets/images/submit-color.png',
      color: Colors.orange,
    ),
  ],
  color: Colors.green,
  maxBookmarks: 500,
);

const lifetimeSubscription = Subscription(
  subscriptionCode: SubscriptionCode.LIFETIME,
  subscriptionName: 'Lifetime',
  productId: 'subscription_lifetime',
  text1: 'BEST VALUE',
  text2: 'Lifetime',
  text3: 'only',
  text4: 'Pay once, enjoy forever!',
  lottiePath: 'assets/lottie/lifetime-face.json',
  perks: [
    _removeAdsPerk,
    _unlockContentsPerk,
    Perk(
      title: 'Enable Bookmarks',
      subtitle: 'You can add unlimited number of bookmarks!',
      imgPath: 'assets/images/bookmark-color.png',
      color: Colors.blue,
    ),
    _aiHumorAnalysis,
    Perk(
      title: 'Highest priority',
      subtitle: 'Highest priority to show your submitted humors!',
      imgPath: 'assets/images/submit-color.png',
      color: Colors.orange,
    ),
  ],
  color: Colors.blue,
  maxBookmarks: GLOBAL.SMALL_MAX_INT,
);

final subscriptionTypes = [
  monthlySubscription,
  yearlySubscription,
  lifetimeSubscription,
];
