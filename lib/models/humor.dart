import 'package:daily_dose_of_humors/models/category.dart';

/*
create_date: date
added_date: date
category: integer between 0 and 10
title TEXT,
context: string
context_list: string
punchline: string
author: string (under 50 chars)
sender: string (under 50 chars)
source: string (under 50 chars)
*/

class Humor {
  final String uuid;
  final DateTime? createDate;
  final DateTime? addedDate;
  final CategoryCode categoryCode;
  final String? title;
  final String? context;
  final List<String>? contextList;
  final String? punchline;
  final String? author;
  final String? sender;
  final String? source;

  // final List<Color> themeColorGradient;
  Humor({
    required this.uuid,
    this.createDate,
    this.addedDate,
    required this.categoryCode,
    this.title,
    this.context,
    this.contextList,
    this.punchline,
    this.author,
    this.sender,
    this.source,
  });

  Humor.fromDocument(Map<String, dynamic> document)
      : uuid = document['uuid'],
        createDate = document['create_date'] == null
            ? null
            : DateTime.parse(document['create_date']),
        addedDate = document['added_date'] == null
            ? null
            : DateTime.parse(document['added_date']),
        categoryCode = CategoryCode.values[document['category']],
        title = document['title'],
        context = document['context'],
        contextList = document['context_list']?.split('@@@'),
        punchline = document['punchline'],
        author = document['author'],
        sender = document['sender'],
        source = document['source'];

  Category getCategoryData() {
    return Category.getCategoryByCode(categoryCode);
  }

  Map<String, dynamic> humorToMap() {
    final Map<String, dynamic> map = {
      'uuid': uuid,
      'category': categoryCode.index,
      'punchline': punchline,
    };

    if (createDate != null) {
      map['create_date'] = createDate!.toIso8601String();
    }
    if (addedDate != null) {
      map['added_date'] = addedDate!.toIso8601String();
    }
    if (title != null) {
      map['title'] = title;
    }
    if (context != null) {
      map['context'] = context;
    }
    if (contextList != null) {
      map['context_list'] = contextList!.join('@@@');
    }
    if (author != null) {
      map['author'] = author;
    }
    if (sender != null) {
      map['sender'] = sender;
    }
    if (source != null) {
      map['source'] = source;
    }
    return map;
  }
}
