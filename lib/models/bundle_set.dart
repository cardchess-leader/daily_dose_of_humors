class BundleSet {
  final String uuid;
  final String title;
  final String subtitle;

  const BundleSet({
    required this.uuid,
    required this.title,
    required this.subtitle,
  });

  BundleSet.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'] ?? '',
        title = json['title'] ?? '',
        subtitle = json['subtitle'] ?? '';
}
