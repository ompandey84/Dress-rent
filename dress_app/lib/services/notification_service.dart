import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/services/supabase_service.dart';
// Note: firebase_messaging package is needed for FCM
// import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final SupabaseClient _supabase = SupabaseService.client;
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initialize notifications (request permission & save token)
  Future<void> initialize() async {
    // try {
    //   NotificationSettings settings = await _firebaseMessaging.requestPermission(
    //     alert: true,
    //     badge: true,
    //     sound: true,
    //   );
    //
    //   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    //     String? token = await _firebaseMessaging.getToken();
    //     if (token != null) {
    //       await _saveTokenToSupabase(token);
    //     }
    //   }
    //
    //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //     // Handle foreground message
    //   });
    // } catch (e) {
    //   print('Error initializing notifications: $e');
    // }
  }

  // Future<void> _saveTokenToSupabase(String token) async {
  //   final userId = _supabase.auth.currentUser?.id;
  //   if (userId == null) return;
  //   
  //   // Save token to a fcm_tokens table or user_settings (not detailed in migrations, so omitting)
  // }

  // Fetch all notifications for the current user
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final data = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  // Mark single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Stream of unread notification count
  Stream<int> getUnreadCountStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value(0);

    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .eq('is_read', false)
        .map((data) => data.length);
  }
}
