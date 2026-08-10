import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/services/notification_service.dart';
import 'package:dress_app/models/notification_item.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    return NotificationService().getNotifications();
  }

  void _refresh() {
    setState(() {
      _notificationsFuture = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NOTIFICATIONS',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await NotificationService().markAllAsRead();
              _refresh();
            },
            child: Text(
              'Read All',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryLime,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryLime),
            );
          }
          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) return _buildEmpty();
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final n = items[index];
                return Dismissible(
                  key: ValueKey(n['id']),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) async {
                    await NotificationService().deleteNotification(n['id']);
                    _refresh();
                  },
                  background: Container(
                    padding: const EdgeInsets.only(right: 24),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(FluentIcons.delete_24_regular, color: Colors.white),
                  ),
                  child: _buildNotificationTile(n),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FluentIcons.alert_24_regular,
            size: 60,
            color: AppTheme.textLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "We'll let you know when something important happens.",
            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FluentIcons.error_circle_24_regular,
                size: 48, color: Colors.red.shade400),
            const SizedBox(height: 12),
            Text('Could not load notifications',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark)),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: _refresh, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> n) {
    final type = n['type'] as String? ?? 'general';
    final isUnread = n['is_unread'] as bool? ?? false;
    return InkWell(
      onTap: () async {
        await NotificationService().markAsRead(n['id']);
        // Refresh the tile quietly
        _refresh();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? AppTheme.primaryLime.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread ? AppTheme.primaryLime : Colors.grey.shade200,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUnread ? Colors.white : const Color(0xFFF6F8FA),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconForType(type), color: AppTheme.textDark, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          (n['title'] as String?) ?? 'Notification',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(n['created_at'] as String?),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (n['message'] as String?) ?? (n['description'] as String?) ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.textLight,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'order':
        return FluentIcons.box_24_regular;
      case 'promo':
        return FluentIcons.savings_24_regular;
      case 'booking':
        return FluentIcons.calendar_24_regular;
      case 'payment':
        return FluentIcons.payment_24_regular;
      case 'return_request':
      case 'review':
      case 'damage':
        return FluentIcons.alert_24_regular;
      case 'listing':
        return FluentIcons.tag_24_regular;
      default:
        return FluentIcons.info_24_regular;
    }
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('d MMM').format(dt);
  }
}
