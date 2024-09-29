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
    required this.price,
  });

  Bundle.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'] ?? '',
        categoryCode = CategoryCode.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => CategoryCode.YOUR_HUMORS,
        ),
        title = json['title'] ?? '',
        description = json['description'] ?? '',
        coverImgList = (json['cover_img_list'] as List<dynamic>?)
                ?.map((item) => item as String)
                .toList() ??
            [],
        humorCount = json['humor_count'] ?? 0,
        languageCode = json['language_code'] ?? 'EN',
        productId = json['product_id'] ?? '',
        releaseDate = json['release_date'] ?? '2024-01-01',
        price = json['price'] ?? '';
}
