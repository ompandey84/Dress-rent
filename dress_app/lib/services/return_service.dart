import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:dress_app/services/auth_service.dart';
import 'package:dress_app/models/booking.dart';

/// Service for damage claims, returns, and disputes.
class ReturnService {
  static final ReturnService _instance = ReturnService._internal();
  factory ReturnService() => _instance;
  ReturnService._internal();

  /// Submit a damage claim (lender raises it).
  Future<Map<String, dynamic>> submitDamageClaim({
    required Booking booking,
    required String type, // 'damage', 'lost', 'late_return'
    required String description,
    required double amountClaimed,
    required List<String> photoUrls,
  }) async {
    if (!SupabaseService.isConfigured) {
      return {
        'id': 'claim-${DateTime.now().millisecondsSinceEpoch}',
        'status': 'submitted',
      };
    }
    final supabase = Supabase.instance.client;
    final res = await supabase.from('damage_claims').insert({
      'booking_id': booking.id,
      'raised_by': AuthService().currentUserId,
      'type': type,
      'description': description,
      'amount_claimed': amountClaimed,
      'photos': photoUrls,
      'status': 'submitted',
    }).select().single();
    return res;
  }

  /// Renter responds to a damage claim (accepts or disputes).
  Future<bool> respondToClaim({
    required String claimId,
    required String response, // 'accept' or 'dispute'
    String? disputeReason,
  }) async {
    if (!SupabaseService.isConfigured) return true;
    final supabase = Supabase.instance.client;
    if (response == 'accept') {
      await supabase.from('damage_claims').update({
        'status': 'approved',
      }).eq('id', claimId);
    } else {
      await supabase.from('disputes').insert({
        'claim_id': claimId,
        'raised_by': AuthService().currentUserId,
        'reason': 'Damage claim disputed',
        'description': disputeReason,
        'status': 'open',
      });
      await supabase.from('damage_claims').update({
        'status': 'disputed',
      }).eq('id', claimId);
    }
    return true;
  }

  /// Mark return QC as complete.
  Future<bool> completeReturn({
    required String bookingId,
    required bool hasDamage,
    double? damageAmount,
  }) async {
    if (!SupabaseService.isConfigured) return true;
    final supabase = Supabase.instance.client;
    await supabase.from('orders').update({
      'status': 'returned',
      'returned_at': DateTime.now().toIso8601String(),
    }).eq('id', bookingId);
    return true;
  }

  /// Calculate late fee for a booking.
  double calculateLateFee({required Booking booking, required int daysLate}) {
    // Default: 50% of daily rate per late day
    return (booking.rentalFee / booking.rentalDays * 0.5) * daysLate;
  }
}
