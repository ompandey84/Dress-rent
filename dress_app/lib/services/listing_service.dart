import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:dress_app/services/auth_service.dart';
import 'package:dress_app/services/storage_service.dart';
import 'package:dress_app/models/listing_draft.dart';

/// Persists lender listings. Falls back to in-memory mock when Supabase
/// is not configured.
class ListingService {
  static final ListingService _instance = ListingService._internal();
  factory ListingService() => _instance;
  ListingService._internal();

  final List<Map<String, dynamic>> _mockListings = [];

  /// Submit a draft for admin review.
  /// Writes to the `products` table (vendor_id-based, per the live schema).
  Future<Map<String, dynamic>> submitForReview(ListingDraft draft) async {
    if (!SupabaseService.isConfigured) {
      // Mock: simulate review submission
      final id = 'mock_listing_${DateTime.now().millisecondsSinceEpoch}';
      final record = <String, dynamic>{
        'id': id,
        'vendor_id': AuthService().currentUserId ?? 'mock_user',
        'title': draft.title,
        'description': draft.description,
        'category': draft.category,
        'gender': draft.gender,
        'occasion': draft.occasion,
        'condition': draft.condition,
        'sizes': draft.sizes.toList(),
        'color': draft.color,
        'fabric': draft.fabric,
        'rental_price': draft.pricePerDay,
        'security_deposit': draft.securityDeposit,
        'insurance_fee': draft.insuranceFee,
        'min_days': draft.minDays,
        'max_days': draft.maxDays,
        'pickup_method': draft.pickupMethod,
        'status': 'pending',
        'images': draft.photos.map((f) => f.path).toList(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      _mockListings.add(record);
      await Future.delayed(const Duration(milliseconds: 800));
      return record;
    }

    final supabase = Supabase.instance.client;
    final userId = AuthService().currentUserId;

    // Resolve vendor row for this user
    String? vendorId;
    try {
      final v = await supabase
          .from('vendors')
          .select('id')
          .eq('user_id', userId ?? '')
          .maybeSingle();
      vendorId = v?['id'] as String?;
      if (vendorId == null) {
        // Auto-create a vendor row so the product insert has a parent
        final v2 = await supabase.from('vendors').insert({
          'user_id': userId,
          'shop_name': 'My Shop',
          'status': 'approved',
        }).select().single();
        vendorId = v2['id'] as String;
      }
    } catch (_) {}

    // Upload photos first
    final photoUrls = <String>[];
    final storage = StorageService();
    for (var i = 0; i < draft.photos.length; i++) {
      try {
        final url = await storage.uploadProductImage(
          draft.photos[i],
          'draft_${DateTime.now().millisecondsSinceEpoch}_$i',
        );
        photoUrls.add(url);
      } catch (_) {
        // fallback: store the local path
        photoUrls.add(draft.photos[i].path);
      }
    }

    final pickupAddress = {
      'line1': draft.pickupAddressLine1,
      'line2': draft.pickupAddressLine2,
      'city': draft.pickupCity,
      'state': draft.pickupState,
      'pincode': draft.pickupPincode,
      'landmark': draft.landmark,
    };

    final record = await supabase.from('products').insert({
      'vendor_id': vendorId,
      'title': draft.title,
      'description': draft.description,
      'category': draft.category,
      'gender': draft.gender,
      'occasion': draft.occasion,
      'condition': draft.condition,
      'color': draft.color,
      'fabric': draft.fabric,
      'sizes': draft.sizes.toList(),
      'rental_price': draft.pricePerDay,
      'security_deposit': draft.securityDeposit,
      'insurance_fee': draft.insuranceFee,
      'min_days': draft.minDays,
      'max_days': draft.maxDays,
      'pickup_method': draft.pickupMethod,
      'pickup_address': pickupAddress,
      'images': photoUrls,
      'status': 'pending',  // admin approval required
      'is_verified': false,
    }).select().single();

    return record;
  }

  /// Get all listings for current lender.
  Future<List<Map<String, dynamic>>> myListings() async {
    if (!SupabaseService.isConfigured) return List.of(_mockListings);
    final supabase = Supabase.instance.client;
    final userId = AuthService().currentUserId ?? '';
    // Resolve vendor_id first
    final v = await supabase
        .from('vendors')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (v == null) return [];
    final res = await supabase
        .from('products')
        .select()
        .eq('vendor_id', v['id'] as String)
        .order('created_at', ascending: false);
    return List.of((res as List).cast<Map<String, dynamic>>());
  }

  /// Get a single listing by id.
  Future<Map<String, dynamic>?> getListing(String id) async {
    if (!SupabaseService.isConfigured) {
      try {
        return _mockListings.firstWhere((l) => l['id'] == id);
      } catch (_) {
        return null;
      }
    }
    final supabase = Supabase.instance.client;
    final res = await supabase
        .from('products')
        .select()
        .eq('id', id)
        .maybeSingle();
    return res;
  }
}
