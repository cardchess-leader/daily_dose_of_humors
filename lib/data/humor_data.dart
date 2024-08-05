import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/models/humor.dart';

final todayHumorList = [
  Humor(
    id: 100,
    categoryCode: CategoryCode.DAD_JOKES,
    context: 'Can a frog jump higher than a house?',
    punchline: 'Of course, a house can\'t jump.1231 23123',
  ),
  Humor(
    id: 101,
    categoryCode: CategoryCode.DAD_JOKES,
    context:
        'Dad: What is the difference between a piano, a tuna, and a pot of glue?\n\nMe: I don\'t know.\n\nDad: You can tuna piano but you can\'t piano a tuna.\n\nMe: What about the pot of glue?',
    punchline: 'Dad: I knew you\'d get stuck on that.',
  ),
  Humor(
    id: 102,
    categoryCode: CategoryCode.KNOCK_KNOCK_JOKES,
    context:
        'Dad: What is the difference between a piano, a tuna, and a pot of glue?\n\nMe: I don\'t know.\n\nDad: You can tuna piano but you can\'t piano a tuna.\n\nMe: What about the pot of glue?',
    contextList: [
      'hello, world!',
      'what is your name?',
      'what does the fox say?',
      'hola mi amigo, como estas?',
    ],
    punchline: 'Dad: I knew you\'d get stuck on that.',
  ),
];
