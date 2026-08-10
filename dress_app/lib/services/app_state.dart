import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dress_app/models/product.dart';
import 'package:dress_app/models/cart_item.dart';
import 'package:dress_app/models/user_profile.dart';
import 'package:dress_app/models/order.dart';
import 'package:dress_app/services/database_service.dart';
import 'package:dress_app/services/auth_service.dart';
import 'package:dress_app/services/wishlist_service.dart';
import 'package:dress_app/services/mock_data_service.dart';
import 'package:dress_app/services/supabase_service.dart';

/// In-memory representation of a guest. Has empty id so we can detect
/// "not signed in" everywhere with a single check.
UserProfile _guestUser() => UserProfile(
      id: '',
      name: 'Guest',
      email: '',
      phone: '',
      avatarUrl: '',
      isVendor: false,
      isOnboarded: false,
    );

class AppState extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // The active user. Defaults to a "Guest" placeholder when not signed in.
  // Callers should check `isAuthenticated` / `isGuest` before reading
  // user-specific data.
  UserProfile _currentUser = _guestUser();
  UserProfile get currentUser => _currentUser;

  /// True if the user has NOT signed in / signed up yet. They can browse the
  /// app, but personal data (orders, wallet, wishlist sync) is not theirs.
  bool get isGuest => _currentUser.id.isEmpty;

  /// True if the user has authenticated (Supabase session OR real id).
  bool get isAuthenticated => !isGuest;

  /// Persisted flag: "user pressed continue as guest". Stays across launches.
  bool _hasChosenGuest = false;
  bool get hasChosenGuest => _hasChosenGuest;

  AppState() {
    _orders = List.of(MockDataService.mockOrders);
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasChosenGuest = prefs.getBool('is_guest') ?? false;
      // If a real auth session is alive, hydrate the profile.
      if (SupabaseService.isConfigured) {
        final user = AuthService().currentUser;
        if (user != null) {
          await refreshProfile();
        }
      }
      notifyListeners();
    } catch (_) {/* ignore */}
  }

  /// User explicitly chose to browse as guest. Persist so they don't have
  /// to re-pick on every launch.
  Future<void> continueAsGuest() async {
    _currentUser = _guestUser();
    _hasChosenGuest = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_guest', true);
    } catch (_) {}
    notifyListeners();
  }

  /// Mark the user as signed in with a real profile.
  Future<void> setAuthenticated(UserProfile profile) async {
    _currentUser = profile;
    _hasChosenGuest = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_guest', false);
    } catch (_) {}
    notifyListeners();
  }

  /// Refresh the current user's profile from backend / mock.
  Future<void> refreshProfile() async {
    if (isGuest) return;
    try {
      final profile = await AuthService().getCurrentProfile();
      if (profile != null && profile.id.isNotEmpty) {
        _currentUser = profile;
        notifyListeners();
      }
    } catch (_) {
      // Keep current user; UI will not break.
    }
  }

  /// Refresh the wishlist from backend.
  Future<void> refreshFavorites() async {
    if (isGuest) return;
    final userId = _currentUser.id;
    if (userId.isEmpty) return;
    try {
      final ids = await WishlistService().getWishlistIds(userId);
      _wishlistProductIds = ids;
      _wishlistedProducts = MockDataService.mockProducts
          .where((p) => ids.contains(p.id))
          .toList();
      notifyListeners();
    } catch (_) {/* ignore */}
  }

  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      await _dbService.updateProfile(profile.toJson());
      _currentUser = profile;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> setVendorMode(bool isVendor) async {
    if (_currentUser.id.isEmpty) return;
    try {
      final updatedProfile = _currentUser.copyWith(isVendor: isVendor);
      await _dbService.updateProfile({'is_vendor': isVendor});
      _currentUser = updatedProfile;
      notifyListeners();
    } catch (_) {/* ignore */}
  }

  /// Sign out and reset to guest. Clears the persisted guest flag so the
  /// app returns to its fresh state.
  Future<void> signOut() async {
    _currentUser = _guestUser();
    _hasChosenGuest = false;
    try {
      await AuthService().signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_guest', false);
    } catch (_) {}
    notifyListeners();
  }

  // ==================== Cart ====================
  final List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;

  /// Total in INR, computed from each item's rental fee × its days.
  double get cartTotal {
    return _cartItems.fold<double>(0, (total, item) {
      final days = item.rentalEndDate
          .difference(item.rentalStartDate)
          .inDays
          .clamp(1, 365) +
          1;
      return total + (item.product.rentalPricePerDay * days * item.quantity);
    });
  }

  Future<void> addToCart(CartItem item) async {
    try {
      await _dbService.addToCart(item.toJson());
    } catch (_) {/* mock-mode no-op */}
    _cartItems.add(item);
    notifyListeners();
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      await _dbService.removeFromCart(itemId);
    } catch (_) {}
    _cartItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  Future<void> updateCartQuantity(String itemId, int quantity) async {
    if (quantity > 0) {
      try {
        await _dbService.updateCartQuantity(itemId, quantity);
      } catch (_) {}
      final index = _cartItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _cartItems[index].quantity = quantity;
      }
    } else {
      await removeFromCart(itemId);
    }
    notifyListeners();
  }

  Future<void> clearCart() async {
    try {
      await _dbService.clearCart();
    } catch (_) {}
    _cartItems.clear();
    notifyListeners();
  }

  // ==================== Wishlist ====================
  List<String> _wishlistProductIds = [];
  List<Product> _wishlistedProducts = [];
  List<String> get wishlistProductIds => _wishlistProductIds;

  bool isFavorite(String productId) =>
      _wishlistProductIds.contains(productId);

  Future<bool> toggleFavorite(String productId) async {
    final wasFav = _wishlistProductIds.contains(productId);
    if (wasFav) {
      _wishlistProductIds.remove(productId);
      _wishlistedProducts.removeWhere((p) => p.id == productId);
    } else {
      _wishlistProductIds.add(productId);
      final product = MockDataService.mockProducts
          .where((p) => p.id == productId)
          .cast<Product?>()
          .firstWhere((_) => true, orElse: () => null);
      if (product != null) _wishlistedProducts.add(product);
    }
    notifyListeners();
    if (isGuest) return !wasFav;
    try {
      await WishlistService().toggle(_currentUser.id, productId);
      return !wasFav;
    } catch (_) {
      return !wasFav;
    }
  }

  List<Product> get wishlistedProducts => _wishlistedProducts;

  // ==================== Orders ====================
  List<Order> _orders = [];
  List<Order> get orders => _orders;

  Future<void> addOrder(Order order, List<Map<String, dynamic>> items) async {
    try {
      await _dbService.createOrder(order.toJson(), items);
    } catch (_) {}
    _orders.insert(0, order);
    notifyListeners();
  }

  Future<void> refreshOrders() async {
    if (isGuest) return;
    try {
      final list = await _dbService.getMyOrders();
      _orders = list
          .map((m) => Order(
                id: (m['id'] ?? m['order_number'] ?? '').toString(),
                orderNumber: (m['order_number'] ?? '').toString(),
                userId: (m['user_id'] ?? m['buyer_id'] ?? '').toString(),
                storeId: (m['store_id'] ?? m['vendor_id'] ?? '').toString(),
                date: '',
                createdAt: m['created_at'] != null
                    ? DateTime.parse(m['created_at'].toString())
                    : DateTime.now(),
                itemsCount: m['items_count'] as int? ?? 1,
                totalPrice: (m['total'] ?? m['total_amount'] ?? 0).toDouble(),
                subtotal: (m['subtotal'] ?? 0).toDouble(),
                deliveryFee: (m['delivery_fee'] ?? 0).toDouble(),
                securityDeposit: (m['security_deposit'] ?? 0).toDouble(),
                discount: (m['discount'] ?? 0).toDouble(),
                status: _parseStatus(m['status']?.toString()),
                imageUrl: (m['image_url'] ??
                        m['order_items']?[0]?['product_image_url'] ??
                        '')
                    .toString(),
              ))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  OrderStatus _parseStatus(String? s) {
    switch (s) {
      case 'requested':
        return OrderStatus.requested;
      case 'preparing':
        return OrderStatus.preparing;
      case 'out_for_delivery':
      case 'outForDelivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'refunded':
        return OrderStatus.refunded;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.requested;
    }
  }
}
