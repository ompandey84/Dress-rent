import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:cashfree_pg/cashfree_pg.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/services/supabase_service.dart';

/// Cashfree payment gateway integration.
///
/// This package is older, but the integration still works for Android.
/// The flow is:
/// 1. Backend (Supabase Edge Function) creates a Cashfree order
/// 2. We get back `payment_session_id` and use it as the `tokenData`
/// 3. Open Cashfree checkout via `CashfreePGSDK.doPayment()`
/// 4. Cashfree notifies our webhook
/// 5. We verify status from backend
class CashfreeService {
  static final CashfreeService _instance = CashfreeService._internal();
  factory CashfreeService() => _instance;
  CashfreeService._internal();

  // Safe env accessors
  String get _environment {
    try {
      return dotenv.env['CASHFREE_ENV'] ?? 'SANDBOX';
    } catch (_) {
      return 'SANDBOX';
    }
  }

  String get _appId {
    try {
      return dotenv.env['CASHFREE_APP_ID'] ?? '';
    } catch (_) {
      return '';
    }
  }

  bool get isConfigured {
    return _appId.isNotEmpty && !_appId.contains('YOUR_');
  }

  /// No-op initialization (kept for API compatibility).
  Future<void> initialize() async {
    // The cashfree_pg package doesn't need explicit init
  }

  /// Create a Cashfree order via our backend (Supabase Edge Function).
  Future<CashfreeOrder> createOrder({
    required String orderId,
    required double amount,
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    Map<String, dynamic>? metadata,
  }) async {
    if (!isConfigured) {
      // Mock order for development
      return CashfreeOrder(
        orderId: orderId,
        paymentSessionId: 'mock_session_$orderId',
        amount: amount,
        currency: 'INR',
      );
    }

    if (!SupabaseService.isConfigured) {
      throw Exception('Supabase not configured — cannot create order');
    }

    final supabase = Supabase.instance.client;
    final response = await supabase.functions.invoke(
      'cashfree-create-order',
      body: {
        'order_id': orderId,
        'order_amount': amount,
        'order_currency': 'INR',
        'customer_details': {
          'customer_id': customerId,
          'customer_name': customerName,
          'customer_email': customerEmail,
          'customer_phone': customerPhone,
        },
        'order_meta': metadata ?? {},
      },
    );

    if (response.status != 200) {
      throw Exception('Failed to create Cashfree order: ${response.data}');
    }

    return CashfreeOrder.fromJson(response.data as Map<String, dynamic>);
  }

  /// Open the Cashfree checkout sheet.
  Future<CashfreePaymentResult> openCheckout({
    required CashfreeOrder order,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) async {
    if (!isConfigured) {
      // Mock checkout for development
      await Future.delayed(const Duration(seconds: 2));
      return CashfreePaymentResult.success(
        orderId: order.orderId,
        paymentId: 'mock_payment_${DateTime.now().millisecondsSinceEpoch}',
        method: 'MOCK',
      );
    }

    try {
      final stage = _environment == 'PRODUCTION' ? 'PROD' : 'TEST';

      final inputs = {
        'stage': stage,
        'appId': _appId,
        'orderId': order.orderId,
        'orderAmount': order.amount,
        'orderCurrency': order.currency,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
        'tokenData': order.paymentSessionId,
      };

      final response = await CashfreePGSDK.doPayment(inputs);

      if (response == null) {
        return CashfreePaymentResult.failure('No response from Cashfree');
      }

      final txStatus = response['txStatus'] as String?;
      final txMsg = response['txMsg'] as String? ?? '';
      final cfPaymentId = response['cfPaymentId'] as String? ?? '';

      if (txStatus == 'SUCCESS') {
        return CashfreePaymentResult.success(
          orderId: order.orderId,
          paymentId: cfPaymentId,
          method: response['paymentMode'] as String? ?? 'UNKNOWN',
        );
      } else if (txStatus == 'CANCELLED') {
        return CashfreePaymentResult.cancelled();
      } else {
        return CashfreePaymentResult.failure(txMsg.isNotEmpty ? txMsg : 'Payment failed');
      }
    } catch (e) {
      return CashfreePaymentResult.failure(e.toString());
    }
  }

  /// Verify payment status from backend.
  Future<CashfreePaymentStatus> verifyPayment(String orderId) async {
    if (!isConfigured || !SupabaseService.isConfigured) {
      return CashfreePaymentStatus(
        orderId: orderId,
        status: 'PAID',
        amount: 0,
      );
    }

    final supabase = Supabase.instance.client;
    final response = await supabase.functions.invoke(
      'cashfree-verify-order',
      body: {'order_id': orderId},
    );

    if (response.status != 200) {
      throw Exception('Failed to verify payment: ${response.data}');
    }

    return CashfreePaymentStatus.fromJson(response.data as Map<String, dynamic>);
  }

  /// Refund a payment.
  Future<CashfreeRefundResult> refund({
    required String orderId,
    required double amount,
    String? reason,
  }) async {
    if (!isConfigured || !SupabaseService.isConfigured) {
      return CashfreeRefundResult(
        refundId: 'mock_refund_${DateTime.now().millisecondsSinceEpoch}',
        status: 'SUCCESS',
        amount: amount,
      );
    }

    final supabase = Supabase.instance.client;
    final response = await supabase.functions.invoke(
      'cashfree-refund',
      body: {
        'order_id': orderId,
        'refund_amount': amount,
        'reason': reason ?? 'Customer request',
      },
    );

    if (response.status != 200) {
      throw Exception('Failed to refund: ${response.data}');
    }

    return CashfreeRefundResult.fromJson(response.data as Map<String, dynamic>);
  }
}

// ============== Data Models ==============

class CashfreeOrder {
  final String orderId;
  final String paymentSessionId;
  final double amount;
  final String currency;

