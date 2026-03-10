class Product {
  final String id;
  final String storeId;
  final String? categoryId;
  final String? brandId;
  final String name;
  final String category;
  final double rentalPricePerDay;
  final double price; // Alias for rentalPricePerDay for backward compatibility
  final double originalPrice;
  final double securityDeposit;
  final String description;
  final String gender;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final double rating;
  final int reviewsCount;
  final String storeName;
  final String location;
  final bool isVerifiedStore;
  final String? arModelUrl;
  final String? videoUrl;
  final DateTime? availableFrom;
  final DateTime? availableUntil;

  Product({
    required this.id,
    this.storeId = '',
    this.categoryId,
    this.brandId,
    required this.name,
    this.category = '',
    required this.rentalPricePerDay,
    required this.price,
    this.originalPrice = 0.0,
    this.securityDeposit = 0.0,
    required this.description,
    this.gender = 'Unisex',
    required this.images,
    required this.sizes,
    required this.colors,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.storeName = '',
    this.location = '',
    this.isVerifiedStore = true,
    this.arModelUrl,
    this.videoUrl,
    this.availableFrom,
    this.availableUntil,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final List<String> parsedImages = [];
    if (json['product_images'] != null) {
      for (var img in json['product_images']) {
        parsedImages.add(img['image_url'] as String);
      }
    }
    
    final List<String> parsedSizes = [];
    if (json['product_sizes'] != null) {
      for (var size in json['product_sizes']) {
        parsedSizes.add(size['size'] as String);
      }
    }
    
    final List<String> parsedColors = [];
    if (json['product_colors'] != null) {
      for (var color in json['product_colors']) {
        parsedColors.add(color['color_name'] as String);
      }
    }

    final double pPrice = (json['rental_price_per_day'] as num?)?.toDouble() ?? 0.0;

    return Product(
      id: json['id'] as String,
      storeId: json['store_id'] as String? ?? '',
      categoryId: json['category_id'] as String?,
      brandId: json['brand_id'] as String?,
      name: json['name'] as String? ?? '',
      category: json['categories'] != null ? json['categories']['name'] : '',
      rentalPricePerDay: pPrice,
      price: pPrice,
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0.0,
      securityDeposit: (json['security_deposit'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      gender: json['gender'] as String? ?? 'Unisex',
      images: parsedImages,
      sizes: parsedSizes,
      colors: parsedColors,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      storeName: json['stores'] != null ? json['stores']['name'] : '',
      isVerifiedStore: json['stores'] != null ? json['stores']['is_verified'] : false,
      location: json['stores'] != null ? json['stores']['location'] : '',
      arModelUrl: json['ar_model_url'] as String?,
      videoUrl: json['video_url'] as String?,
      availableFrom: json['available_from'] != null ? DateTime.parse(json['available_from']) : null,
      availableUntil: json['available_until'] != null ? DateTime.parse(json['available_until']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (storeId.isNotEmpty) 'store_id': storeId,
      if (categoryId != null) 'category_id': categoryId,
      if (brandId != null) 'brand_id': brandId,
      'name': name,
      'rental_price_per_day': rentalPricePerDay,
      'original_price': originalPrice,
      'security_deposit': securityDeposit,
      'description': description,
      'gender': gender,
      if (arModelUrl != null) 'ar_model_url': arModelUrl,
      if (videoUrl != null) 'video_url': videoUrl,
      if (availableFrom != null) 'available_from': availableFrom?.toIso8601String(),
      if (availableUntil != null) 'available_until': availableUntil?.toIso8601String(),
    };
  }
}
