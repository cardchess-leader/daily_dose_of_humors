import 'package:daily_dose_of_humors/models/category.dart';

/// Abstract base class for Humor
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
  final String imgUrl;

  const Humor({
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
    this.imgUrl = '',
  });

  /// Retrieves the associated [Category] based on [categoryCode].
  Category getCategoryData() {
    return Category.getCategoryByCode(categoryCode);
  }

  /// Generates a sharing format for the humor based on its category.
  SharedFormat? toSharedFormat() {
    switch (categoryCode) {
      case CategoryCode.DAD_JOKES:
      case CategoryCode.DIALOG_JOKES:
      case CategoryCode.DARK_HUMORS:
      case CategoryCode.KNOCK_KNOCK_JOKES:
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

  /// Converts humor to a map for database or serialization.
  Map<String, dynamic> humorToMap();
}

/// Class for daily humor
class DailyHumor extends Humor {
  final bool isNew;

  DailyHumor({
    required super.uuid,
    required super.categoryCode,
    required super.context,
    required super.contextList,
    required super.punchline,
    required super.author,
    required super.sender,
    required super.source,
    required super.sourceName,
    this.isNew = false,
    super.humorIndex,
    super.imgUrl,
    super.aiAnalysis,
  });

  /// Creates a [DailyHumor] from server data.
  factory DailyHumor.loadFromServer(Map<String, dynamic> document) {
    return DailyHumor(
      uuid: document['uuid'] ?? '',
      categoryCode: _parseCategoryCode(document['category']),
      context: document['context'] ?? '',
      contextList:
          (document['context_list'] as List<dynamic>?)?.cast<String>() ?? [],
      punchline: document['punchline'] ?? '',
      imgUrl: document['img_url'] ?? '',
      aiAnalysis: document['ai_analysis'] ?? '',
      author: document['author'] ?? 'Anonymous',
      sender: document['sender'] ?? '',
      source: document['source'] ?? '',
      sourceName: document['source_name'] ?? '',
      humorIndex: document['index'] ?? 0,
      isNew: document['is_new'] ?? false,
    );
  }

  /// Creates a [DailyHumor] from a database table row.
  factory DailyHumor.loadFromTable(Map<String, dynamic> document) {
    return DailyHumor(
      uuid: document['uuid'],
      categoryCode: _parseCategoryCode(document['category']),
      context: document['context'] ?? '',
      contextList: document['context_list'] == ''
          ? []
          : document['context_list'].split('@@@'),
      punchline: document['punchline'] ?? '',
      imgUrl: document['img_url'] ?? '',
      aiAnalysis: document['ai_analysis'] ?? '',
      author: document['author'] ?? 'Anonymous',
      sender: document['sender'] ?? '',
      source: document['source'] ?? '',
      sourceName: document['source_name'] ?? '',
      humorIndex: document['humor_index'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> humorToMap() {
    return {
      'uuid': uuid,
      'category': categoryCode.name,
      'context': context,
      'context_list': contextList.join('@@@'),
      'humor_index': humorIndex,
      'punchline': punchline,
      'ai_analysis': aiAnalysis,
      'author': author,
      'sender': sender,
      'source': source,
      'img_url': imgUrl,
    };
  }
}

/// Class for bookmarked humor
class BookmarkHumor extends Humor {
  int? bookmarkOrd;
  final DateTime bookmarkAddedDate;

  BookmarkHumor({
    required super.uuid,
    this.bookmarkOrd,
    DateTime? bookmarkAddedDate,
    required super.categoryCode,
    required super.context,
    required super.contextList,
    required super.punchline,
    required super.author,
    required super.sender,
    required super.source,
    required super.sourceName,
    super.humorIndex,
    super.imgUrl,
    super.aiAnalysis,
  }) : bookmarkAddedDate = bookmarkAddedDate ?? DateTime.now();

  /// Creates a [BookmarkHumor] from a database table row.
  factory BookmarkHumor.loadFromTable(Map<String, dynamic> document) {
    return BookmarkHumor(
      uuid: document['uuid'],
      bookmarkOrd: document['bookmark_ord'],
      bookmarkAddedDate: DateTime.parse(document['bookmark_added_date']),
      categoryCode: _parseCategoryCode(document['category']),
      context: document['context'] ?? '',
      contextList: document['context_list'] == ''
          ? []
          : document['context_list'].split('@@@'),
      punchline: document['punchline'] ?? '',
      imgUrl: document['img_url'] ?? '',
      aiAnalysis: document['ai_analysis'] ?? '',
      author: document['author'] ?? 'Anonymous',
      sender: document['sender'] ?? '',
      source: document['source'] ?? '',
      sourceName: document['source_name'] ?? '',
      humorIndex: document['humor_index'] ?? 0,
    );
  }

  /// Converts [DailyHumor] to [BookmarkHumor].
  factory BookmarkHumor.convertFromDailyHumor(DailyHumor dailyHumor) {
    return BookmarkHumor(
      uuid: dailyHumor.uuid,
      categoryCode: dailyHumor.categoryCode,
      context: dailyHumor.context,
      contextList: dailyHumor.contextList,
      punchline: dailyHumor.punchline,
      imgUrl: dailyHumor.imgUrl,
      aiAnalysis: dailyHumor.aiAnalysis,
      author: dailyHumor.author,
      sender: dailyHumor.sender,
      source: dailyHumor.source,
      sourceName: dailyHumor.sourceName,
      bookmarkAddedDate: DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> humorToMap() {
    return {
      'uuid': uuid,
      'bookmark_ord': bookmarkOrd,
      'bookmark_added_date': bookmarkAddedDate.toIso8601String(),
      'category': categoryCode.name,
      'context': context,
      'context_list': contextList.join('@@@'),
      'punchline': punchline,
      'ai_analysis': aiAnalysis,
      'author': author,
      'sender': sender,
      'source': source,
      'img_url': imgUrl,
    };
  }
}

/// Utility to parse [CategoryCode] safely.
CategoryCode _parseCategoryCode(dynamic category) {
  if (category is String) {
    return CategoryCode.values.firstWhere(
      (e) => e.name == category,
      orElse: () => CategoryCode.YOUR_HUMORS,
    );
  }
  return CategoryCode.YOUR_HUMORS;
}

/// Format class for sharing humor
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
