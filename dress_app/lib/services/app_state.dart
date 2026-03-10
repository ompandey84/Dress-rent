import 'package:flutter/material.dart';
import 'package:dress_app/models/product.dart';
import 'package:dress_app/models/cart_item.dart';
import 'package:dress_app/models/user_profile.dart';
import 'package:dress_app/models/order.dart';
import 'package:dress_app/services/auth_service.dart';
import 'package:dress_app/services/database_service.dart';
import 'dart:async';

class AppState extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  StreamSubscription? _authSubscription;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Current User (fallback to empty mock to prevent null errors during migration)
  UserProfile? _currentUser;
  UserProfile get currentUser => _currentUser ?? UserProfile(
    id: '', email: '', name: 'Guest', avatarUrl: '', isVendor: false,
    addresses: [], phone: '', isOnboarded: false, 
  );

  bool get isAuthenticated => _currentUser != null && _currentUser!.id.isNotEmpty;

  AppState() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authSubscription = _authService.authStateChanges.listen((data) {
      final session = data.session;
      if (session != null) {
        _loadUserData(session.user.id);
      } else {
        _clearUserData();
      }
    });
  }

  Future<void> _loadUserData(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final profileMap = await _dbService.getProfile(userId);
      if (profileMap != null) {
         _currentUser = UserProfile.fromJson(profileMap);
      }

      final cartMaps = await _dbService.getCartItems();
      _cartItems = cartMaps.map((e) => CartItem.fromJson(e)).toList();

      final orderMaps = await _dbService.getMyOrders();
      _orders = orderMaps.map((e) => Order.fromJson(e)).toList();

      final wishlistMaps = await _dbService.getWishlist();
      _wishlistProductIds = wishlistMaps.map((e) => e['product_id'] as String).toList();
      _wishlistedProducts = wishlistMaps.map((e) {
        final productMap = e['products'] as Map<String, dynamic>?;
        if (productMap != null) {
          return Product.fromJson(productMap);
        }
        return null;
      }).where((p) => p != null).cast<Product>().toList();
    } catch (e) {
      debugPrint('Error loading user data: $e');
      // If profile doesn't exist yet, we don't crash, we just wait for onboarding or handle it.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _clearUserData() {
    _currentUser = null;
    _cartItems.clear();
    _orders.clear();
    _wishlistProductIds.clear();
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _dbService.updateProfile(profile.toJson());
      _currentUser = profile;
      notifyListeners();
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }

  Future<void> setVendorMode(bool isVendor) async {
    if (_currentUser == null) return;
    try {
      final updatedProfile = _currentUser!.copyWith(isVendor: isVendor);
      await _dbService.updateProfile({'is_vendor': isVendor});
      _currentUser = updatedProfile;
      notifyListeners();
    } catch (e) {
      debugPrint('Set vendor mode error: $e');
    }
  }

  // Cart
  List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;

  Future<void> addToCart(CartItem item) async {
    try {
      await _dbService.addToCart(item.toJson());
      _cartItems.add(item);
      notifyListeners();
    } catch (e) {
      debugPrint('Add to cart error: $e');
    }
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      await _dbService.removeFromCart(itemId);
      _cartItems.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      debugPrint('Remove from cart error: $e');
    }
  }

  Future<void> updateCartQuantity(String itemId, int quantity) async {
    try {
      if (quantity > 0) {
        await _dbService.updateCartQuantity(itemId, quantity);
        final index = _cartItems.indexWhere((item) => item.id == itemId);
        if (index != -1) {
          _cartItems[index].quantity = quantity;
        }
      } else {
        await removeFromCart(itemId);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Update cart quantity error: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      await _dbService.clearCart();
      _cartItems.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Clear cart error: $e');
    }
  }

  double get cartTotal {
    return _cartItems.fold(0, (total, item) => total + (item.product.price * item.quantity));
  }

  // Wishlist
  List<String> _wishlistProductIds = [];
  List<Product> _wishlistedProducts = [];
  List<String> get wishlistProductIds => _wishlistProductIds;

  bool isFavorite(String productId) {
    return _wishlistProductIds.contains(productId);
  }

  Future<void> toggleFavorite(String productId) async {
    try {
      await _dbService.toggleWishlist(productId);
      if (_wishlistProductIds.contains(productId)) {
        _wishlistProductIds.remove(productId);
        _wishlistedProducts.removeWhere((p) => p.id == productId);
      } else {
        _wishlistProductIds.add(productId);
        // We'd ideally need the full product to add to _wishlistedProducts here.
        // For now, next time they load the page or if we refresh, it'll fetch.
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
    }
  }

  List<Product> get wishlistedProducts => _wishlistedProducts;

  // Orders
  List<Order> _orders = [];
  List<Order> get orders => _orders;

  Future<void> addOrder(Order order, List<Map<String, dynamic>> items) async {
    try {
      await _dbService.createOrder(order.toJson(), items);
      _orders.insert(0, order);
      notifyListeners();
    } catch (e) {
      debugPrint('Create order error: $e');
    }
  }
}
