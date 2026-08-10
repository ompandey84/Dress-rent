import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:dress_app/services/mock_data_service.dart';
import 'package:dress_app/models/product.dart';

/// Wishlist service. Falls back to in-memory mock when Supabase isn't configured.
///
/// In live mode, reads/writes the `wishlist` table which references
/// `products.id` (per the live Supabase schema).
class WishlistService {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  // In-memory fallback for mock mode
  final Set<String> _mockWishlist = {};

  bool get _isReal => SupabaseService.isConfigured;

  /// Get all wishlisted products for the current user.
  Future<List<Product>> getWishlist(String userId) async {
    // Guest users have no real id — don't try to query Supabase
    if (userId.isEmpty || !_isReal) {
      return MockDataService.mockProducts
          .where((p) => _mockWishlist.contains(p.id))
          .toList();
    }
    // Live mode: select wishlist rows joined to products.
    final res = await SupabaseService.client
        .from('wishlist')
        .select('product_id, products(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (res as List)
        .map((row) {
          final product = row['products'];
          if (product == null) return null;
          return Product.fromJson(Map<String, dynamic>.from(product));
        })
        .whereType<Product>()
        .toList();
  }

  /// Get all wishlisted product IDs.
  Future<List<String>> getWishlistIds(String userId) async {
    if (userId.isEmpty || !_isReal) {
      return _mockWishlist.toList();
    }
    final res = await SupabaseService.client
        .from('wishlist')
        .select('product_id')
        .eq('user_id', userId);
    return (res as List)
        .map((row) => row['product_id'] as String)
        .toList();
  }

  /// Check if a product is in the user's wishlist.
  Future<bool> isWishlisted(String userId, String productId) async {
    if (userId.isEmpty || !_isReal) {
      return _mockWishlist.contains(productId);
    }
    final res = await SupabaseService.client
        .from('wishlist')
        .select('id')
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();
    return res != null;
  }

  /// Add a product to the wishlist. Uses upsert to avoid race-condition dupes.
  Future<void> addToWishlist(String userId, String productId) async {
    if (userId.isEmpty || !_isReal) {
      _mockWishlist.add(productId);
      return;
    }
    await SupabaseService.client.from('wishlist').upsert(
      {'user_id': userId, 'product_id': productId},
      onConflict: 'user_id,product_id',
    );
  }

  /// Remove a product from the wishlist.
  Future<void> removeFromWishlist(String userId, String productId) async {
    if (userId.isEmpty || !_isReal) {
      _mockWishlist.remove(productId);
      return;
    }
    await SupabaseService.client
        .from('wishlist')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }

  /// Toggle: add if not present, remove if present. Returns the new state.
  Future<bool> toggle(String userId, String productId) async {
    if (userId.isEmpty || !_isReal) {
      final had = _mockWishlist.contains(productId);
      if (had) {
        _mockWishlist.remove(productId);
      } else {
        _mockWishlist.add(productId);
      }
      return !had;
    }
    final isW = await isWishlisted(userId, productId);
    if (isW) {
      await removeFromWishlist(userId, productId);
      return false;
    } else {
      await addToWishlist(userId, productId);
      return true;
    }
  }
}
