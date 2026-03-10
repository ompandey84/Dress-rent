class Store {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String bannerUrl;
  final String logoUrl;
  final String location;
  final double? latitude;
  final double? longitude;
  final bool isVerified;
  final double rating;
  final int reviewsCount;
  final int totalProducts;

  Store({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description = '',
    this.bannerUrl = '',
    this.logoUrl = '',
    this.location = '',
    this.latitude,
    this.longitude,
    this.isVerified = false,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.totalProducts = 0,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      bannerUrl: json['banner_url'] as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? '',
      location: json['location'] as String? ?? '',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      isVerified: json['is_verified'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      totalProducts: json['total_products'] as int? ?? 0,
    );
  }
}
