class Category {
  final String id;
  final String name;
  final String slug;
  final String iconUrl;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.iconUrl = '',
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      iconUrl: json['icon_url'] as String? ?? '',
    );
  }
}
