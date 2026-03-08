import 'package:dress_app/models/product.dart';

class CartItem {
  final String id;
  final Product product;
  final String selectedSize;
  final String selectedColor;
  final String rentalDates;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
    required this.rentalDates,
    this.quantity = 1,
  });
}
