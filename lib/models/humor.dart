import 'package:daily_dose_of_humors/models/category.dart';

abstract class Humor {
  final String uuid;
  final CategoryCode categoryCode;
  final String context;
  final List<String> contextList;
  final String punchline;
  final String aiAnalysis;
  final String author;
  final String sender;
  final String source;
  final String sourceName;
  final int humorIndex;

  Humor({
    required this.uuid,
    required this.categoryCode,
    required this.context,
    required this.contextList,
    required this.punchline,
    this.aiAnalysis = '',
    required this.author,
    required this.sender,
    required this.source,
    required this.sourceName,
    this.humorIndex = 0,
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

  DailyHumor({
    required super.uuid,
    required super.categoryCode,
    required super.context,
    required super.contextList,
    required super.punchline,
    required super.author,
    required super.sender,
    required super.source,
    super.aiAnalysis,
    required super.sourceName,
    this.isNew = false,
    super.humorIndex,
  });

  /// Constructor for loading humors from server
  DailyHumor.loadFromServer(
      Map<String, dynamic> document) // Construct from Firebase server
      : isNew = document['is_new'] ?? false,
        super(
          humorIndex: document['index'],
          uuid: document['uuid'],
          categoryCode: CategoryCode.values.firstWhere(
            (e) => e.name == document['category'],
            orElse: () =>
                CategoryCode.YOUR_HUMORS, // Return null if no match is found
          ),
          context: document['context'],
          contextList:
              (document['context_list'] as List<dynamic>?)?.cast<String>() ??
                  [],
          punchline: document['punchline'],
          aiAnalysis: document['ai_analysis'] ?? '',
          author: document['author'],
          sender: document['sender'],
          source: document['source'],
          sourceName: document['source_name'],
        );

  DailyHumor.loadFromTable(Map<String, dynamic> document)
      : isNew = false,
        super(
          humorIndex: document['humor_index'],
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
          aiAnalysis: document['ai_analysis'],
          author: document['author'],
          sender: document['sender'],
          source: document['source'],
          sourceName: document['source_name'],
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
      'ai_analysis': aiAnalysis,
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
    required super.contextList,
    required super.punchline,
    super.aiAnalysis,
    required super.author,
    required super.sender,
    required super.source,
    required super.sourceName,
    super.humorIndex,
  }) : bookmarkAddedDate = bookmarkAddedDate ?? DateTime.now();

  BookmarkHumor.loadFromTable(
      Map<String, dynamic> document) // Construct from Firebase server
      : bookmarkAddedDate = DateTime.parse(document['bookmark_added_date']),
        bookmarkOrd = document['bookmark_ord'],
        super(
          humorIndex: document['humor_index'],
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
          aiAnalysis: document['ai_analysis'],
          author: document['author'],
          sender: document['sender'],
          source: document['source'],
          sourceName: document['source_name'],
        );

  BookmarkHumor.convertFromDailyHumor(DailyHumor dailyHumor)
      : bookmarkAddedDate = DateTime.now(),
        bookmarkOrd = null,
        super(
          humorIndex: dailyHumor.humorIndex,
          uuid: dailyHumor.uuid,
          categoryCode: dailyHumor.categoryCode,
          context: dailyHumor.context,
          contextList: dailyHumor.contextList,
          punchline: dailyHumor.punchline,
          aiAnalysis: dailyHumor.aiAnalysis,
          author: dailyHumor.author,
          sender: dailyHumor.sender,
          source: dailyHumor.source,
          sourceName: dailyHumor.sourceName,
        );

  @override
  Map<String, dynamic> humorToMap() {
    final Map<String, dynamic> map = {
      'humor_index': humorIndex,
      'uuid': uuid,
      'bookmark_ord': bookmarkOrd, // even if this value is null, use it!
      'bookmark_added_date': bookmarkAddedDate.toIso8601String(),
      'category': categoryCode.name,
      'context': context,
      'context_list': contextList.join('@@@'),
      'punchline': punchline,
      'ai_analysis': aiAnalysis,
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
