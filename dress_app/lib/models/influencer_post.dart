class InfluencerPost {
  final String id;
  final String userId;
  final String imageUrl;
  final String caption;
  final String? productId;
  final int likesCount;
  final DateTime createdAt;

  InfluencerPost({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.caption = '',
    this.productId,
    this.likesCount = 0,
    required this.createdAt,
  });

  factory InfluencerPost.fromJson(Map<String, dynamic> json) {
    return InfluencerPost(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      productId: json['product_id'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
