import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/models/category.dart';

const humorCategoryList = [
  Category(
    title: 'Dad Jokes',
    imgPath: 'assets/images/moustache.png',
    description: 'Simple, pun-filled, and often groan-inducing humor.',
    numDailyNew: 10,
    subscriberOnly: true,
    themeColor: Colors.blue,
  ),
  Category(
    title: 'Knock-Knock Series',
    imgPath: 'assets/images/fist.png',
    description:
        'Interactive and pun-based humor, often silly and family-friendly.',
    numDailyNew: 5,
    subscriberOnly: true,
    themeColor: Colors.red,
  ),
  Category(
    title: 'One-Liners',
    imgPath: 'assets/images/one-line-icon.png',
    description:
        'Brief, witty, and punchy humor, delivering a quick and impactful punchline.',
    numDailyNew: 7,
    subscriberOnly: true,
    themeColor: Colors.green,
  ),
  Category(
    title: 'Dark Humors',
    imgPath: 'assets/images/mask.png',
    description: 'Simple, pun-filled, and often groan-inducing humor.',
    numDailyNew: 7,
    subscriberOnly: true,
    themeColor: Colors.grey,
  ),
  Category(
    title: 'Tricky Riddles',
    imgPath: 'assets/images/knot.png',
    description:
        'An enigmatic quiz, often with a clever twist or double meaning',
    numDailyNew: 7,
    subscriberOnly: true,
    themeColor: Colors.yellow,
  ),
  Category(
    title: 'Fun Facts',
    imgPath: 'assets/images/light-bulb.png',
    description: 'Interesting trivia, often surprising and amusing.',
    numDailyNew: 7,
    subscriberOnly: true,
    themeColor: Colors.cyan,
  ),
  Category(
    title: 'Funny Quotes',
    imgPath: 'assets/images/quotation.png',
    description: 'Witty sayings, often hilarious and clever.',
    numDailyNew: 7,
    subscriberOnly: true,
    themeColor: Colors.orange,
  ),
  Category(
    title: 'Story Jokes',
    imgPath: 'assets/images/open-book.png',
    description: 'Extended anecdotes with a clever and surprising punchline.',
    numDailyNew: 7,
    subscriberOnly: true,
    themeColor: Colors.brown,
  ),
  Category(
    title: 'Detective Puzzles',
    imgPath: 'assets/images/detective.png',
    description:
        'Mystery challenges requiring keen observation and logical deduction.',
    numDailyNew: 7,
    subscriberOnly: true,
    themeColor: Colors.indigo,
  ),
];
