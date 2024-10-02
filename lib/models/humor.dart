import 'package:daily_dose_of_humors/models/category.dart';

abstract class Humor {
  final String uuid;
  final CategoryCode categoryCode;
  final String context;
  final List<String> contextList;
  final String punchline;
  final String author;
  final String sender;
  final String source;

  Humor({
    required this.uuid,
    DateTime? addedDate,
    required this.categoryCode,
    required this.context,
    this.contextList = const [],
    this.punchline = '',
    this.author = '',
    required this.sender,
    required this.source,
  });

  Category getCategoryData() {
    return Category.getCategoryByCode(categoryCode);
  }

  SharedFormat? toSharedFormat() {
    switch (categoryCode) {
      case CategoryCode.DAD_JOKES:
      case CategoryCode.KNOCK_KNOCK_JOKES:
      case CategoryCode.DARK_HUMORS:
        return SharedFormat(
          option1BtnText: 'With Punchline',
          option1Format:
              '$context\n\n$punchline\n\n--From Daily Dose of Humors :)',
          option2BtnText: 'Without Punchline',
          option2Format: '$context\n\n--From Daily Dose of Humors :)',
        );
      case CategoryCode.TRICKY_RIDDLES:
      case CategoryCode.TRIVIA_QUIZ:
        return SharedFormat(
          dialogBody:
              'Would you like to share this humor with or without answer?',
          option1BtnText: 'With Answer',
          option1Format:
              '$context\n\n$punchline\n\n--From Daily Dose of Humors :)',
          option2BtnText: 'Without Answer',
          option2Format: '$context\n\n--From Daily Dose of Humors :)',
        );
      case CategoryCode.ONE_LINERS:
        return SharedFormat(
          defaultFormat: '$context\n\n--From Daily Dose of Humors :)',
        );
      case CategoryCode.FUNNY_QUOTES:
        return SharedFormat(
          defaultFormat:
              '$context\n\n-Quote from $author\n\n--From Daily Dose of Humors :)',
        );
      case CategoryCode.YOUR_HUMORS:
        return SharedFormat(
          defaultFormat: '$context\n\n--From Daily Dose of Humors :)',
        );
      default:
        return null;
    }
  }

  Map<String, dynamic> humorToMap();
}

class DailyHumor extends Humor {
  // Both daily and bundle humors
  bool isNew;
  int humorIndex;

  DailyHumor({
    required super.uuid,
    required super.categoryCode,
    required super.context,
    super.contextList,
    super.punchline,
    super.author,
    required super.sender,
    required super.source,
    this.isNew = false,
    required this.humorIndex,
  });

  /// Constructor for loading humors from server
  DailyHumor.loadFromServer(
      Map<String, dynamic> document) // Construct from Firebase server
      : isNew = document['is_new'] ?? false,
        humorIndex = document['humor_index'] ?? 0,
        super(
          uuid: document['uuid'],
          categoryCode: CategoryCode.values.firstWhere(
            (e) => e.name == document['category'],
            orElse: () =>
                CategoryCode.YOUR_HUMORS, // Return null if no match is found
          ),
          context: document['context'],
          contextList: document['context_list'].cast<String>(),
          punchline: document['punchline'],
          author: document['author'],
          sender: document['sender'],
          source: document['source'],
        );

  DailyHumor.loadFromTable(Map<String, dynamic> document)
      : isNew = false,
        humorIndex = document['humor_index'] ?? 0,
        super(
          uuid: document['uuid'],
          categoryCode: CategoryCode.values.firstWhere(
            (e) => e.name == document['category'],
            orElse: () =>
                CategoryCode.YOUR_HUMORS, // Return null if no match is found
          ),
          context: document['context'],
          contextList: document['context_list'] == ''
              ? []
              : document['context_list'].split('@@@'),
          punchline: document['punchline'],
          author: document['author'],
          sender: document['sender'],
          source: document['source'],
        );

  @override
  Map<String, dynamic> humorToMap() {
    final Map<String, dynamic> map = {
      'author': author,
      'category': categoryCode.name,
      'context': context,
      'context_list': contextList.join('@@@'),
      'humor_index': humorIndex,
      'punchline': punchline,
      'sender': sender,
      'source': source,
      'uuid': uuid,
    };
    return map;
  }
}

class BookmarkHumor extends Humor {
  int? bookmarkOrd;
  final DateTime bookmarkAddedDate;

  BookmarkHumor({
    required super.uuid,
    this.bookmarkOrd,
    DateTime? bookmarkAddedDate, // exclusive to bookmark humor
    required super.categoryCode,
    required super.context,
    super.contextList,
    super.punchline,
    super.author,
    required super.sender,
    required super.source,
  }) : bookmarkAddedDate = bookmarkAddedDate ?? DateTime.now();

  BookmarkHumor.loadFromTable(
      Map<String, dynamic> document) // Construct from Firebase server
      : bookmarkAddedDate = DateTime.parse(document['bookmark_added_date']),
        bookmarkOrd = document['bookmark_ord'],
        super(
          uuid: document['uuid'],
          categoryCode: CategoryCode.values.firstWhere(
            (e) => e.name == document['category'],
            orElse: () =>
                CategoryCode.YOUR_HUMORS, // Return null if no match is found
          ),
          context: document['context'],
          contextList: document['context_list'] == ''
              ? []
              : document['context_list'].split('@@@'),
          punchline: document['punchline'],
          author: document['author'],
          sender: document['sender'],
          source: document['source'],
        );

  BookmarkHumor.convertFromDailyHumor(DailyHumor dailyHumor)
      : bookmarkAddedDate = DateTime.now(),
        bookmarkOrd = null,
        super(
          uuid: dailyHumor.uuid,
          categoryCode: dailyHumor.categoryCode,
          context: dailyHumor.context,
          contextList: dailyHumor.contextList,
          punchline: dailyHumor.punchline,
          sender: dailyHumor.sender,
          source: dailyHumor.source,
        );

  @override
  Map<String, dynamic> humorToMap() {
    final Map<String, dynamic> map = {
      'uuid': uuid,
      'bookmark_ord': bookmarkOrd, // even if this value is null, use it!
      'bookmark_added_date': bookmarkAddedDate.toIso8601String(),
      'category': categoryCode.name,
      'context': context,
      'context_list': contextList.join('@@@'),
      'punchline': punchline,
      'author': author,
      'sender': sender,
      'source': source,
    };
    return map;
  }
}

class SharedFormat {
  final String dialogSubject;
  final String dialogBody;
  final String? defaultFormat;
  final String? option1BtnText;
  final String? option1Format;
  final String? option2BtnText;
  final String? option2Format;

  const SharedFormat({
    this.dialogSubject = 'You\'re almost there!',
    this.dialogBody =
        'Would you like to share this humor with or without punchline?',
    this.defaultFormat,
    this.option1BtnText,
    this.option1Format,
    this.option2BtnText,
    this.option2Format,
  });
}
