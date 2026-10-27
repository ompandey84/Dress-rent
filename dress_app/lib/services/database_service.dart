import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/services/mock_data_service.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:dress_app/services/auth_service.dart';
import 'package:dress_app/models/product.dart';
import 'package:dress_app/models/order.dart';
import 'package:dress_app/models/notification_item.dart';
import 'package:dress_app/models/user_profile.dart';
import 'package:dress_app/models/address.dart';

/// Backend adapter. Reads from the live Supabase tables when configured,
/// otherwise falls back to `MockDataService`.
///
/// Schema (per `0001_full_schema.sql`):
///   profiles, addresses, products, vendors, orders, cart_items,
///   wishlist, ratings, support_tickets, vendor_bookings, etc.
class DatabaseService {
  String? get currentUserId =>
      AuthService().currentUserId ?? 'mock-user-id';

  // ==========================================
  // PROFILES & SETTINGS
  // ==========================================

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    if (!SupabaseService.isConfigured) {
      final u = MockDataService.currentUser;
      return {
        'id': u.id,
        'full_name': u.name,
        'email': u.email,
        'phone': u.phone,
        'avatar_url': u.avatarUrl,
        'is_vendor': u.isVendor,
        'rating': u.rating,
        'reviews_count': u.reviewsCount,
      };
    }
    try {
      final res = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return res;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (!SupabaseService.isConfigured) return;
    final uid = AuthService().currentUserId;
    if (uid == null) return;
    await Supabase.instance.client
        .from('profiles')
        .update(data)
        .eq('id', uid);
  }

  Future<Map<String, dynamic>?> getSettings() async {
    return {'theme': 'light', 'notifications_enabled': true};
  }

  Future<void> updateSettings(Map<String, dynamic> data) async {
    if (!SupabaseService.isConfigured) return;
    final uid = AuthService().currentUserId;
    if (uid == null) return;
    await Supabase.instance.client
        .from('user_settings')
        .upsert({'user_id': uid, ...data}, onConflict: 'user_id');
  }

  // ==========================================
  // ADDRESSES
  // ==========================================

