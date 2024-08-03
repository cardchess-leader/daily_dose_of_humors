import 'package:daily_dose_of_humors/models/category.dart';

class Humor {
  final CategoryCode categoryCode;
  final String context;
  final List<String> contextList;
  final String punchLine;

  // final List<Color> themeColorGradient;
  const Humor({
    required this.categoryCode,
    required this.context,
    this.contextList = const [],
    required this.punchLine,
  });

  Category getCategoryData() {
    return Category.getCategoryByCode(categoryCode);
  }
}
