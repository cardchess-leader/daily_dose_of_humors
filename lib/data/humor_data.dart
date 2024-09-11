import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/models/humor.dart';

final todayHumorList = [
  DailyHumor(
    uuid: '7cd0636c-17ee-47a4-a966-72bf0fd8b2a8',
    categoryCode: CategoryCode.DAD_JOKES,
    context: 'Can a frog jump higher than a house?',
    punchline: 'Of course, a house can\'t jump.',
    sender: 'Board Collie',
    source: 'Daily Dose of Humors',
    createdDate: DateTime.now(),
  ),
  DailyHumor(
    uuid: '8b82fbd8-20b5-4a7f-9e2c-75b6fc3f5dab',
    categoryCode: CategoryCode.DAD_JOKES,
    context:
        'Dad: What is the difference between a piano, a tuna, and a pot of glue?\n\nMe: I don\'t know.\n\nDad: You can tuna piano but you can\'t piano a tuna.\n\nMe: What about the pot of glue?',
    punchline: 'Dad: I knew you\'d get stuck on that.',
    sender: 'Board Collie',
    source: 'Daily Dose of Humors',
    createdDate: DateTime.now(),
  ),
  DailyHumor(
    uuid: '767a1c3d-9e33-423c-928f-ceab408ee144',
    categoryCode: CategoryCode.KNOCK_KNOCK_JOKES,
    context: 'hello, world!',
    contextList: [
      'what is your name?',
      'what does the fox say?',
      'hola mi amigo, como estas?',
    ],
    // punchline: 'Punch Punch Babe.',
    sender: 'Board Collie',
    source: 'Daily Dose of Humors',
    createdDate: DateTime.now(),
  ),
];
