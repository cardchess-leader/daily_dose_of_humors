class BundleSet {
  final String uuid;
  final String title;
  final String subtitle;
  final List<String> bundleList;

  const BundleSet({
    required this.uuid,
    required this.title,
    required this.subtitle,
    required this.bundleList,
  });

  factory BundleSet.fromJson(Map<String, dynamic> json) {
    try {
      return BundleSet(
        uuid: json['uuid'] as String? ?? '',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        bundleList: (json['bundle_list'] as List<dynamic>?)
                ?.whereType<String>() // Select only elements of type String
                .toList() ??
            [],
      );
    } catch (e) {
      // Handle any unexpected JSON structure or type issues gracefully
      print('Error parsing BundleSet JSON: $e');
      return const BundleSet(
        uuid: '',
        title: '',
        subtitle: '',
        bundleList: [],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'title': title,
      'subtitle': subtitle,
      'bundle_list': bundleList,
    };
  }
}
