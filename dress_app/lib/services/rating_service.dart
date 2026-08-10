import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:dress_app/services/auth_service.dart';
import 'package:dress_app/models/booking.dart';

class Rating {
  final String id;
  final String bookingId;
  final String raterId;
  final String rateeId;
  final String type; // 'renter_to_lender', 'lender_to_renter', 'renter_to_listing'
  final int score; // 1-5
  final String? review;
  final int? communicationScore;
  final int? accuracyScore;
  final int? deliveryScore;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.bookingId,
    required this.raterId,
    required this.rateeId,
    required this.type,
    required this.score,
    this.review,
    this.communicationScore,
    this.accuracyScore,
    this.deliveryScore,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    id: json['id'] as String,
    bookingId: json['order_id'] as String,
    raterId: json['rater_id'] as String,
    rateeId: json['ratee_id'] as String,
    type: json['type'] as String,
    score: json['score'] as int,
    review: json['review'] as String?,
    communicationScore: json['communication_score'] as int?,
    accuracyScore: json['accuracy_score'] as int?,
    deliveryScore: json['delivery_score'] as int?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

/// Service for mutual ratings, payouts, and referrals.
class RatingService {
  static final RatingService _instance = RatingService._internal();
  factory RatingService() => _instance;
  RatingService._internal();

  /// Submit a rating (renter to lender OR lender to renter).
  Future<bool> submitRating({
    required Booking booking,
    required String rateeId,
    required String type, // 'renter_to_lender' or 'lender_to_renter'
    required int score,
    String? review,
    int? communicationScore,
    int? accuracyScore,
    int? deliveryScore,
  }) async {
    if (!SupabaseService.isConfigured) return true;
    final supabase = Supabase.instance.client;
    try {
      await supabase.from('ratings').upsert({
        'order_id': booking.id,
        'rater_id': AuthService().currentUserId,
        'ratee_id': rateeId,
        'type': type,
        'score': score,
        'review': review,
        'communication_score': communicationScore,
        'accuracy_score': accuracyScore,
        'delivery_score': deliveryScore,
      });
      // Recalculate aggregate rating
      await _recalcRating(rateeId, type);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _recalcRating(String userId, String type) async {
    if (!SupabaseService.isConfigured) return;
    final supabase = Supabase.instance.client;
    final res = await supabase
        .from('ratings')
        .select('score')
        .eq('ratee_id', userId)
        .eq('type', type);
    final scores = (res as List).map((r) => r['score'] as int).toList();
    if (scores.isEmpty) return;
    // Update profile aggregate
    await supabase.from('profiles').update({
      'reviews_count': scores.length,
    }).eq('id', userId);
  }

  /// Get all ratings for a user.
  Future<List<Rating>> getRatingsFor(String userId) async {
    if (!SupabaseService.isConfigured) return [];
    final supabase = Supabase.instance.client;
    final res = await supabase
        .from('ratings')
        .select()
        .eq('ratee_id', userId)
        .order('created_at', ascending: false);
    return (res as List).map((m) => Rating.fromJson(m)).toList();
  }

  /// Check if a user has already rated a specific booking.
  Future<bool> hasRated(String bookingId, String type) async {
    if (!SupabaseService.isConfigured) return false;
    final supabase = Supabase.instance.client;
    final res = await supabase
        .from('ratings')
        .select('id')
        .eq('order_id', bookingId)
        .eq('rater_id', AuthService().currentUserId ?? '')
        .eq('type', type)
        .maybeSingle();
    return res != null;
  }
}
