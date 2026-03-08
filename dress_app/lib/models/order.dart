import 'package:flutter/material.dart';

enum OrderStatus { requested, preparing, outForDelivery, delivered, refunded }

class Order {
  final String id;
  final String date;
  final int itemsCount;
  final double totalPrice;
  final OrderStatus status;
  final String imageUrl;

  Order({
    required this.id,
    required this.date,
    required this.itemsCount,
    required this.totalPrice,
    required this.status,
    required this.imageUrl,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.requested:
        return 'Requested';
      case OrderStatus.preparing:
        return 'Preparing Order';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.requested:
        return Colors.blue.shade700;
      case OrderStatus.preparing:
        return Colors.orange.shade800;
      case OrderStatus.outForDelivery:
        return Colors.teal.shade700;
      case OrderStatus.delivered:
        return Colors.green.shade700;
      case OrderStatus.refunded:
        return Colors.red.shade700;
    }
  }

  Color get statusBgColor {
    switch (status) {
      case OrderStatus.requested:
        return Colors.blue.shade50;
      case OrderStatus.preparing:
        return Colors.orange.shade50;
      case OrderStatus.outForDelivery:
        return Colors.teal.shade50;
      case OrderStatus.delivered:
        return Colors.green.shade50;
      case OrderStatus.refunded:
        return Colors.red.shade50;
    }
  }
}
