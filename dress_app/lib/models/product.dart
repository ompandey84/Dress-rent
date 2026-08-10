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
    // product_images: list of {image_url, display_order}
    final imgs = json['product_images'];
    if (imgs is List) {
      for (final img in imgs) {
        if (img is Map && img['image_url'] != null) {
          parsedImages.add(img['image_url'].toString());
        }
      }
    }
    // Fallback: a single `image_url` / `images` / `thumbnail` field
    if (parsedImages.isEmpty) {
      for (final k in ['image_url', 'images', 'thumbnail', 'cover_image_url']) {
        final v = json[k];
        if (v is String && v.isNotEmpty) {
          parsedImages.add(v);
          break;
        }
      }
    }

    final List<String> parsedSizes = [];
    final sizes = json['product_sizes'];
    if (sizes is List) {
      for (final size in sizes) {
        if (size is Map && size['size'] != null) {
          parsedSizes.add(size['size'].toString());
        }
      }
    }
    if (parsedSizes.isEmpty) {
      for (final k in ['sizes', 'available_sizes']) {
        final v = json[k];
        if (v is List) {
          for (final s in v) {
            if (s is String) parsedSizes.add(s);
            if (s is Map && s['size'] != null) parsedSizes.add(s['size'].toString());
          }
        }
      }
    }

    final List<String> parsedColors = [];
    final colors = json['product_colors'];
    if (colors is List) {
      for (final color in colors) {
        if (color is Map) {
          final n = color['color_name'] ?? color['name'];
          if (n != null) parsedColors.add(n.toString());
        } else if (color is String) {
          parsedColors.add(color);
        }
      }
    }
    if (parsedColors.isEmpty) {
      for (final k in ['colors', 'available_colors']) {
        final v = json[k];
        if (v is List) {
          for (final c in v) {
            if (c is String) parsedColors.add(c);
            if (c is Map && c['color_name'] != null) parsedColors.add(c['color_name'].toString());
          }
        }
      }
    }

    final double pPrice =
        (json['rental_price_per_day'] as num?)?.toDouble() ??
            (json['rental_price'] as num?)?.toDouble() ??
            (json['price'] as num?)?.toDouble() ??
            0.0;

    // Category: prefer joined `categories.name`, else raw `category` field
    String category = '';
    if (json['categories'] is Map) {
      category = (json['categories']['name'] ?? '').toString();
    } else if (json['category'] is Map) {
      category = (json['category']['name'] ?? '').toString();
    } else {
      category = (json['category'] ?? '').toString();
    }

    // Store fields
    String storeName = '';
    bool isVerifiedStore = false;
    String storeLocation = '';
    if (json['stores'] is Map) {
      final s = json['stores'] as Map;
      storeName =
          (s['name'] ?? s['shop_name'] ?? '').toString();
      isVerifiedStore = s['is_verified'] == true;
      storeLocation = (s['location'] ?? '').toString();
    } else {
      storeName = (json['store_name'] ?? '').toString();
      storeLocation = (json['location'] ?? '').toString();
    }

    DateTime? tryParseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    return Product(
      id: (json['id'] ?? '').toString(),
      storeId: (json['store_id'] ?? '').toString(),
      categoryId: json['category_id']?.toString(),
      brandId: json['brand_id']?.toString(),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      category: category,
      rentalPricePerDay: pPrice,
      price: pPrice,
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? pPrice,
      securityDeposit: (json['security_deposit'] as num?)?.toDouble() ?? 0.0,
      description: (json['description'] ?? '').toString(),
      gender: (json['gender'] ?? 'Unisex').toString(),
      images: parsedImages,
      sizes: parsedSizes,
      colors: parsedColors,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (json['reviews_count'] is int)
          ? json['reviews_count'] as int
          : int.tryParse(json['reviews_count']?.toString() ?? '') ?? 0,
      storeName: storeName,
      isVerifiedStore: isVerifiedStore,
      location: storeLocation,
      arModelUrl: json['ar_model_url']?.toString(),
      videoUrl: json['video_url']?.toString(),
      availableFrom: tryParseDate(json['available_from']),
      availableUntil: tryParseDate(json['available_until']),
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
