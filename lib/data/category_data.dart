import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/models/manual.dart';

const humorCategoryList = [
  Category(
    title: 'Dad Jokes',
    lottiePath: 'assets/lottie/card-lottie/dad-jokes.json',
    lottiePointInTime: 1.0,
    imgSize: 200,
    animDuration: 2200,
    description: 'Simple, pun-filled, and often groan-inducing humor.',
    numDailyNew: 10,
    subscriberOnly: false,
    themeColor: Color.fromARGB(255, 61, 171, 255),
    themeColor2: Color.fromARGB(255, 207, 229, 255),
    categoryCode: CategoryCode.DAD_JOKES,
  ),
  Category(
    title: 'Knock-Knock Jokes',
    lottiePath: 'assets/lottie/card-lottie/knock-knock-jokes.json',
    lottiePointInTime: 0.25,
    imgSize: 200,
    animDuration: 1300,
    description:
        'Interactive and pun-based humor, often silly and family-friendly.',
    numDailyNew: 5,
    subscriberOnly: false,
    themeColor: Color.fromARGB(255, 255, 76, 91),
    themeColor2: Color.fromARGB(255, 255, 227, 227),
    categoryCode: CategoryCode.KNOCK_KNOCK_JOKES,
  ),
  Category(
      title: 'One-Liners',
      lottiePath: 'assets/lottie/card-lottie/one-liners.json',
      lottiePointInTime: 1.0,
      imgSize: 200,
      animDuration: 1500,
      description:
          'Brief, witty, and punchy humor, delivering a quick and impactful punchline.',
      numDailyNew: 7,
      subscriberOnly: false,
      themeColor: Color.fromARGB(255, 115, 216, 119),
      themeColor2: Color.fromARGB(255, 225, 242, 225),
      categoryCode: CategoryCode.ONE_LINERS,
      manualList: [
        ManualItem(
          lottiePath: 'assets/lottie/swipe-right.json',
          text: 'Swipe to view next jokes.',
        ),
      ]),
  Category(
    title: 'Dark Humors',
    lottiePath: 'assets/lottie/card-lottie/dark-humors.json',
    lottiePointInTime: 1.0,
    imgSize: 200,
    animDuration: 2000,
    description: 'Simple, pun-filled, and often groan-inducing humor.',
    numDailyNew: 7,
    subscriberOnly: false,
    themeColor: Color.fromARGB(255, 186, 186, 186),
    themeColor2: Color.fromARGB(255, 234, 234, 234),
    categoryCode: CategoryCode.DARK_HUMORS,
  ),
  Category(
    title: 'Tricky Riddles',
    lottiePath: 'assets/lottie/card-lottie/tricky-riddles.json',
    lottiePointInTime: 1.0,
    imgSize: 300,
    animDuration: 1600,
    description:
        'An enigmatic quiz, often with a clever twist or double meaning',
    numDailyNew: 7,
    subscriberOnly: false,
    themeColor: Color.fromARGB(255, 255, 239, 96),
    themeColor2: Color.fromARGB(255, 255, 248, 188),
    categoryCode: CategoryCode.TRICKY_RIDDLES,
    manualList: [
      ManualItem(
          lottiePath: 'assets/lottie/swipe-right.json',
          text: 'Swipe to view next riddles.'),
      ManualItem(
          lottiePath: 'assets/lottie/double-tap.json',
          text: 'Double-tap to view the answer.'),
    ],
  ),
  Category(
    title: 'Trivia Quiz',
    lottiePath: 'assets/lottie/card-lottie/ox-quiz.json',
    lottiePointInTime: 0.6,
    imgSize: 200,
    animDuration: 1100,
    description: 'Quiz of interesting trivia, often surprising and amusing.',
    numDailyNew: 7,
    subscriberOnly: false,
    themeColor: Color.fromARGB(255, 57, 199, 218),
    themeColor2: Color.fromARGB(255, 198, 230, 234),
    categoryCode: CategoryCode.TRIVIA_QUIZ,
    manualList: [
      ManualItem(
          lottiePath: 'assets/lottie/swipe-right.json',
          text: 'Swipe to view next quizes.'),
      ManualItem(
          lottiePath: 'assets/lottie/double-tap.json',
          text: 'Double-tap to view the answer.'),
    ],
  ),
  Category(
    title: 'Funny Quotes',
    lottiePath: 'assets/lottie/card-lottie/funny-quotes.json',
    lottiePointInTime: 1.0,
    imgSize: 200,
    animDuration: 1100,
    description: 'Witty sayings, often hilarious and clever.',
    numDailyNew: 7,
    subscriberOnly: false,
    themeColor: Color.fromARGB(255, 255, 177, 60),
    themeColor2: Color.fromARGB(255, 255, 230, 192),
    categoryCode: CategoryCode.FUNNY_QUOTES,
    manualList: [
      ManualItem(
          lottiePath: 'assets/lottie/swipe-right.json',
          text: 'Swipe to view next quotes.'),
    ],
  ),
  Category(
    title: 'Story Jokes',
    lottiePath: 'assets/lottie/card-lottie/story-jokes.json',
    lottiePointInTime: 1.0,
    imgSize: 200,
    animDuration: 1700,
    description: 'Extended anecdotes with a clever and surprising punchline.',
    numDailyNew: 7,
    subscriberOnly: true,
    themeColor: Color.fromARGB(255, 166, 127, 112),
    themeColor2: Color.fromARGB(255, 213, 193, 185),
    categoryCode: CategoryCode.STORY_JOKES,
  ),
  Category(
    title: 'Mystery Puzzles',
    lottiePath: 'assets/lottie/card-lottie/detective-puzzles.json',
    lottiePointInTime: 0.7,
    imgSize: 200,
    animDuration: 2000,
    description:
        'Mystery challenges requiring keen observation and logical deduction.',
    numDailyNew: 7,
    subscriberOnly: true,
    themeColor: Color.fromARGB(255, 123, 137, 218),
    categoryCode: CategoryCode.MYSTERY_PUZZLES,
    manualList: [
      ManualItem(
          lottiePath: 'assets/lottie/swipe-right.json',
          text: 'Swipe to view next puzzles.'),
      ManualItem(
          lottiePath: 'assets/lottie/tap.json', text: 'Tap to view each clue.'),
      ManualItem(
          lottiePath: 'assets/lottie/double-tap.json',
          text: 'Double-tap to find the answer.'),
      ManualItem(
          lottiePath: 'assets/lottie/double-tap.json',
          text: 'Double-tap to find the answer.'),
    ],
  ),
  Category(
    title: 'Your Humors',
    lottiePath: 'assets/lottie/card-lottie/detective-puzzles.json',
    lottiePointInTime: 0.7,
    description: 'Awesome humors created by you!',
    numDailyNew: 0,
    themeColor: Color.fromARGB(255, 123, 218, 202),
    categoryCode: CategoryCode.YOUR_HUMORS,
    isDaily: false,
  ),
];
