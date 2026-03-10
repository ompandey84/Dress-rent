enum NotificationType { order, promo, general, booking, payment, returnReq, review, damage, listing }

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String timeText;
  final NotificationType type;
  bool isRead;
  final String? relatedOrderId;
  final String? relatedProductId;
  final String? deepLink;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.timeText,
    required this.type,
    this.isRead = false,
    this.relatedOrderId,
    this.relatedProductId,
    this.deepLink,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timestamp: DateTime.parse(json['created_at'] as String),
      timeText: _formatTime(DateTime.parse(json['created_at'] as String)),
      type: _parseType(json['type'] as String? ?? 'general'),
      isRead: json['is_read'] as bool? ?? false,
      relatedOrderId: json['related_order_id'] as String?,
      relatedProductId: json['related_product_id'] as String?,
      deepLink: json['deep_link'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type.name,
      if (relatedOrderId != null) 'related_order_id': relatedOrderId,
      if (relatedProductId != null) 'related_product_id': relatedProductId,
      if (deepLink != null) 'deep_link': deepLink,
    };
  }

  static NotificationType _parseType(String typeStr) {
    switch (typeStr) {
      case 'order': return NotificationType.order;
      case 'promo': return NotificationType.promo;
      case 'booking': return NotificationType.booking;
      case 'payment': return NotificationType.payment;
      case 'return': return NotificationType.returnReq;
      case 'review': return NotificationType.review;
      case 'damage': return NotificationType.damage;
      case 'listing': return NotificationType.listing;
      default: return NotificationType.general;
    }
  }

  static String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
