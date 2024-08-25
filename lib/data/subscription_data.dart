import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/models/subscription.dart';

final subscriptionTypes = [
  const Subscription(
    text1: 'MOST AFFORDABLE',
    text2: '1 Month',
    text3: 'KRW 1,900 per month',
    text4: '≈ KRW 475.00 / week only',
    lottiePath: 'assets/lottie/monthly-face.json',
    perks: [
      Perk(
          title: 'Remove All Ads',
          subtitle: 'Remove all freaking ads!',
          imgPath: 'assets/images/remove-ads-color.png',
          color: Colors.red),
      Perk(
          title: 'Unlock All Contents',
          subtitle: 'Unlock all humor contents, including detective puzzles!',
          imgPath: 'assets/images/unlock-color.png',
          color: Colors.green),
      Perk(
          title: 'Enable Bookmarks',
          subtitle: 'Enable upto 200 bookmarks',
          imgPath: 'assets/images/bookmark-color.png',
          color: Colors.blue),
      Perk(
          title: 'Higher priority',
          subtitle:
              'Higher priority to show your submitted humors on daily dose of humors!',
          imgPath: 'assets/images/submit-color.png',
          color: Colors.orange),
    ],
    color: Colors.red,
  ),
  const Subscription(
    text1: 'MOST POPULAR',
    text2: '1 Year',
    text3: 'KRW 9,900 per year',
    text4: '≈ KRW 190.38 / week only',
    lottiePath: 'assets/lottie/yearly-face.json',
    perks: [
      Perk(
          title: 'Remove All Ads',
          subtitle: 'Remove all freaking ads!',
          imgPath: 'assets/images/remove-ads-color.png',
          color: Colors.red),
      Perk(
          title: 'Unlock All Contents',
          subtitle: 'Unlock all humor contents, including detective puzzles!',
          imgPath: 'assets/images/unlock-color.png',
          color: Colors.green),
      Perk(
          title: 'Enable Bookmarks',
          subtitle: 'Enable upto 200 bookmarks',
          imgPath: 'assets/images/bookmark-color.png',
          color: Colors.blue),
      Perk(
          title: 'Higher priority',
          subtitle:
              'Higher priority to show your submitted humors on daily dose of humors!',
          imgPath: 'assets/images/submit-color.png',
          color: Colors.orange),
    ],
    color: Colors.green,
  ),
  const Subscription(
    text1: 'BEST VALUE',
    text2: 'Lifetime',
    text3: 'KRW 49,900 (one-time payment)',
    text4: '≈ KRW 60.38 / week only\n(Based on 3 years)',
    lottiePath: 'assets/lottie/lifetime-face.json',
    perks: [
      Perk(
          title: 'Remove All Ads',
          subtitle: 'Remove all freaking ads!',
          imgPath: 'assets/images/remove-ads-color.png',
          color: Colors.red),
      Perk(
          title: 'Unlock All Contents',
          subtitle: 'Unlock all humor contents, including detective puzzles!',
          imgPath: 'assets/images/unlock-color.png',
          color: Colors.green),
      Perk(
          title: 'Enable Bookmarks',
          subtitle: 'Enable upto 200 bookmarks',
          imgPath: 'assets/images/bookmark-color.png',
          color: Colors.blue),
      Perk(
          title: 'Higher priority',
          subtitle:
              'Higher priority to show your submitted humors on daily dose of humors!',
          imgPath: 'assets/images/submit-color.png',
          color: Colors.orange),
    ],
    color: Colors.blue,
  ),
];