  Future<List<Map<String, dynamic>>> getAddresses() async {
    if (!SupabaseService.isConfigured) {
      return MockDataService.currentUser.addresses
          .map((a) => {
                'id': a.id,
                'label': a.label,
                'full_name': a.fullName,
                'phone': a.phone,
                'street': a.street,
                'city': a.city,
                'zip_code': a.zipCode,
                'is_default': a.isDefault,
              })
          .toList();
    }
    final uid = AuthService().currentUserId;
    if (uid == null) return [];
    final res = await Supabase.instance.client
        .from('addresses')
        .select()
        .eq('user_id', uid)
        .order('is_default', ascending: false);
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> addAddress(Map<String, dynamic> address) async {
    if (!SupabaseService.isConfigured) {
      return {...address, 'id': 'addr-${DateTime.now().millisecondsSinceEpoch}'};
    }
    final uid = AuthService().currentUserId;
    final res = await Supabase.instance.client
        .from('addresses')
        .insert({'user_id': uid, ...address})
        .select()
        .single();
    return res;
  }

  Future<void> updateAddress(String id, Map<String, dynamic> address) async {
    if (!SupabaseService.isConfigured) return;
    await Supabase.instance.client
        .from('addresses')
        .update(address)
        .eq('id', id);
  }

  Future<void> deleteAddress(String id) async {
    if (!SupabaseService.isConfigured) return;
    await Supabase.instance.client
        .from('addresses')
        .delete()
        .eq('id', id);
  }

  // ==========================================
  // PRODUCTS & SEARCH
  // ==========================================

  Future<List<Map<String, dynamic>>> getProducts({
    String? categoryId,
    String? brandId,
    String? sortBy,
    int limit = 20,
    int offset = 0,
  }) async {
    if (!SupabaseService.isConfigured) {
      final products = MockDataService.mockProducts;
      final list = products.map((p) => _productToMap(p)).toList();
      if (offset >= list.length) return [];
      final end = (offset + limit).clamp(0, list.length);
      return list.sublist(offset, end);
    }
    // Live schema: products has store_id (not vendor_id), no `status` column
    // (uses `is_active`), no `product_colors` table. We do a safe, narrow
    // select so the home screen never crashes on missing relations.
    try {
      final res = await Supabase.instance.client
          .from('products')
          .select('''
            *,
            stores:store_id(id, shop_name, name, location, is_verified),
            product_images(image_url, display_order),
            product_sizes(size, quantity, available_quantity)
          ''')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      final list = (res as List).cast<Map<String, dynamic>>();
      if (list.isEmpty && offset == 0) {
        final products = MockDataService.mockProducts;
        final mockList = products.map((p) => _productToMap(p)).toList();
        final end = limit.clamp(0, mockList.length);
        return mockList.sublist(0, end);
      }
      return list;
    } catch (e) {
      // Schema mismatch or RLS issue — fall back to bare select so the
      // home screen can still render something instead of "Error loading products".
      try {
        final res = await Supabase.instance.client
            .from('products')
            .select('*')
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
        final list = (res as List).cast<Map<String, dynamic>>();
        if (list.isEmpty && offset == 0) {
          final products = MockDataService.mockProducts;
          final mockList = products.map((p) => _productToMap(p)).toList();
          final end = limit.clamp(0, mockList.length);
          return mockList.sublist(0, end);
        }
        return list;
      } catch (_) {
        if (offset == 0) {
          final products = MockDataService.mockProducts;
          final mockList = products.map((p) => _productToMap(p)).toList();
          final end = limit.clamp(0, mockList.length);
          return mockList.sublist(0, end);
        }
        return [];
      }
    }
  }

  Future<Map<String, dynamic>> getProductDetails(String productId) async {
    if (!SupabaseService.isConfigured) {
      final p = MockDataService.mockProducts.firstWhere(
        (x) => x.id == productId,
        orElse: () => MockDataService.mockProducts.first,
      );
      return _productToMap(p);
    }
    try {
      final res = await Supabase.instance.client
          .from('products')
          .select('''
            *,
            stores:store_id(id, shop_name, name, location, is_verified),
            product_images(image_url, display_order),
            product_sizes(size, quantity, available_quantity)
          ''')
          .eq('id', productId)
          .maybeSingle();
      return res ?? {};
    } catch (_) {
      // Fallback: bare select
      try {
        final res = await Supabase.instance.client
            .from('products')
            .select('*')
            .eq('id', productId)
            .maybeSingle();
        return res ?? {};
      } catch (_) {
        return {};
      }
    }
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final q = query.toLowerCase();
    if (!SupabaseService.isConfigured) {
      return MockDataService.mockProducts
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q))
          .map((p) => _productToMap(p))
          .toList();
    }
    // Search across title / description / category. Supabase's
    // text-search or() filter is unavailable in the JS-style query
    // builder, so we run two simpler queries and merge.
    final client = Supabase.instance.client;
    final selectStr = '''
      *,
      stores:store_id(id, shop_name, name, location, is_verified),
      product_images(image_url, display_order),
      product_sizes(size, quantity, available_quantity)
    ''';
    try {
      final byTitle = await client
          .from('products')
          .select(selectStr)
          .ilike('name', '%$q%')
          .eq('is_active', true)
          .limit(50);
      final byDesc = await client
          .from('products')
          .select(selectStr)
          .ilike('description', '%$q%')
          .eq('is_active', true)
          .limit(50);
      final merged = <String, Map<String, dynamic>>{};
      for (final list in [byTitle, byDesc]) {
        for (final row in (list as List)) {
          final m = Map<String, dynamic>.from(row as Map);
          final id = (m['id'] ?? '').toString();
          if (id.isNotEmpty) merged[id] = m;
        }
      }
      return merged.values.take(50).toList();
    } catch (_) {
      // Bare fallback
      try {
        final res = await client
            .from('products')
            .select('*')
            .ilike('name', '%$q%')
            .eq('is_active', true)
            .limit(50);
        return (res as List).cast<Map<String, dynamic>>();
      } catch (_) {
        return [];
      }
    }
  }

  Map<String, dynamic> _productToMap(Product p) {
    return {
      'id': p.id,
      'store_id': p.storeId,
      'category_id': p.categoryId,
      'brand_id': p.brandId,
      'name': p.name,
      'title': p.name,
      'category': p.category,
      'rental_price_per_day': p.rentalPricePerDay,
      'original_price': p.originalPrice,
      'security_deposit': p.securityDeposit,
      'description': p.description,
      'gender': p.gender,
      'rating': p.rating,
      'reviews_count': p.reviewsCount,
      'ar_model_url': p.arModelUrl,
      'video_url': p.videoUrl,
      'available_from': p.availableFrom?.toIso8601String(),
      'available_until': p.availableUntil?.toIso8601String(),
      'product_images': p.images
          .asMap()
          .entries
          .map((e) => {'image_url': e.value, 'display_order': e.key})
          .toList(),
      'product_sizes': p.sizes
          .map((s) => {'size': s, 'quantity': 5, 'available_quantity': 5})
          .toList(),
      'product_colors': p.colors.map((c) => {'color_name': c}).toList(),
      'stores': {
        'id': p.storeId,
        'name': p.storeName,
        'is_verified': p.isVerifiedStore,
        'location': p.location,
      },
    };
  }

  // ==========================================
  // CART
  // ==========================================

  Stream<List<Map<String, dynamic>>> getCartStream() {
    final uid = AuthService().currentUserId;
    if (uid == null) return Stream.value([]);
    if (!SupabaseService.isConfigured) {
      return Stream.value([]);
    }
    return Supabase.instance.client
        .from('cart_items')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .map((rows) => rows.cast<Map<String, dynamic>>());
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final uid = AuthService().currentUserId;
    if (uid == null) return [];
    if (!SupabaseService.isConfigured) return [];
    final res = await Supabase.instance.client
        .from('cart_items')
        .select('*, products(*)')
        .eq('user_id', uid);
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<void> addToCart(Map<String, dynamic> item) async {
    if (!SupabaseService.isConfigured) return;
    final uid = AuthService().currentUserId;
    if (uid == null) return;
    await Supabase.instance.client.from('cart_items').insert({
      'user_id': uid,
      ...item,
    });
  }

  Future<void> removeFromCart(String cartItemId) async {
    if (!SupabaseService.isConfigured) return;
    await Supabase.instance.client
        .from('cart_items')
        .delete()
        .eq('id', cartItemId);
  }

  Future<void> updateCartQuantity(String cartItemId, int quantity) async {
    if (!SupabaseService.isConfigured) return;
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }
    await Supabase.instance.client
        .from('cart_items')
        .update({'quantity': quantity})
        .eq('id', cartItemId);
  }

  Future<void> clearCart() async {
    if (!SupabaseService.isConfigured) return;
    final uid = AuthService().currentUserId;
    if (uid == null) return;
    await Supabase.instance.client
        .from('cart_items')
        .delete()
        .eq('user_id', uid);
  }

  Future<void> lockCartInventory() async {
    // Placeholder for inventory lock when payment intent is created.
    return;
  }

  // ==========================================
  // WISHLIST  (writes also live here so the heart-icon stays in sync)
  // ==========================================

  Future<List<Map<String, dynamic>>> getWishlist() async {
    final uid = AuthService().currentUserId;
    if (uid == null) return [];
    if (!SupabaseService.isConfigured) return [];
    final res = await Supabase.instance.client
        .from('wishlist')
        .select('product_id, products(*)')
        .eq('user_id', uid)
        .order('created_at', ascending: false);
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<void> toggleWishlist(String productId) async {
    final uid = AuthService().currentUserId;
    if (uid == null) return;
    if (!SupabaseService.isConfigured) return;
    final existing = await Supabase.instance.client
        .from('wishlist')
        .select('id')
        .eq('user_id', uid)
        .eq('product_id', productId)
        .maybeSingle();
    if (existing != null) {
      await Supabase.instance.client
          .from('wishlist')
          .delete()
          .eq('id', existing['id']);
    } else {
      await Supabase.instance.client.from('wishlist').insert({
        'user_id': uid,
        'product_id': productId,
      });
    }
  }

  // ==========================================
  // ORDERS
  // ==========================================

  Future<List<Map<String, dynamic>>> getMyOrders() async {
    if (!SupabaseService.isConfigured) {
      return MockDataService.mockOrders
          .map((o) => {
                'id': o.id,
                'order_number': o.id,
                'user_id': o.userId,
                'store_id': o.storeId,
                'created_at': o.createdAt.toIso8601String(),
                'subtotal': o.subtotal,
                'delivery_fee': o.deliveryFee,
                'security_deposit': o.securityDeposit,
                'discount': o.discount,
                'total': o.totalPrice,
                'status': o.status.name == 'outForDelivery'
                    ? 'out_for_delivery'
                    : o.status.name,
                'image_url': o.imageUrl,
                'order_items': [
                  {
                    'product_image_url': o.imageUrl,
                    'quantity': o.itemsCount,
                  }
                ],
              })
          .toList();
    }
    final uid = AuthService().currentUserId;
    if (uid == null || uid.isEmpty) return [];
    final res = await Supabase.instance.client
        .from('orders')
        .select('*, order_items(*)')
        .eq('buyer_id', uid)
        .order('created_at', ascending: false);
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    if (!SupabaseService.isConfigured) {
      final o = MockDataService.mockOrders.firstWhere(
        (x) => x.id == orderId,
        orElse: () => MockDataService.mockOrders.first,
      );
      return {
        'id': o.id,
        'order_number': o.id,
        'status': o.status.name,
        'total': o.totalPrice,
      };
    }
    final res = await Supabase.instance.client
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', orderId)
        .maybeSingle();
    return res ?? {};
  }

  Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData, List<Map<String, dynamic>> items) async {
    if (!SupabaseService.isConfigured) {
      return {...orderData, 'id': 'ORD-${DateTime.now().millisecondsSinceEpoch}'};
    }
    final res = await Supabase.instance.client
        .from('orders')
        .insert(orderData)
        .select()
        .single();
    return res;
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    if (!SupabaseService.isConfigured) return;
    final uid = AuthService().currentUserId;
    await Supabase.instance.client.from('orders').update({
      'status': 'cancelled',
      'cancellation_reason': reason,
      'cancelled_at': DateTime.now().toIso8601String(),
      'cancelled_by': uid,
    }).eq('id', orderId);
  }

  Future<void> requestRentalExtension(String orderId, String newEndDate) async {
    if (!SupabaseService.isConfigured) return;
    await Supabase.instance.client.from('orders').update({
      'requested_end_date': newEndDate,
      'extension_status': 'requested',
    }).eq('id', orderId);
  }

  Future<void> requestReturn(String orderId, String reason) async {
    if (!SupabaseService.isConfigured) return;
    await Supabase.instance.client.from('orders').update({
      'status': 'return_scheduled',
      'return_reason': reason,
    }).eq('id', orderId);
  }

  Future<Map<String, dynamic>> requestEarlyPickup(
      String orderId, String reason, String notes) async {
    if (!SupabaseService.isConfigured) {
      return {'id': 'mock-req-${DateTime.now().millisecondsSinceEpoch}'};
    }
    final res = await Supabase.instance.client
        .from('early_pickup_requests')
        .insert({
          'order_id': orderId,
          'requester_id': currentUserId,
          'reason': reason,
          'notes': notes,
          'status': 'submitted',
        })
        .select()
        .single();
    return res;
  }

  Future<void> addEarlyPickupPhoto(String requestId, String photoUrl) async {
    if (!SupabaseService.isConfigured) return;
    final res = await Supabase.instance.client
        .from('early_pickup_requests')
        .select('photos')
        .eq('id', requestId)
        .maybeSingle();
    final existing =
        (res?['photos'] as List?)?.cast<String>().toList() ?? <String>[];
    existing.add(photoUrl);
    await Supabase.instance.client
        .from('early_pickup_requests')
        .update({'photos': existing}).eq('id', requestId);
  }

  // ==========================================
  // CHAT
  // ==========================================

  Stream<List<Map<String, dynamic>>> getChatRoomsStream() {
    final uid = AuthService().currentUserId;
    if (uid == null) return Stream.value([]);
    if (!SupabaseService.isConfigured) return Stream.value([]);
    // No `.or()` on streams; fall back to filtering the raw stream.
    return Supabase.instance.client
        .from('chat_rooms')
        .stream(primaryKey: ['id'])
        .map((rows) => (rows as List)
            .cast<Map<String, dynamic>>()
            .where((r) => r['buyer_id'] == uid || r['lender_id'] == uid)
            .toList());
  }

  Stream<List<Map<String, dynamic>>> getChatMessagesStream(String roomId) {
    if (!SupabaseService.isConfigured) return Stream.value([]);
    return Supabase.instance.client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map((rows) => rows.cast<Map<String, dynamic>>());
  }

  Future<void> sendMessage(String roomId, String text,
      [String? fileUrl, String? fileType]) async {
    if (!SupabaseService.isConfigured) return;
    final uid = AuthService().currentUserId;
    await Supabase.instance.client.from('chat_messages').insert({
      'room_id': roomId,
      'sender_id': uid,
      'text': text,
      if (fileUrl != null) 'file_url': fileUrl,
      if (fileType != null) 'file_type': fileType,
    });
  }

  // ==========================================
  // AI
  // ==========================================

  Future<Map<String, dynamic>> createAiSession(String title) async {
    if (!SupabaseService.isConfigured) {
      return {
        'id': 'ai-${DateTime.now().millisecondsSinceEpoch}',
        'title': title,
      };
    }
    final res = await Supabase.instance.client
        .from('ai_sessions')
        .insert({'title': title, 'user_id': currentUserId})
        .select()
        .single();
    return res;
  }

  Future<void> sendAiMessage(
      String sessionId, String userMessage, String assistantResponse) async {
    if (!SupabaseService.isConfigured) return;
    await Supabase.instance.client.from('ai_messages').insert({
      'session_id': sessionId,
      'user_message': userMessage,
      'assistant_response': assistantResponse,
    });
  }

  Future<List<Map<String, dynamic>>> getAiMessages(String sessionId) async {
    if (!SupabaseService.isConfigured) return [];
    final res = await Supabase.instance.client
        .from('ai_messages')
        .select()
        .eq('session_id', sessionId)
        .order('created_at');
    return (res as List).cast<Map<String, dynamic>>();
  }

  // ==========================================
  // REVIEWS & FEEDBACK
  // ==========================================

  Future<void> submitProductReview(Map<String, dynamic> reviewData) async {
    if (!SupabaseService.isConfigured) return;
    await Supabase.instance.client
        .from('product_reviews')
        .insert(reviewData);
  }

  Future<List<Map<String, dynamic>>> getProductReviews(String productId) async {
    if (!SupabaseService.isConfigured) return [];
    final res = await Supabase.instance.client
        .from('product_reviews')
        .select('*, profiles:reviewer_id(full_name, avatar_url)')
        .eq('product_id', productId)
        .order('created_at', ascending: false);
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<void> submitAppFeedback(int rating, String feedbackText) async {
    if (!SupabaseService.isConfigured) return;
    await Supabase.instance.client.from('app_feedback').insert({
      'user_id': currentUserId,
      'rating': rating,
      'feedback': feedbackText,
    });
  }

  // ==========================================
  // VENDOR
  // ==========================================

  Future<Map<String, dynamic>> createVendorProfile(
      Map<String, dynamic> profileData, Map<String, dynamic> bankData) async {
    if (!SupabaseService.isConfigured) {
      return {...profileData, ...bankData, 'id': 'v1'};
    }
    final uid = AuthService().currentUserId;
    final res = await Supabase.instance.client
        .from('vendors')
        .insert({'user_id': uid, ...profileData})
        .select()
        .single();
    if (bankData.isNotEmpty) {
      await Supabase.instance.client.from('vendor_bank_details').insert({
        'vendor_id': res['id'],
        ...bankData,
      });
    }
    return res;
  }

  Future<Map<String, dynamic>?> getVendorAnalytics() async {
    if (!SupabaseService.isConfigured) {
      return {
        'total_revenue': 452000.0,
        'total_orders': 47,
        'active_listings': MockDataService.mockProducts.length,
        'pending_returns': 5,
        'this_month': 85000.0,
        'pending_amount': 32000.0,
      };
    }
    final uid = AuthService().currentUserId;
    if (uid == null) return null;
    // Sum rental + insurance fees for completed orders belonging to this vendor.
    final orders = await Supabase.instance.client
        .from('orders')
        .select('total_amount, status, vendor_id')
        .eq('vendor_id', uid);
    final all = (orders as List).cast<Map<String, dynamic>>();
    final revenue = all
        .where((o) => o['status'] == 'completed' || o['status'] == 'returned')
        .fold<double>(0, (s, o) => s + (o['total_amount'] as num? ?? 0));
    final activeListings = await Supabase.instance.client
        .from('products')
        .select('id')
        .eq('vendor_id', uid)
        .eq('status', 'approved');
    return {
      'total_revenue': revenue,
      'total_orders': all.length,
      'active_listings': (activeListings as List).length,
      'pending_returns': all.where((o) => o['status'] == 'return_scheduled').length,
    };
  }

  Future<List<Map<String, dynamic>>> getVendorBookings() async {
    if (!SupabaseService.isConfigured) return [];
    final uid = AuthService().currentUserId;
    if (uid == null) return [];
    final res = await Supabase.instance.client
        .from('orders')
        .select('*, products:product_id(title, images)')
        .eq('vendor_id', uid)
        .order('created_at', ascending: false);
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<void> updateVendorBookingStatus(
      String bookingId, String newStatus, String orderId) async {
    if (!SupabaseService.isConfigured) return;
    await Supabase.instance.client
        .from('orders')
        .update({'status': newStatus})
        .eq('id', orderId);
  }
}
