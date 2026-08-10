import 'package:flutter/material.dart';

enum BookingStatus {
  pendingPayment,
  pendingLenderAcceptance,
  accepted,
  rejectedByLender,
  lenderPreparing,
  pickupScheduled,
  inTransitToRenter,
  deliveredToRenter,
  inUse,
  returnScheduled,
  inTransitToLender,
  returned,
  completed,
  cancelledByRenter,
  cancelledByLender,
  disputed,
}

BookingStatus bookingStatusFromString(String s) {
  switch (s) {
    case 'pending_payment':
      return BookingStatus.pendingPayment;
    case 'pending_lender_acceptance':
      return BookingStatus.pendingLenderAcceptance;
    case 'accepted':
      return BookingStatus.accepted;
    case 'rejected_by_lender':
      return BookingStatus.rejectedByLender;
    case 'lender_preparing':
      return BookingStatus.lenderPreparing;
    case 'pickup_scheduled':
      return BookingStatus.pickupScheduled;
    case 'in_transit_to_renter':
      return BookingStatus.inTransitToRenter;
    case 'delivered_to_renter':
      return BookingStatus.deliveredToRenter;
    case 'in_use':
      return BookingStatus.inUse;
    case 'return_scheduled':
      return BookingStatus.returnScheduled;
    case 'in_transit_to_lender':
      return BookingStatus.inTransitToLender;
    case 'returned':
      return BookingStatus.returned;
    case 'completed':
      return BookingStatus.completed;
    case 'cancelled_by_renter':
      return BookingStatus.cancelledByRenter;
    case 'cancelled_by_lender':
      return BookingStatus.cancelledByLender;
    case 'disputed':
      return BookingStatus.disputed;
    default:
      return BookingStatus.pendingPayment;
  }
}

extension BookingStatusDisplay on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.pendingPayment:
        return 'Pending Payment';
      case BookingStatus.pendingLenderAcceptance:
        return 'Awaiting Lender Approval';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.rejectedByLender:
        return 'Rejected by Lender';
      case BookingStatus.lenderPreparing:
        return 'Lender Preparing';
      case BookingStatus.pickupScheduled:
        return 'Pickup Scheduled';
      case BookingStatus.inTransitToRenter:
        return 'Out for Delivery';
      case BookingStatus.deliveredToRenter:
        return 'Delivered';
      case BookingStatus.inUse:
        return 'In Use';
      case BookingStatus.returnScheduled:
        return 'Return Scheduled';
      case BookingStatus.inTransitToLender:
        return 'Return in Transit';
      case BookingStatus.returned:
        return 'Returned';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelledByRenter:
        return 'Cancelled';
      case BookingStatus.cancelledByLender:
        return 'Cancelled by Lender';
      case BookingStatus.disputed:
        return 'Disputed';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.pendingPayment:
        return Colors.orange.shade700;
      case BookingStatus.pendingLenderAcceptance:
        return Colors.blue.shade700;
      case BookingStatus.accepted:
      case BookingStatus.lenderPreparing:
        return Colors.indigo.shade700;
      case BookingStatus.rejectedByLender:
      case BookingStatus.cancelledByRenter:
      case BookingStatus.cancelledByLender:
        return Colors.red.shade700;
      case BookingStatus.pickupScheduled:
      case BookingStatus.inTransitToRenter:
      case BookingStatus.inTransitToLender:
      case BookingStatus.returnScheduled:
        return Colors.teal.shade700;
      case BookingStatus.deliveredToRenter:
      case BookingStatus.inUse:
        return Colors.green.shade700;
      case BookingStatus.returned:
      case BookingStatus.completed:
        return Colors.green.shade900;
      case BookingStatus.disputed:
        return Colors.deepOrange.shade700;
    }
  }
}

class Booking {
  final String id;
  final String orderNumber;
  final String listingId;
  final String lenderId;
  final String renterId;
  final DateTime startDate;
  final DateTime endDate;
  final double rentalFee;
  final double securityDeposit;
  final double deliveryFee;
  final double insuranceFee;
  final double discount;
  final double total;
  final bool hasInsurance;
  final String paymentStatus; // pending|paid|failed|refunded
  final String escrowStatus;
  final BookingStatus status;
  final String? cashfreeOrderId;
  final String? cashfreePaymentId;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final DateTime? acceptedAt;
  final DateTime? deliveredAt;
  final DateTime? returnedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final double? refundAmount;

