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

  BundleSet.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'] ?? '',
        title = json['title'] ?? '',
        subtitle = json['subtitle'] ?? '',
        bundleList = (json['bundle_list'] as List<dynamic>?)
                ?.map((uuid) => uuid as String)
                .toList() ??
            [];
}
