class SizeGuide {
  final String id;
  final String? categoryId;
  final String sizeLabel;
  final double? bustCm;
  final double? waistCm;
  final double? hipsCm;
  final double? lengthCm;

  SizeGuide({
    required this.id,
    this.categoryId,
    required this.sizeLabel,
    this.bustCm,
    this.waistCm,
    this.hipsCm,
    this.lengthCm,
  });

  factory SizeGuide.fromJson(Map<String, dynamic> json) {
    return SizeGuide(
      id: json['id'] as String,
      categoryId: json['category_id'] as String?,
      sizeLabel: json['size_label'] as String? ?? '',
      bustCm: json['bust_cm'] != null ? (json['bust_cm'] as num).toDouble() : null,
      waistCm: json['waist_cm'] != null ? (json['waist_cm'] as num).toDouble() : null,
      hipsCm: json['hips_cm'] != null ? (json['hips_cm'] as num).toDouble() : null,
      lengthCm: json['length_cm'] != null ? (json['length_cm'] as num).toDouble() : null,
    );
  }
}