  CashfreeOrder({
    required this.orderId,
    required this.paymentSessionId,
    required this.amount,
    required this.currency,
  });

  factory CashfreeOrder.fromJson(Map<String, dynamic> json) {
    return CashfreeOrder(
      orderId: json['order_id'] as String,
      paymentSessionId: json['payment_session_id'] as String,
      amount: (json['order_amount'] as num).toDouble(),
      currency: json['order_currency'] as String? ?? 'INR',
    );
  }
}

class CashfreePaymentResult {
  final bool isSuccess;
  final bool isCancelled;
  final String? orderId;
  final String? paymentId;
  final String? method;
  final String? errorMessage;

  const CashfreePaymentResult._({
    required this.isSuccess,
    required this.isCancelled,
    this.orderId,
    this.paymentId,
    this.method,
    this.errorMessage,
  });

  factory CashfreePaymentResult.success({
    required String orderId,
    required String paymentId,
    required String method,
  }) =>
      CashfreePaymentResult._(
        isSuccess: true,
        isCancelled: false,
        orderId: orderId,
        paymentId: paymentId,
        method: method,
      );

  factory CashfreePaymentResult.cancelled() =>
      const CashfreePaymentResult._(isSuccess: false, isCancelled: true);

  factory CashfreePaymentResult.failure(String error) =>
      CashfreePaymentResult._(
        isSuccess: false,
        isCancelled: false,
        errorMessage: error,
      );
}

class CashfreePaymentStatus {
  final String orderId;
  final String status; // 'PAID', 'ACTIVE', 'EXPIRED', 'TERMINATED'
  final double amount;
  final String? paymentId;
  final String? method;

  CashfreePaymentStatus({
    required this.orderId,
    required this.status,
    required this.amount,
    this.paymentId,
    this.method,
  });

  factory CashfreePaymentStatus.fromJson(Map<String, dynamic> json) {
    return CashfreePaymentStatus(
      orderId: json['order_id'] as String,
      status: json['order_status'] as String,
      amount: (json['order_amount'] as num).toDouble(),
      paymentId: json['cf_payment_id'] as String?,
      method: json['payment_group'] as String?,
    );
  }

  bool get isPaid => status == 'PAID';
}

class CashfreeRefundResult {
  final String refundId;
  final String status;
  final double amount;

  CashfreeRefundResult({
    required this.refundId,
    required this.status,
    required this.amount,
  });

  factory CashfreeRefundResult.fromJson(Map<String, dynamic> json) {
    return CashfreeRefundResult(
      refundId: json['refund_id'] as String,
      status: json['refund_status'] as String,
      amount: (json['refund_amount'] as num).toDouble(),
    );
  }
}
