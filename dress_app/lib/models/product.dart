class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double originalPrice;
  final String description;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final double rating;
  final int reviewsCount;
  final String storeName;
  final String location;
  final bool isVerifiedStore;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.originalPrice = 0.0,
    required this.description,
    required this.images,
    required this.sizes,
    required this.colors,
    required this.rating,
    required this.reviewsCount,
    required this.storeName,
    required this.location,
    this.isVerifiedStore = true,
  });
}
