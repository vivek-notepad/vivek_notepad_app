class OurApp {
  final String name;
  final String description;
  final String packageId;
  final String? iconAsset;
  final String? iconUrl;

  const OurApp({
    required this.name,
    required this.description,
    required this.packageId,
    this.iconAsset,
    this.iconUrl,
  });

  String get playStoreUrl =>
      'https://play.google.com/store/apps/details?id=$packageId';
}
