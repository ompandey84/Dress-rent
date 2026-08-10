import 'package:dress_app/models/product.dart';

class CartItem {
  final String id;
  final String userId;
  final Product product;
  final String selectedSize;
  final String selectedColor;
  final DateTime rentalStartDate;
  final DateTime rentalEndDate;
  final DateTime? lockedUntil;
  int quantity;

  CartItem({
    required this.id,
    this.userId = '',
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
    required this.rentalStartDate,
    required this.rentalEndDate,
    this.lockedUntil,
    this.quantity = 1,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      product: json['products'] != null 
          ? Product.fromJson(json['products']) 
          : Product(
              id: json['product_id'] as String,
              name: 'Unknown Loading',
              rentalPricePerDay: 0.0,
              price: 0.0,
              description: '',
              images: [],
              sizes: [],
              colors: [],
            ),
      selectedSize: json['selected_size'] as String? ?? '',
      selectedColor: json['selected_color'] as String? ?? '',
      rentalStartDate: DateTime.parse(json['rental_start_date'] as String),
      rentalEndDate: DateTime.parse(json['rental_end_date'] as String),
      lockedUntil: json['locked_until'] != null ? DateTime.parse(json['locked_until'] as String) : null,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  String get rentalDates {
    final start = '${_monthName(rentalStartDate.month)} ${rentalStartDate.day}';
    final end = '${_monthName(rentalEndDate.month)} ${rentalEndDate.day}, ${rentalEndDate.year}';
    return '$start - $end';
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId.isNotEmpty) 'user_id': userId,
      'product_id': product.id,
      'selected_size': selectedSize,
      'selected_color': selectedColor,
      'rental_start_date': rentalStartDate.toIso8601String().substring(0, 10),
      'rental_end_date': rentalEndDate.toIso8601String().substring(0, 10),
      'quantity': quantity,
      if (lockedUntil != null) 'locked_until': lockedUntil?.toIso8601String(),
    };
  }
}
