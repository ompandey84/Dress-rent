class Measurements {
  final String id;
  final String userId;
  final double? bust;
  final double? waist;
  final double? hips;
  final double? height;
  final double? shoulder;
  final double? inseam;
  final double? weight;
  final String? preferredSize;
  final DateTime updatedAt;

  Measurements({
    required this.id,
    required this.userId,
    this.bust,
    this.waist,
    this.hips,
    this.height,
    this.shoulder,
    this.inseam,
    this.weight,
    this.preferredSize,
    required this.updatedAt,
  });

  factory Measurements.fromJson(Map<String, dynamic> json) {
    return Measurements(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      bust: (json['bust'] as num?)?.toDouble(),
      waist: (json['waist'] as num?)?.toDouble(),
      hips: (json['hips'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      shoulder: (json['shoulder'] as num?)?.toDouble(),
      inseam: (json['inseam'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      preferredSize: json['preferred_size'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'bust': bust,
      'waist': waist,
      'hips': hips,
      'height': height,
      'shoulder': shoulder,
      'inseam': inseam,
      'weight': weight,
      'preferred_size': preferredSize,
    };
  }

  bool get isEmpty =>
      bust == null &&
      waist == null &&
      hips == null &&
      height == null &&
      shoulder == null &&
      inseam == null &&
      weight == null;

  /// Calculate suggested size based on measurements
  String suggestSize() {
    if (bust == null) return preferredSize ?? 'M';
    if (bust! < 81) return 'XS';
    if (bust! < 86) return 'S';
    if (bust! < 91) return 'M';
    if (bust! < 97) return 'L';
    if (bust! < 102) return 'XL';
    return 'XXL';
  }
}
