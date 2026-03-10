import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/services/supabase_service.dart';

class DatabaseService {
  final SupabaseClient _supabase = SupabaseService.client;
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // ==========================================
  // PROFILES & SETTINGS
  // ==========================================

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final res = await _supabase.from('profiles').select().eq('id', userId).single();
      return res;
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');
    
    try {
      await _supabase.from('profiles').update(data).eq('id', uid);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getSettings() async {
    final uid = currentUserId;
    if (uid == null) return null;
    
    try {
      return await _supabase.from('user_settings').select().eq('user_id', uid).single();
    } catch (e) {
      return null;
    }
  }

  Future<void> updateSettings(Map<String, dynamic> data) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');
    
    try {
      await _supabase.from('user_settings').update(data).eq('user_id', uid);
    } catch (e) {
      throw Exception('Failed to update settings: $e');
    }
  }

  // ==========================================
  // ADDRESSES
  // ==========================================

  Future<List<Map<String, dynamic>>> getAddresses() async {
    final uid = currentUserId;
    if (uid == null) return [];

    try {
      final res = await _supabase.from('addresses').select().eq('user_id', uid).order('is_default', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw Exception('Failed to fetch addresses: $e');
    }
  }

  Future<Map<String, dynamic>> addAddress(Map<String, dynamic> address) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');
    address['user_id'] = uid;

    try {
      if (address['is_default'] == true) {
        // Unset other defaults
        await _supabase.from('addresses').update({'is_default': false}).eq('user_id', uid);
      }
      final res = await _supabase.from('addresses').insert(address).select().single();
      return res;
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  Future<void> updateAddress(String id, Map<String, dynamic> address) async {
    try {
      if (address['is_default'] == true) {
        await _supabase.from('addresses').update({'is_default': false}).eq('user_id', currentUserId!);
      }
      await _supabase.from('addresses').update(address).eq('id', id);
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _supabase.from('addresses').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
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
    try {
      var query = _supabase.from('products').select('''
        *,
        product_images(image_url),
        stores(name, is_verified)
      ''').eq('is_active', true);

      if (categoryId != null) query = query.eq('category_id', categoryId);
      if (brandId != null) query = query.eq('brand_id', brandId);

      if (sortBy == 'price_asc') {
        query = query.order('rental_price_per_day', ascending: true);
      } else if (sortBy == 'price_desc') {
        query = query.order('rental_price_per_day', ascending: false);
      } else if (sortBy == 'popular') {
        query = query.order('total_rentals', ascending: false);
      } else {
        query = query.order('created_at', ascending: false);
      }

      final res = await query.range(offset, offset + limit - 1);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<Map<String, dynamic>> getProductDetails(String productId) async {
    try {
      final res = await _supabase.from('products').select('''
        *,
        product_images(image_url, display_order),
        product_sizes(size, quantity, available_quantity),
        product_colors(color_name, color_hex),
        stores(*),
        categories(name, slug),
        brands(name, slug)
      ''').eq('id', productId).single();
      return res;
    } catch (e) {
      throw Exception('Failed to fetch product details: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      // Save search history
      final uid = currentUserId;
      if (uid != null) {
        await _supabase.from('search_history').insert({'user_id': uid, 'query': query});
      }

      final res = await _supabase.from('products').select('''
        *,
        product_images(image_url)
      ''').ilike('name', '%$query%').eq('is_active', true).limit(20);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // ==========================================
  // CART & CHECKOUT
  // ==========================================

  Stream<List<Map<String, dynamic>>> getCartStream() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    return _supabase.from('cart_items').stream(primaryKey: ['id']).eq('user_id', uid);
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final uid = currentUserId;
    if (uid == null) return [];

    try {
      final res = await _supabase.from('cart_items').select('''
        *,
        products(name, rental_price_per_day, product_images(image_url))
      ''').eq('user_id', uid);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw Exception('Failed to fetch cart: $e');
    }
  }

  Future<void> addToCart(Map<String, dynamic> item) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');
    item['user_id'] = uid;

    try {
      await _supabase.from('cart_items').insert(item);
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _supabase.from('cart_items').delete().eq('id', cartItemId);
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }

  Future<void> updateCartQuantity(String cartItemId, int quantity) async {
    try {
      await _supabase.from('cart_items').update({'quantity': quantity}).eq('id', cartItemId);
    } catch (e) {
      throw Exception('Failed to update quantity: $e');
    }
  }
  
  Future<void> clearCart() async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');
    try {
      await _supabase.from('cart_items').delete().eq('user_id', uid);
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // Check inventory lock (logic for 10-min countdown timer)
  Future<void> lockCartInventory() async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');
    try {
      final lockedUntil = DateTime.now().add(const Duration(minutes: 10)).toIso8601String();
      await _supabase.from('cart_items').update({'locked_until': lockedUntil}).eq('user_id', uid);
    } catch (e) {
      throw Exception('Failed to lock inventory: $e');
    }
  }

  // ==========================================
  // WISHLIST
  // ==========================================

  Future<List<Map<String, dynamic>>> getWishlist() async {
    final uid = currentUserId;
    if (uid == null) return [];

    try {
      final res = await _supabase.from('wishlist').select('''
        product_id,
        products(*, product_images(image_url))
      ''').eq('user_id', uid).order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw Exception('Failed to fetch wishlist: $e');
    }
  }

  Future<void> toggleWishlist(String productId) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    try {
      final res = await _supabase.from('wishlist')
          .select('id')
          .eq('user_id', uid)
          .eq('product_id', productId)
          .maybeSingle();

      if (res != null) {
        // Exists, remove it
        await _supabase.from('wishlist').delete().eq('id', res['id']);
      } else {
        // Doesn't exist, add it
        await _supabase.from('wishlist').insert({'user_id': uid, 'product_id': productId});
      }
    } catch (e) {
      throw Exception('Failed to toggle wishlist: $e');
    }
  }

  // ==========================================
  // ORDERS & TRACKING
  // ==========================================

  Future<List<Map<String, dynamic>>> getMyOrders() async {
    final uid = currentUserId;
    if (uid == null) return [];

    try {
      final res = await _supabase.from('orders').select('''
        *,
        order_items(*),
        stores(name)
      ''').eq('user_id', uid).order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final res = await _supabase.from('orders').select('''
        *,
        order_items(*),
        addresses(*),
        stores(*)
      ''').eq('id', orderId).single();
      return res;
    } catch (e) {
      throw Exception('Failed to fetch order details: $e');
    }
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData, List<Map<String, dynamic>> items) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');
    
    orderData['user_id'] = uid;
    
    try {
      // 1. Create order
      final orderRes = await _supabase.from('orders').insert(orderData).select().single();
      final orderId = orderRes['id'];

      // 2. Create items
      for (var item in items) {
        item['order_id'] = orderId;
      }
      await _supabase.from('order_items').insert(items);
      
      // 3. Clear cart
      await clearCart();
      
      return orderRes;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Order Actions
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await _supabase.from('orders').update({
        'status': 'cancelled',
        'cancellation_reason': reason,
        'cancelled_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  Future<void> requestRentalExtension(String orderId, String newEndDate) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    try {
      // First get order details to verify dates
      final order = await _supabase.from('orders').select('rental_end_date').eq('id', orderId).single();
      
      await _supabase.from('rental_extensions').insert({
        'order_id': orderId,
        'user_id': uid,
        'original_end_date': order['rental_end_date'],
        'new_end_date': newEndDate,
        'status': 'pending',
      });
    } catch (e) {
      throw Exception('Failed to request extension: $e');
    }
  }

  Future<void> requestReturn(String orderId, String reason) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    try {
      await _supabase.from('return_requests').insert({
        'order_id': orderId,
        'user_id': uid,
        'reason': reason,
      });
    } catch (e) {
      throw Exception('Failed to request return: $e');
    }
  }

  Future<Map<String, dynamic>> requestEarlyPickup(String orderId, String reason, String notes) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    try {
      final res = await _supabase.from('early_pickup_requests').insert({
        'order_id': orderId,
        'user_id': uid,
        'reason': reason,
        'additional_notes': notes,
      }).select().single();
      return res;
    } catch (e) {
      throw Exception('Failed to request early pickup: $e');
    }
  }
  
  Future<void> addEarlyPickupPhoto(String requestId, String photoUrl) async {
    try {
      await _supabase.from('early_pickup_photos').insert({
        'pickup_request_id': requestId,
        'photo_url': photoUrl,
      });
    } catch (e) {
      throw Exception('Failed to add pickup photo: $e');
    }
  }

  // ==========================================
  // CHAT (USER TO USER)
  // ==========================================

  Stream<List<Map<String, dynamic>>> getChatRoomsStream() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    return _supabase.from('chat_rooms').stream(primaryKey: ['id'])
      .eq('participant_1', uid).or('participant_2.eq.$uid');
  }

  Stream<List<Map<String, dynamic>>> getChatMessagesStream(String roomId) {
    return _supabase.from('chat_messages').stream(primaryKey: ['id'])
      .eq('room_id', roomId).order('created_at', ascending: true);
  }

  Future<void> sendMessage(String roomId, String text, [String? fileUrl, String? fileType]) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    try {
      final res = await _supabase.from('chat_messages').insert({
        'room_id': roomId,
        'sender_id': uid,
        'text': text,
      }).select().single();

      if (fileUrl != null) {
        await _supabase.from('chat_attachments').insert({
          'message_id': res['id'],
          'file_url': fileUrl,
          'file_type': fileType ?? 'image',
        });
      }

      // Update room last message
      await _supabase.from('chat_rooms').update({
        'last_message': text.isNotEmpty ? text : 'Sent an attachment',
        'last_message_at': DateTime.now().toIso8601String(),
      }).eq('id', roomId);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // ==========================================
  // AI CHAT (STYLIST ASSISTANT)
  // ==========================================

  Future<Map<String, dynamic>> createAiSession(String title) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    try {
      final res = await _supabase.from('ai_chat_sessions').insert({
        'user_id': uid,
        'title': title
      }).select().single();
      return res;
    } catch (e) {
      throw Exception('Failed to create AI session: $e');
    }
  }

  Future<void> sendAiMessage(String sessionId, String userMessage, String assistantResponse) async {
    try {
      // User message
      await _supabase.from('ai_chat_messages').insert({
        'session_id': sessionId,
        'role': 'user',
        'content': userMessage,
      });
      
      // Assistant message
      await _supabase.from('ai_chat_messages').insert({
        'session_id': sessionId,
        'role': 'assistant',
        'content': assistantResponse,
      });
    } catch (e) {
      throw Exception('Failed to save AI messages: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAiMessages(String sessionId) async {
    try {
      final res = await _supabase.from('ai_chat_messages')
          .select()
          .eq('session_id', sessionId)
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw Exception('Failed to load AI messages: $e');
    }
  }

  // ==========================================
  // REVIEWS & FEEDBACK
  // ==========================================

  Future<void> submitProductReview(Map<String, dynamic> reviewData) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');
    reviewData['user_id'] = uid;

    try {
      await _supabase.from('reviews').insert(reviewData);
    } catch (e) {
      throw Exception('Failed to submit review: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getProductReviews(String productId) async {
    try {
      final res = await _supabase.from('reviews').select('''
        *,
        profiles(full_name, avatar_url),
        review_responses(response_text, created_at)
      ''').eq('product_id', productId).order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  Future<void> submitAppFeedback(int rating, String feedbackText) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    try {
      await _supabase.from('app_feedback').insert({
        'user_id': uid,
        'rating': rating,
        'feedback_text': feedbackText,
      });
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }

  // ==========================================
  // VENDOR ECOSYSTEM
  // ==========================================

  Future<Map<String, dynamic>> createVendorProfile(Map<String, dynamic> profileData, Map<String, dynamic> bankData) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');
    profileData['user_id'] = uid;

    try {
      // Update profile is_vendor
      await _supabase.from('profiles').update({'is_vendor': true}).eq('id', uid);

      // Create vendor profile
      final vendorRes = await _supabase.from('vendor_profiles').insert(profileData).select().single();
      final vendorId = vendorRes['id'];

      // Create bank details
      bankData['vendor_profile_id'] = vendorId;
      await _supabase.from('vendor_bank_details').insert(bankData);

      // Create initial analytics record
      await _supabase.from('vendor_analytics').insert({'vendor_profile_id': vendorId});

      return vendorRes;
    } catch (e) {
      throw Exception('Failed to create vendor profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getVendorAnalytics() async {
    final uid = currentUserId;
    if (uid == null) return null;

    try {
      // Join through vendor_profiles
      final res = await _supabase.from('vendor_profiles').select('''
        id,
        vendor_analytics(*)
      ''').eq('user_id', uid).single();
      
      if (res['vendor_analytics'] != null && (res['vendor_analytics'] as List).isNotEmpty) {
        return res['vendor_analytics'][0];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getVendorBookings() async {
    final uid = currentUserId;
    if (uid == null) return [];

    try {
      // Find the vendor profile ID first
      final vProfile = await _supabase.from('vendor_profiles').select('id').eq('user_id', uid).single();
      final vendorId = vProfile['id'];

      final res = await _supabase.from('vendor_bookings').select('''
        *
      ''').eq('vendor_profile_id', vendorId).order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw Exception('Failed to fetch vendor bookings: $e');
    }
  }

  Future<void> updateVendorBookingStatus(String bookingId, String newStatus, String orderId) async {
    try {
      await _supabase.from('vendor_bookings').update({'status': newStatus}).eq('id', bookingId);
      
      // Update the main order status as well based on vendor action
      String orderStatus = 'requested';
      if (newStatus == 'accepted') orderStatus = 'preparing';
      if (newStatus == 'dispatched') orderStatus = 'out_for_delivery';
      if (newStatus == 'returned') orderStatus = 'delivered';
      if (newStatus == 'declined') orderStatus = 'cancelled';
      
      await _supabase.from('orders').update({'status': orderStatus}).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }
}
