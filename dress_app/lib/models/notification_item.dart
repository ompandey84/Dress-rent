enum NotificationType { order, promo, general }

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String timeText;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeText,
    required this.type,
    this.isRead = false,
  });
}
