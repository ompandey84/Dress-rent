import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:dress_app/services/auth_service.dart';

/// Categories of issues that can be raised.
enum SupportCategory {
  booking,
  payment,
  damage,
  account,
  safety,
  other,
}

extension SupportCategoryX on SupportCategory {
  String get label {
    switch (this) {
      case SupportCategory.booking: return 'Booking issue';
      case SupportCategory.payment: return 'Payment / Refund';
      case SupportCategory.damage: return 'Damage / Claim';
      case SupportCategory.account: return 'Account / Login';
      case SupportCategory.safety: return 'Safety concern';
      case SupportCategory.other: return 'Other';
    }
  }
}

class SupportTicket {
  final String id;
  final String userId;
  final SupportCategory category;
  final String subject;
  final String description;
  final String? relatedBookingId;
  final String? relatedUserId;
  final List<String> attachments;
  final String status; // open, in_progress, resolved, closed
  final DateTime createdAt;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.category,
    required this.subject,
    required this.description,
    this.relatedBookingId,
    this.relatedUserId,
    this.attachments = const [],
    required this.status,
    required this.createdAt,
  });
}

/// Service for support tickets, reports, and blocked users.
class SupportService {
  static final SupportService _instance = SupportService._internal();
  factory SupportService() => _instance;
  SupportService._internal();

  final List<Map<String, dynamic>> _mockTickets = [];
  final List<String> _mockBlockedUsers = [];

  /// Create a support ticket.
  Future<SupportTicket> createTicket({
    required SupportCategory category,
    required String subject,
    required String description,
    String? relatedBookingId,
    String? relatedUserId,
    List<String> attachments = const [],
  }) async {
    final id = 'ticket_${DateTime.now().millisecondsSinceEpoch}';
    final ticket = SupportTicket(
      id: id,
      userId: AuthService().currentUserId ?? 'mock_user',
      category: category,
      subject: subject,
      description: description,
      relatedBookingId: relatedBookingId,
      relatedUserId: relatedUserId,
      attachments: attachments,
      status: 'open',
      createdAt: DateTime.now(),
    );

    if (!SupabaseService.isConfigured) {
      _mockTickets.add({
        'id': ticket.id,
        'user_id': ticket.userId,
        'category': ticket.category.name,
        'subject': ticket.subject,
        'description': ticket.description,
        'related_booking_id': ticket.relatedBookingId,
        'related_user_id': ticket.relatedUserId,
        'attachments': ticket.attachments,
        'status': ticket.status,
        'created_at': ticket.createdAt.toIso8601String(),
      });
      await Future.delayed(const Duration(milliseconds: 400));
      return ticket;
    }

    final supabase = Supabase.instance.client;
    await supabase.from('support_tickets').insert({
      'user_id': ticket.userId,
      'category': ticket.category.name,
      'subject': ticket.subject,
      'description': ticket.description,
      'related_booking_id': ticket.relatedBookingId,
      'related_user_id': ticket.relatedUserId,
      'attachments': ticket.attachments,
      'status': ticket.status,
    });
    return ticket;
  }

  /// Get all tickets for current user.
  Future<List<SupportTicket>> myTickets() async {
    if (!SupabaseService.isConfigured) {
      return _mockTickets.map((m) => SupportTicket(
        id: m['id'],
        userId: m['user_id'],
        category: SupportCategory.values.firstWhere(
          (c) => c.name == m['category'],
          orElse: () => SupportCategory.other,
        ),
        subject: m['subject'],
        description: m['description'],
        relatedBookingId: m['related_booking_id'],
        relatedUserId: m['related_user_id'],
        attachments: (m['attachments'] as List).cast<String>(),
        status: m['status'],
        createdAt: DateTime.parse(m['created_at']),
      )).toList();
    }
    final supabase = Supabase.instance.client;
    final res = await supabase
        .from('support_tickets')
        .select()
        .eq('user_id', AuthService().currentUserId ?? '')
        .order('created_at', ascending: false);
    return (res as List).map((m) => SupportTicket(
      id: m['id'],
      userId: m['user_id'],
      category: SupportCategory.values.firstWhere(
        (c) => c.name == m['category'],
        orElse: () => SupportCategory.other,
      ),
      subject: m['subject'],
      description: m['description'],
      relatedBookingId: m['related_booking_id'],
      relatedUserId: m['related_user_id'],
      attachments: (m['attachments'] as List).cast<String>(),
      status: m['status'],
      createdAt: DateTime.parse(m['created_at']),
    )).toList();
  }

  /// Report a user.
  Future<bool> reportUser({
    required String userId,
    required String reason, // 'harassment', 'fake_listing', 'inappropriate', 'no_show', 'other'
    String? notes,
    String? relatedBookingId,
  }) async {
    if (!SupabaseService.isConfigured) {
      await Future.delayed(const Duration(milliseconds: 400));
      return true;
    }
    final supabase = Supabase.instance.client;
    await supabase.from('user_reports').insert({
      'reporter_id': AuthService().currentUserId,
      'reported_user_id': userId,
      'reason': reason,
      'notes': notes,
      'related_booking_id': relatedBookingId,
    });
    return true;
  }

  /// Block a user.
  Future<bool> blockUser(String userId) async {
    if (!SupabaseService.isConfigured) {
      _mockBlockedUsers.add(userId);
      await Future.delayed(const Duration(milliseconds: 200));
      return true;
    }
    final supabase = Supabase.instance.client;
    await supabase.from('blocked_users').insert({
      'user_id': AuthService().currentUserId,
      'blocked_user_id': userId,
    });
    return true;
  }

  /// Unblock a user.
  Future<bool> unblockUser(String userId) async {
    if (!SupabaseService.isConfigured) {
      _mockBlockedUsers.remove(userId);
      await Future.delayed(const Duration(milliseconds: 200));
      return true;
    }
    final supabase = Supabase.instance.client;
    await supabase.from('blocked_users').delete()
        .eq('user_id', AuthService().currentUserId ?? '')
        .eq('blocked_user_id', userId);
    return true;
  }

  /// Get blocked users.
  Future<List<String>> blockedUsers() async {
    if (!SupabaseService.isConfigured) return List.of(_mockBlockedUsers);
    final supabase = Supabase.instance.client;
    final res = await supabase
        .from('blocked_users')
        .select('blocked_user_id')
        .eq('user_id', AuthService().currentUserId ?? '');
    return ((res as List).map((m) => m['blocked_user_id'] as String)).toList();
  }
}
