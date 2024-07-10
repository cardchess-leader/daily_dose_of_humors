import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/models/category.dart';

const humorCategoryList = [
  Category(
    title: 'Dad Jokes',
    imgPath: 'assets/images/moustache.png',
    description: 'Simple, pun-filled, and often groan-inducing humor.',
    numDailyNew: 10,
    subscriberOnly: true,
    themeColor: Color.fromARGB(255, 61, 171, 255),
  ),
  Category(
    title: 'Knock-Knock Series',
    imgPath: 'assets/images/fist.png',
    description:
        'Interactive and pun-based humor, often silly and family-friendly.',
    numDailyNew: 5,
    subscriberOnly: true,
    themeColor: Color.fromARGB(255, 255, 88, 76),
  ),
  Category(
    title: 'One-Liners',
    imgPath: 'assets/images/one-line-icon.png',
    description:
        'Brief, witty, and punchy humor, delivering a quick and impactful punchline.',
    numDailyNew: 7,
    subscriberOnly: true,
    themeColor: Color.fromARGB(255, 115, 216, 119),
  ),
  Category(
    title: 'Dark Humors',
    imgPath: 'assets/images/mask.png',
    description: 'Simple, pun-filled, and often groan-inducing humor.',
    numDailyNew: 7,
    subscriberOnly: true,
    themeColor: Color.fromARGB(255, 186, 186, 186),
  ),
  Category(
    title: 'Tricky Riddles',
    imgPath: 'assets/images/knot.png',
    description:
        'An enigmatic quiz, often with a clever twist or double meaning',
    numDailyNew: 7,
    subscriberOnly: true,
    themeColor: Color.fromARGB(255, 255, 239, 96),
  ),
  Category(
    title: 'Fun Facts',
    imgPath: 'assets/images/light-bulb.png',
    description: 'Interesting trivia, often surprising and amusing.',
    numDailyNew: 7,
    subscriberOnly: true,
    themeColor: Color.fromARGB(255, 57, 199, 218),
  ),
  Category(
    title: 'Funny Quotes',
    imgPath: 'assets/images/quotation.png',
    description: 'Witty sayings, often hilarious and clever.',
    numDailyNew: 7,
    subscriberOnly: true,
    themeColor: Color.fromARGB(255, 255, 177, 60),
  ),
  Category(
    title: 'Story Jokes',
    imgPath: 'assets/images/open-book.png',
    description: 'Extended anecdotes with a clever and surprising punchline.',
    numDailyNew: 7,
    subscriberOnly: true,
    themeColor: Color.fromARGB(255, 166, 127, 112),
  ),
  Category(
    title: 'Detective Puzzles',
    imgPath: 'assets/images/detective.png',
    description:
        'Mystery challenges requiring keen observation and logical deduction.',
    numDailyNew: 7,
    subscriberOnly: true,
    themeColor: Color.fromARGB(255, 123, 137, 218),
  ),
];
