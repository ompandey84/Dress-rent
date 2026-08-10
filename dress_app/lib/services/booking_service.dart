import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:dress_app/services/database_service.dart';
import 'package:dress_app/services/cashfree_service.dart';
import 'package:dress_app/services/mock_data_service.dart';
import 'package:dress_app/services/auth_service.dart';
import 'package:dress_app/models/booking.dart';
import 'package:dress_app/models/product.dart';
import 'package:dress_app/models/cart_item.dart';

/// Service to manage the booking lifecycle: create, list, cancel, pay.
class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final _db = DatabaseService();

  /// Calculate booking pricing breakdown.
  BookingPricing calculatePricing({
    required Product product,
    required DateTime startDate,
    required DateTime endDate,
    double discount = 0,
    bool includeInsurance = false,
  }) {
    final days = endDate.difference(startDate).inDays + 1;
    final rentalFee = product.rentalPricePerDay * days;
    final securityDeposit = product.securityDeposit;
    final deliveryFee = _calculateDeliveryFee(days);
    final insuranceFee = includeInsurance ? _calculateInsuranceFee(rentalFee) : 0.0;
    final total = rentalFee + securityDeposit + deliveryFee + insuranceFee - discount;

    return BookingPricing(
      rentalDays: days,
      rentalFee: rentalFee,
      securityDeposit: securityDeposit,
      deliveryFee: deliveryFee,
      insuranceFee: insuranceFee,
      discount: discount,
      total: total,
      includeInsurance: includeInsurance,
    );
  }

  /// Free delivery for 3+ day rentals, otherwise ₹49.
  /// Public so the cart screen can preview it.
  static double calculateDeliveryFee(int days) {
    if (days >= 3) return 0;
    return 49.0;
  }

  double _calculateDeliveryFee(int days) => calculateDeliveryFee(days);

  double _calculateInsuranceFee(double rentalFee) {
    // 5% of rental fee (covers accidental damage up to 100% of item value)
    return (rentalFee * 0.05).roundToDouble();
  }

  /// Create a booking (writes to `orders` table per the live schema).
  Future<Booking> createBooking({
    required Product product,
    required CartItem cartItem,
    required BookingPricing pricing,
  }) async {
    final renterId = AuthService().currentUserId ?? 'mock-user-id';
    final cashfreeOrderId = 'dress_${DateTime.now().millisecondsSinceEpoch}';

    if (!SupabaseService.isConfigured) {
      // Mock mode: just create locally
      return Booking(
        id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
        orderNumber: 'DRS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        listingId: product.id,
        lenderId: product.storeId,
        renterId: renterId,
        startDate: cartItem.rentalStartDate,
        endDate: cartItem.rentalEndDate,
        rentalFee: pricing.rentalFee,
        securityDeposit: pricing.securityDeposit,
        deliveryFee: pricing.deliveryFee,
        insuranceFee: pricing.insuranceFee,
        discount: pricing.discount,
        total: pricing.total,
        hasInsurance: pricing.includeInsurance,
        status: BookingStatus.pendingPayment,
        cashfreeOrderId: cashfreeOrderId,
        createdAt: DateTime.now(),
        listingTitle: product.name,
        listingImage: product.images.isNotEmpty ? product.images.first : null,
        lenderName: product.storeName,
      );
    }

    final supabase = Supabase.instance.client;
    // Resolve vendor_id from the product row (the live schema has
    // products.vendor_id pointing at public.vendors.id).
    String? vendorId;
    try {
      final prod = await supabase
          .from('products')
          .select('vendor_id')
          .eq('id', product.id)
          .maybeSingle();
      vendorId = prod?['vendor_id'] as String?;
    } catch (_) {}

    // The insert uses your schema's actual columns.
    // We store the per-day total inside `total_amount` (your schema
    // doesn't have a separate `rental_price` column on orders — that's
    // per-day on `products.rental_price` only).
    final res = await supabase.from('orders').insert({
      'buyer_id': renterId,
      'vendor_id': vendorId,
      'product_id': product.id,
      'start_date': cartItem.rentalStartDate.toIso8601String().split('T')[0],
      'end_date': cartItem.rentalEndDate.toIso8601String().split('T')[0],
      'rental_days': pricing.rentalDays,
      'total_amount': pricing.total,
      'delivery_fee': pricing.deliveryFee,
      'security_deposit': pricing.securityDeposit,
      'insurance_fee': pricing.insuranceFee,
      'discount': pricing.discount,
      'selected_size': cartItem.selectedSize,
      'selected_color': cartItem.selectedColor,
      'status': 'pending',
      'payment_status': 'pending',
      'escrow_status': 'none',
      'cashfree_order_id': cashfreeOrderId,
    }).select().single();

    return Booking.fromJson(res);
  }

  /// Initiate Cashfree payment for a booking.
  ///
  /// [amount] lets the caller pass a wallet-aware amount (i.e. the
  /// `amountToPayNow` from BookingSummaryScreen). When null, we fall back to
  /// `booking.total` so legacy callers still work.
  Future<CashfreePaymentResult> payForBooking({
    required Booking booking,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    double? amount,
  }) async {
    final chargeAmount = amount ?? booking.total;

    if (!SupabaseService.isConfigured) {
      // Mock mode: succeed immediately
      await Future.delayed(const Duration(seconds: 1));
      return CashfreePaymentResult.success(
        orderId: booking.cashfreeOrderId ?? 'mock',
        paymentId: 'mock_pay_${DateTime.now().millisecondsSinceEpoch}',
        method: 'MOCK',
      );
    }

    // Create order with Cashfree (using the wallet-aware amount when given)
    final order = await CashfreeService().createOrder(
      orderId: booking.cashfreeOrderId!,
      amount: chargeAmount,
      customerId: booking.renterId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      metadata: {
        'booking_id': booking.id,
        'listing_id': booking.listingId,
        'type': 'rental',
        if (chargeAmount != booking.total)
          'wallet_covered': (booking.total - chargeAmount).toStringAsFixed(2),
      },
    );

    // Open checkout
    return await CashfreeService().openCheckout(
      order: order,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
    );
  }

  /// After successful payment, update booking status to confirmed + held in escrow.
  Future<void> markAsPaid(String bookingId) async {
    if (!SupabaseService.isConfigured) return;
    final supabase = Supabase.instance.client;
    await supabase.from('orders').update({
      'payment_status': 'paid',
      'status': 'confirmed',
      'escrow_status': 'held',
    }).eq('id', bookingId);
  }

  /// Get all bookings for the current user.
  Future<List<Booking>> getMyBookings() async {
    if (!SupabaseService.isConfigured) {
      return MockDataService.mockOrders.map((o) => Booking(
            id: o.id,
            orderNumber: o.id,
            listingId: o.id,
            lenderId: o.storeId,
            renterId: o.userId,
            startDate: o.createdAt,
            endDate: o.createdAt.add(const Duration(days: 3)),
            rentalFee: o.totalPrice,
            securityDeposit: 0,
            deliveryFee: o.deliveryFee,
            total: o.totalPrice,
            status: _mapOrderStatus(o.status.name),
            createdAt: o.createdAt,
            listingImage: o.imageUrl,
          )).toList();
    }
    final supabase = Supabase.instance.client;
    final renterId = AuthService().currentUserId;
    if (renterId == null) return [];
    final res = await supabase
        .from('orders')
        .select('*, products(title, images)')
        .eq('buyer_id', renterId)
        .order('created_at', ascending: false);
    return (res as List).map((m) => Booking.fromJson(m)).toList();
  }

  /// Cancel an order and request refund.
  Future<bool> cancelBooking(String bookingId, String reason) async {
    if (!SupabaseService.isConfigured) return true;
    final supabase = Supabase.instance.client;
    final res = await supabase.from('orders').update({
      'status': 'cancelled',
      'cancellation_reason': reason,
      'cancelled_at': DateTime.now().toIso8601String(),
      'cancelled_by': AuthService().currentUserId,
    }).eq('id', bookingId);
    return res != null;
  }

  /// Mark a delivered order as awaiting return pickup.
  /// (Used by the renter's "Return Order" action.)
  Future<bool> markReturnRequested(String bookingId) async {
    if (!SupabaseService.isConfigured) return true;
    final supabase = Supabase.instance.client;
    final res = await supabase.from('orders').update({
      'status': 'return_scheduled',
    }).eq('id', bookingId);
    return res != null;
  }

  BookingStatus _mapOrderStatus(String s) {
    switch (s) {
      case 'requested':
        return BookingStatus.pendingLenderAcceptance;
      case 'preparing':
        return BookingStatus.lenderPreparing;
      case 'outForDelivery':
        return BookingStatus.inTransitToRenter;
      case 'delivered':
        return BookingStatus.deliveredToRenter;
      case 'refunded':
        return BookingStatus.cancelledByRenter;
      default:
        return BookingStatus.pendingPayment;
    }
  }
}

/// Booking pricing breakdown.
class BookingPricing {
  final int rentalDays;
  final double rentalFee;
  final double securityDeposit;
  final double deliveryFee;
  final double insuranceFee;
  final double discount;
  final double total;
  final bool includeInsurance;

  const BookingPricing({
    required this.rentalDays,
    required this.rentalFee,
    required this.securityDeposit,
    required this.deliveryFee,
    required this.insuranceFee,
    required this.discount,
    required this.total,
    required this.includeInsurance,
  });

  @override
  String toString() => 'BookingPricing(days: $rentalDays, total: $total)';
}