  // Joined data (optional, set by loader)
  final String? listingTitle;
  final String? listingImage;
  final String? lenderName;
  final String? renterName;

  // Variant
  final String? selectedSize;
  final String? selectedColor;

  Booking({
    required this.id,
    required this.orderNumber,
    required this.listingId,
    required this.lenderId,
    required this.renterId,
    required this.startDate,
    required this.endDate,
    required this.rentalFee,
    required this.securityDeposit,
    this.deliveryFee = 0,
    this.insuranceFee = 0,
    this.discount = 0,
    required this.total,
    this.hasInsurance = false,
    this.paymentStatus = 'pending',
    this.escrowStatus = 'pending',
    this.status = BookingStatus.pendingPayment,
    this.cashfreeOrderId,
    this.cashfreePaymentId,
    this.cancellationReason,
    this.cancelledAt,
    this.acceptedAt,
    this.deliveredAt,
    this.returnedAt,
    this.completedAt,
    required this.createdAt,
    this.refundAmount,
    this.listingTitle,
    this.listingImage,
    this.lenderName,
    this.renterName,
    this.selectedSize,
    this.selectedColor,
  });

  int get rentalDays => endDate.difference(startDate).inDays + 1;

  bool get isActive =>
      ![BookingStatus.completed, BookingStatus.cancelledByRenter, BookingStatus.cancelledByLender, BookingStatus.rejectedByLender].contains(status);

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String? ?? '',
      listingId: json['product_id'] as String? ?? json['listing_id'] as String? ?? '',
      lenderId: json['vendor_id'] as String? ?? json['lender_id'] as String? ?? '',
      renterId: json['buyer_id'] as String? ?? json['renter_id'] as String? ?? '',
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      rentalFee: (json['rental_fee'] as num?)?.toDouble() ?? 0,
      securityDeposit: (json['security_deposit'] as num?)?.toDouble() ?? 0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
      insuranceFee: (json['insurance_fee'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      total: (json['total_amount'] as num?)?.toDouble()
          ?? (json['total'] as num?)?.toDouble()
          ?? 0,
      hasInsurance: (json['insurance_fee'] as num?)?.toDouble() != null
          && (json['insurance_fee'] as num).toDouble() > 0,
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      escrowStatus: json['escrow_status'] as String? ?? 'none',
      status: bookingStatusFromString(json['status'] as String? ?? 'pending'),
      cashfreeOrderId: json['cashfree_order_id'] as String?,
      cashfreePaymentId: json['cashfree_payment_id'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      returnedAt: json['returned_at'] != null
          ? DateTime.parse(json['returned_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      refundAmount: (json['refund_amount'] as num?)?.toDouble(),
      // Embedded joins
      listingTitle: (json['products'] as Map?)?['title'] as String?
          ?? (json['listings'] as Map?)?['title'] as String?,
      listingImage: ((json['products'] as Map?)?['images'] as List?)?.isNotEmpty == true
          ? ((json['products'] as Map?)?['images'] as List).first as String
          : (((json['listings'] as Map?)?['photos'] as List?)?.isNotEmpty == true
              ? ((json['listings'] as Map?)?['photos'] as List).first as String
              : null),
      lenderName: (json['vendor'] as Map?)?['shop_name'] as String?
          ?? (json['lender'] as Map?)?['full_name'] as String?,
      renterName: (json['renter'] as Map?)?['full_name'] as String?
          ?? (json['buyer'] as Map?)?['full_name'] as String?,
      selectedSize: json['selected_size'] as String?,
      selectedColor: json['selected_color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'product_id': listingId,
      'vendor_id': lenderId,
      'buyer_id': renterId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'rental_days': rentalDays,
      'rental_price': rentalFee,
      'security_deposit': securityDeposit,
      'delivery_fee': deliveryFee,
      'insurance_fee': insuranceFee,
      'discount': discount,
      'total_amount': total,
      'selected_size': selectedSize,
      'selected_color': selectedColor,
      'payment_status': paymentStatus,
      'escrow_status': escrowStatus,
      'status': status.name,
    };
  }
}
