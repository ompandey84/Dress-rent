import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:dress_app/services/auth_service.dart';
import 'package:dress_app/services/mock_data_service.dart';

/// Notification backend. In live mode uses Supabase `notifications` table;
/// in mock mode falls back to in-memory `MockDataService.mockNotifications`.
class NotificationService {
  /// In-memory list so mock-mode reads see writes within the same session.
  final List<Map<String, dynamic>> _mockList = [];
  bool _mockSeeded = false;

  Future<void> initialize() async {
    if (!SupabaseService.isConfigured && !_mockSeeded) {
      _mockList.addAll(
        MockDataService.mockNotifications.map(_notifToMap),
      );
      _mockSeeded = true;
    }
  }

  Map<String, dynamic> _notifToMap(dynamic n) => {
        'id': n.id,
        'title': n.title,
        'description': n.description,
        'created_at': n.timestamp.toIso8601String(),
        'is_read': n.isRead,
        'type': n.type.name,
        'related_order_id': n.relatedOrderId,
        'related_product_id': n.relatedProductId,
        'deep_link': n.deepLink,
      };

  Future<List<Map<String, dynamic>>> getNotifications() async {
    if (!SupabaseService.isConfigured) {
      await initialize();
      return List.unmodifiable(_mockList);
    }
    final uid = AuthService().currentUserId;
    if (uid == null) return [];
    final res = await Supabase.instance.client
        .from('notifications')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(100);
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<void> markAsRead(String notificationId) async {
    if (!SupabaseService.isConfigured) {
      final i = _mockList.indexWhere((n) => n['id'] == notificationId);
      if (i != -1) {
        _mockList[i] = {..._mockList[i], 'is_read': true};
      }
      return;
    }
    await Supabase.instance.client
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
  }

  Future<void> markAllAsRead() async {
    if (!SupabaseService.isConfigured) {
      for (var i = 0; i < _mockList.length; i++) {
        _mockList[i] = {..._mockList[i], 'is_read': true};
      }
      return;
    }
    final uid = AuthService().currentUserId;
    if (uid == null) return;
    await Supabase.instance.client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', uid)
        .eq('is_read', false);
  }

  Future<void> deleteNotification(String notificationId) async {
    if (!SupabaseService.isConfigured) {
      _mockList.removeWhere((n) => n['id'] == notificationId);
      return;
    }
    await Supabase.instance.client
        .from('notifications')
        .delete()
        .eq('id', notificationId);
  }

  /// Real-time stream of unread count. Yields once initially and then on every
  /// change in mock mode; in live mode subscribes to Postgres changes.
  Stream<int> getUnreadCountStream() async* {
    yield await getUnreadCount();
    if (!SupabaseService.isConfigured) {
      // Polling fallback for mock mode.
      await for (final _ in Stream.periodic(const Duration(seconds: 30))) {
        yield await getUnreadCount();
      }
      return;
    }
    final uid = AuthService().currentUserId;
    if (uid == null) return;
    // Subscribe to the notifications table. Whenever a row changes we
    // re-read the unread count.
    final channel = Supabase.instance.client
        .channel('notif_count:$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: uid,
          ),
          callback: (_) {},
        )
        .subscribe();
    try {
      // The channel itself doesn't expose a stream directly; instead, poll
      // when a change event fires by listening on a Stream<int> built
      // from onChange.
      final controller = StreamController<int>();
      final sub = channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'notifications',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: uid,
        ),
        callback: (_) async {
          controller.add(await getUnreadCount());
        },
      );
      controller.add(await getUnreadCount());
      await for (final c in controller.stream) {
        yield c;
      }
      await sub;
    } finally {
      await channel.unsubscribe();
    }
  }

  Future<int> getUnreadCount() async {
    if (!SupabaseService.isConfigured) {
      return _mockList.where((n) => n['is_read'] != true).length;
    }
    final uid = AuthService().currentUserId;
    if (uid == null) return 0;
    final res = await Supabase.instance.client
        .from('notifications')
        .select('id')
        .eq('user_id', uid)
        .eq('is_read', false);
    return (res as List).length;
  }

  /// Insert a notification (used by services like booking confirmation).
  Future<void> push({
    required String userId,
    required String title,
    required String description,
    String type = 'general',
    String? relatedOrderId,
    String? relatedProductId,
    String? deepLink,
  }) async {
    final payload = {
      'user_id': userId,
      'title': title,
      'description': description,
      'type': type,
      'is_read': false,
      if (relatedOrderId != null) 'related_order_id': relatedOrderId,
      if (relatedProductId != null) 'related_product_id': relatedProductId,
      if (deepLink != null) 'deep_link': deepLink,
      'created_at': DateTime.now().toIso8601String(),
    };
    if (!SupabaseService.isConfigured) {
      _mockList.insert(0, {...payload, 'id': 'n_${DateTime.now().millisecondsSinceEpoch}'});
      return;
    }
    await Supabase.instance.client.from('notifications').insert(payload);
  }
}
