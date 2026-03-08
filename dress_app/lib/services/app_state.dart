import 'package:flutter/material.dart';
import 'package:dress_app/models/product.dart';
import 'package:dress_app/models/cart_item.dart';
import 'package:dress_app/models/user_profile.dart';
import 'package:dress_app/services/mock_data_service.dart';
import 'package:dress_app/models/order.dart';

class AppState extends ChangeNotifier {
  // Current User
  UserProfile _currentUser = MockDataService.currentUser;
  UserProfile get currentUser => _currentUser;

  void updateUserProfile(UserProfile profile) {
    _currentUser = profile;
    notifyListeners();
  }

  void setVendorMode(bool isVendor) {
    _currentUser.isVendor = isVendor;
    notifyListeners();
  }

  // Cart
  final List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;

  void addToCart(CartItem item) {
    _cartItems.add(item);
    notifyListeners();
  }

  void removeFromCart(String itemId) {
    _cartItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void updateCartQuantity(String itemId, int quantity) {
    final index = _cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      if (quantity > 0) {
        _cartItems[index].quantity = quantity;
      } else {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  double get cartTotal {
    return _cartItems.fold(0, (total, item) => total + (item.product.price * item.quantity));
  }

  // Wishlist
  final List<String> _wishlistProductIds = []; // store IDs to sync properly
  List<String> get wishlistProductIds => _wishlistProductIds;

  bool isFavorite(String productId) {
    return _wishlistProductIds.contains(productId);
  }

  void toggleFavorite(String productId) {
    if (_wishlistProductIds.contains(productId)) {
      _wishlistProductIds.remove(productId);
    } else {
      _wishlistProductIds.add(productId);
    }
    notifyListeners();
  }

  List<Product> get wishlistedProducts {
    return MockDataService.mockProducts
        .where((p) => _wishlistProductIds.contains(p.id))
        .toList();
  }

  // Orders
  final List<Order> _orders = List.from(MockDataService.mockOrders);
  List<Order> get orders => _orders;

  void addOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
  }
}
