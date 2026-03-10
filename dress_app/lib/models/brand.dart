class Brand {
  final String id;
  final String name;
  final String slug;
  final String logoUrl;

  Brand({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl = '',
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? '',
    );
  }
}
