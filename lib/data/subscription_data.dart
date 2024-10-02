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
  subtitle:
      'Unlock all subscriber-only daily contents, including detective puzzles!',
  imgPath: 'assets/images/unlock-color.png',
  color: Colors.green,
);

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

const monthlySubscription = Subscription(
  subscriptionCode: SubscriptionCode.MONTHLY,
  subscriptionName: 'Monthly',
  text1: 'MOST AFFORDABLE',
  text2: '1 Month',
  text3: 'KRW 1,900 per month',
  text4: '≈ KRW 475.00 / week only',
  lottiePath: 'assets/lottie/monthly-face.json',
  maxBookmarks: 0,
  perks: [
    _removeAdsPerk,
    _unlockContentsPerk,
    Perk(
      title: 'Enable Bookmarks',
      subtitle: 'Enable upto 200 bookmarks', // match this with actual
      imgPath: 'assets/images/bookmark-color.png',
      color: Colors.blue,
    ),
    Perk(
      title: 'Higher priority',
      subtitle:
          'High priority to show your submitted humors on daily dose of humors!',
      imgPath: 'assets/images/submit-color.png',
      color: Colors.orange,
    ),
  ],
  color: Colors.red,
);

const yearlySubscription = Subscription(
  subscriptionCode: SubscriptionCode.YEARLY,
  subscriptionName: 'Yearly',
  text1: 'MOST POPULAR',
  text2: '1 Year',
  text3: 'KRW 9,900 per year',
  text4: '≈ KRW 190.38 / week only',
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
    Perk(
      title: 'Higher priority',
      subtitle:
          'Higher priority to show your submitted humors on daily dose of humors!',
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
  text1: 'BEST VALUE',
  text2: 'Lifetime',
  text3: 'KRW 39,900 only',
  text4: 'One-time payment only',
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
    Perk(
      title: 'Highest priority',
      subtitle:
          'Highest priority to show your submitted humors on daily dose of humors!',
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
