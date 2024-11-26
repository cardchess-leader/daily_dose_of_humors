import 'package:daily_dose_of_humors/models/category.dart';

class Bundle {
  final String uuid;
  final CategoryCode categoryCode;
  final String title;
  final String description;
  final List<String> coverImgList;
  final int humorCount;
  final String languageCode;
  final String productId;
  final String releaseDate;
  final String price;

  const Bundle({
    required this.uuid,
    required this.categoryCode,
    required this.title,
    required this.description,
    required this.coverImgList,
    required this.humorCount,
    required this.languageCode,
    required this.productId,
    required this.releaseDate,
    this.price = '',
  });

  /// Factory constructor for parsing JSON into a Bundle object
  factory Bundle.fromJson(Map<String, dynamic> json) {
    try {
      return Bundle(
        uuid: json['uuid'] as String? ?? '',
        categoryCode: _parseCategoryCode(json['category']),
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        coverImgList: (json['cover_img_list'] as List<dynamic>?)
                ?.whereType<String>()
                .toList() ??
            [],
        humorCount: json['humor_count'] as int? ?? 0,
        languageCode: json['language_code'] as String? ?? 'EN',
        productId: json['product_id'] as String? ?? '',
        releaseDate: json['release_date'] as String? ?? '2024-01-01',
        price: json['price'] as String? ?? '',
      );
    } catch (e) {
      // Handle any unexpected JSON structure or type issues gracefully
      print('Error parsing Bundle JSON: $e');
      return Bundle(
        uuid: '',
        categoryCode: CategoryCode.YOUR_HUMORS,
        title: '',
        description: '',
        coverImgList: [],
        humorCount: 0,
        languageCode: 'EN',
        productId: '',
        releaseDate: '2024-01-01',
        price: '',
      );
    }
  }

  /// Converts the Bundle object to a Map for database operations or JSON serialization
  Map<String, dynamic> bundleToMap() {
    return {
      'uuid': uuid,
      'category': categoryCode.name,
      'title': title,
      'description': description,
      'cover_img_list': coverImgList.join('@@@'),
      'humor_count': humorCount,
      'language_code': languageCode,
      'product_id': productId,
      'release_date': releaseDate,
    };
  }

  /// Helper method to parse CategoryCode from a dynamic JSON value
  static CategoryCode _parseCategoryCode(dynamic category) {
    if (category is String) {
      return CategoryCode.values.firstWhere(
        (e) => e.name == category,
        orElse: () => CategoryCode.YOUR_HUMORS,
      );
    }
    return CategoryCode.YOUR_HUMORS; // Default fallback
  }
}
