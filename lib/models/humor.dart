import 'package:daily_dose_of_humors/models/category.dart';

abstract class Humor {
  final String uuid;
  final CategoryCode categoryCode;
  final String context;
  final List<String>? contextList;
  final String? punchline;
  final String? author;
  final String sender;
  final String source;

  Humor({
    required this.uuid,
    DateTime? addedDate,
    required this.categoryCode,
    required this.context,
    this.contextList,
    this.punchline,
    this.author,
    required this.sender,
    required this.source,
  });

  Humor.fromDocument(Map<String, dynamic> document)
      : uuid = document['uuid'],
        categoryCode = CategoryCode.values.firstWhere(
          (e) => e.name == document['category'],
          orElse: () =>
              CategoryCode.YOUR_HUMORS, // Return null if no match is found
        ),
        context = document['context'],
        contextList = document['context_list']?.split('@@@'),
        punchline = document['punchline'],
        author = document['author'],
        sender = document['sender'],
        source = document['source'];

  Category getCategoryData() {
    return Category.getCategoryByCode(categoryCode);
  }

  Map<String, dynamic> humorToMap();
}

class DailyHumor extends Humor {
  final DateTime createdDate;
  int thumbsUpCount;
  bool isNew;

  DailyHumor({
    required super.uuid,
    DateTime? createdDate, // exclusive to daily humor
    required super.categoryCode,
    required super.context,
    super.contextList,
    super.punchline,
    super.author,
    required super.sender,
    required super.source,
    this.thumbsUpCount = 0, // exclusive to daily humor
    this.isNew = false,
  }) : createdDate = createdDate ?? DateTime.now();

  DailyHumor.fromDocument(
      Map<String, dynamic> document) // Construct from Firebase server
      : createdDate = DateTime.parse(document['created_date']),
        thumbsUpCount = document['thumbs_up_count'] ?? 0,
        isNew = document['is_new'] ?? false,
        super(
          uuid: document['uuid'],
          categoryCode: CategoryCode.values.firstWhere(
            (e) => e.name == document['category'],
            orElse: () =>
                CategoryCode.YOUR_HUMORS, // Return null if no match is found
          ),
          context: document['context'],
          contextList: document['context_list']?.split('@@@'),
          punchline: document['punchline'],
          author: document['author'],
          sender: document['sender'],
          source: document['source'],
        );

  @override
  Map<String, dynamic> humorToMap() {
    final Map<String, dynamic> map = {
      'uuid': uuid,
      'category': categoryCode.name,
      'context': context,
      'context_list': contextList?.join('@@@'),
      'punchline': punchline,
      'source': source,
      'author': author,
      'sender': sender,
    };
    return map;
  }
}

class BookmarkHumor extends Humor {
  int? bookmarkOrd;
  final DateTime bookmarkAddedDate;
  int bookmarkEmojiIndex;

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
    this.bookmarkEmojiIndex = 0,
  }) : bookmarkAddedDate = bookmarkAddedDate ?? DateTime.now();

  BookmarkHumor.fromDocument(
      Map<String, dynamic> document) // Construct from Firebase server
      : bookmarkAddedDate = DateTime.parse(document['bookmark_added_date']),
        bookmarkOrd = document['bookmark_ord'],
        bookmarkEmojiIndex = document['bookmark_emoji_index'],
        super(
          uuid: document['uuid'],
          categoryCode: CategoryCode.values.firstWhere(
            (e) => e.name == document['category'],
            orElse: () =>
                CategoryCode.YOUR_HUMORS, // Return null if no match is found
          ),
          context: document['context'],
          contextList: document['context_list']?.split('@@@'),
          punchline: document['punchline'],
          author: document['author'],
          sender: document['sender'],
          source: document['source'],
        );

  BookmarkHumor.fromDailyHumor(DailyHumor dailyHumor)
      : bookmarkAddedDate = DateTime.now(),
        bookmarkOrd = null,
        bookmarkEmojiIndex = 0,
        super(
            uuid: dailyHumor.uuid,
            categoryCode: dailyHumor.categoryCode,
            context: dailyHumor.context,
            contextList: dailyHumor.contextList,
            punchline: dailyHumor.punchline,
            sender: dailyHumor.sender,
            source: dailyHumor.source);

  @override
  Map<String, dynamic> humorToMap() {
    final Map<String, dynamic> map = {
      'uuid': uuid,
      'bookmark_ord': bookmarkOrd, // even if this value is null, use it!
      'bookmark_added_date': bookmarkAddedDate.toIso8601String(),
      'category': categoryCode.name,
      'context': context,
      'context_list': contextList?.join('@@@'),
      'punchline': punchline,
      'author': author,
      'sender': sender,
      'source': source,
      'bookmark_emoji_index': bookmarkEmojiIndex,
    };
    return map;
  }
}
