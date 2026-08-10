import 'package:flutter/material.dart';

enum OrderStatus { requested, preparing, outForDelivery, delivered, refunded, cancelled }

class Order {
  /// The raw Supabase UUID. Use this for service calls.
  final String id;
  /// Human-friendly display like "#ORD-9821". Used for UI.
  final String displayId;
  final String orderNumber;
  final String userId;
  final String storeId;
  final String date;
  final DateTime createdAt;
  final int itemsCount;
  final double totalPrice;
  final double subtotal;
  final double deliveryFee;
  final double securityDeposit;
  final double discount;
  final OrderStatus status;
  final String imageUrl;
  final String? promoCode;
  final String? paymentMethod;
  final DateTime? rentalStartDate;
  final DateTime? rentalEndDate;
  final DateTime? estimatedDelivery;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime? refundedAt;
  final double? refundAmount;
  final String? storeName;

  Order({
    required this.id,
    this.displayId = '',
    this.orderNumber = '',
    this.userId = '',
    this.storeId = '',
    required this.date,
    required this.createdAt,
    required this.itemsCount,
    required this.totalPrice,
    this.subtotal = 0.0,
    this.deliveryFee = 0.0,
    this.securityDeposit = 0.0,
    this.discount = 0.0,
    required this.status,
    required this.imageUrl,
    this.promoCode,
    this.paymentMethod,
    this.rentalStartDate,
    this.rentalEndDate,
    this.estimatedDelivery,
    this.cancelledAt,
    this.cancellationReason,
    this.refundedAt,
    this.refundAmount,
    this.storeName,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    int itemsCnt = 0;
    String imgUrl = '';
    
    if (json['order_items'] != null && (json['order_items'] as List).isNotEmpty) {
      final items = json['order_items'] as List;
      itemsCnt = items.fold(0, (sum, item) => sum + (item['quantity'] as int? ?? 1));
      imgUrl = items[0]['product_image_url'] as String? ?? '';
    }

    final cAt = DateTime.parse(json['created_at'] as String);

    return Order(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      storeId: json['store_id'] as String? ?? '',
      date: '${cAt.day} ${_getMonth(cAt.month)}, ${cAt.year}',
      createdAt: cAt,
      itemsCount: itemsCnt,
      totalPrice: (json['total'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      securityDeposit: (json['security_deposit'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      status: _parseStatus(json['status'] as String? ?? 'requested'),
      imageUrl: imgUrl,
      promoCode: json['promo_code'] as String?,
      paymentMethod: json['payment_method'] as String?,
      rentalStartDate: json['rental_start_date'] != null ? DateTime.parse(json['rental_start_date'] as String) : null,
      rentalEndDate: json['rental_end_date'] != null ? DateTime.parse(json['rental_end_date'] as String) : null,
      estimatedDelivery: json['estimated_delivery'] != null ? DateTime.parse(json['estimated_delivery'] as String) : null,
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at'] as String) : null,
      cancellationReason: json['cancellation_reason'] as String?,
      refundedAt: json['refunded_at'] != null ? DateTime.parse(json['refunded_at'] as String) : null,
      refundAmount: (json['refund_amount'] as num?)?.toDouble(),
      storeName: json['stores'] != null ? json['stores']['name'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_number': orderNumber,
      'store_id': storeId,
      'status': status.name == 'outForDelivery' ? 'out_for_delivery' : status.name,
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'security_deposit': securityDeposit,
      'discount': discount,
      'total': totalPrice,
      if (promoCode != null) 'promo_code': promoCode,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (rentalStartDate != null) 'rental_start_date': rentalStartDate?.toIso8601String().substring(0, 10),
      if (rentalEndDate != null) 'rental_end_date': rentalEndDate?.toIso8601String().substring(0, 10),
    };
  }

  static OrderStatus _parseStatus(String statusStr) {
    switch (statusStr) {
      case 'requested': return OrderStatus.requested;
      case 'preparing': return OrderStatus.preparing;
      case 'out_for_delivery': return OrderStatus.outForDelivery;
      case 'delivered': return OrderStatus.delivered;
      case 'refunded': return OrderStatus.refunded;
      case 'cancelled': return OrderStatus.cancelled;
      default: return OrderStatus.requested;
    }
  }

  static String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String get statusText {
    switch (status) {
      case OrderStatus.requested: return 'Requested';
      case OrderStatus.preparing: return 'Preparing Order';
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.refunded: return 'Refunded';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.requested: return Colors.blue.shade700;
      case OrderStatus.preparing: return Colors.orange.shade800;
      case OrderStatus.outForDelivery: return Colors.teal.shade700;
      case OrderStatus.delivered: return Colors.green.shade700;
      case OrderStatus.refunded: return Colors.red.shade700;
      case OrderStatus.cancelled: return Colors.grey.shade700;
    }
  }

  Color get statusBgColor {
    switch (status) {
      case OrderStatus.requested: return Colors.blue.shade50;
      case OrderStatus.preparing: return Colors.orange.shade50;
      case OrderStatus.outForDelivery: return Colors.teal.shade50;
      case OrderStatus.delivered: return Colors.green.shade50;
      case OrderStatus.refunded: return Colors.red.shade50;
      case OrderStatus.cancelled: return Colors.grey.shade50;
    }
  }
}
