import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:dress_app/services/auth_service.dart';

/// Wallet transaction kinds.
enum WalletTxnType {
  topup,         // money added by user (Cashfree/UPI)
  depositPaid,   // held as security for a booking
  depositRefund, // returned to wallet after safe return
  ugcCredit,     // earned via UGC posts
  referralBonus, // referral sign-up
  cashback,      // promotional cashback
  withdraw,      // sent to bank account
  damageClaim,   // deducted due to damage claim
}

extension WalletTxnTypeX on WalletTxnType {
  String get code => name;
  bool get isCredit => this == WalletTxnType.topup || this == WalletTxnType.depositRefund
      || this == WalletTxnType.ugcCredit || this == WalletTxnType.referralBonus
      || this == WalletTxnType.cashback;
}

/// A single wallet transaction.
class WalletTransaction {
  final String id;
  final String userId;
  final WalletTxnType type;
  final double amount; // always positive; sign comes from `type.isCredit`
  final String description;
  final String? bookingId;
  final String? sourceTxnId;
  final double balanceAfter;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    this.bookingId,
    this.sourceTxnId,
    required this.balanceAfter,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) => WalletTransaction(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    type: WalletTxnType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => WalletTxnType.topup,
    ),
    amount: (json['amount'] as num).toDouble(),
    description: json['description'] as String? ?? '',
    bookingId: json['order_id'] as String?,
    sourceTxnId: json['source_txn_id'] as String?,
    balanceAfter: (json['balance_after'] as num).toDouble(),
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

/// Engine that tracks the refundable security deposit and overall wallet balance.
///
/// ## Logic
/// 1. `getBalance()` — current available balance (topup + refunds, NOT counting
///    deposits currently held as escrow).
/// 2. `lockDeposit(amount, bookingId)` — moves `amount` from available balance
///    into a held escrow pool for a specific booking. This does NOT change the
///    total balance but does reduce what's available for new bookings.
/// 3. `releaseDeposit(bookingId)` — returns the held escrow to available balance
///    (after a safe return).
/// 4. `claimDeposit(bookingId, amount)` — partially captures the held escrow as
///    a damage claim; the remainder (if any) is released.
/// 5. `topUp(amount, source)` — adds money to the wallet via Cashfree/UPI/etc.
/// 6. `canCoverDeposit(amount)` — true if available balance ≥ amount.
/// 7. `depositShortfall(amount)` — 0 if balance covers it, else the gap.
///
/// The "deposit" is the *refundable security deposit* required per booking.
/// Different listings have different deposit amounts (set on the listing).
class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  // -------- in-memory mock state --------
  double _mockAvailable = 2450.0;
  double _mockHeld = 0.0;
  final List<WalletTransaction> _mockTxns = [];
  // Map<bookingId, heldAmount> for what is currently locked as escrow
  final Map<String, double> _mockHeldByBooking = {};

  // ------------------------ BALANCE ------------------------

  /// Available balance = topups + refunds - currently held escrow.
  Future<double> getAvailableBalance() async {
    if (!SupabaseService.isConfigured) {
      return _mockAvailable;
    }
    final userId = AuthService().currentUserId;
    if (userId == null || userId.isEmpty) {
      // Guest user — no real wallet yet
      return 0.0;
    }
    final supabase = Supabase.instance.client;
    final res = await supabase
        .from('wallet_transactions')
        .select('amount, type')
        .eq('user_id', userId);
    double total = 0;
    double held = 0;
    final heldBookings = <String, double>{};
    for (final row in (res as List)) {
      final type = WalletTxnType.values.firstWhere(
        (t) => t.name == row['type'],
        orElse: () => WalletTxnType.topup,
      );
      final amt = (row['amount'] as num).toDouble();
      if (type == WalletTxnType.depositPaid) {
        held += amt;
        final bid = row['order_id'] as String?;
        if (bid != null) heldBookings[bid] = (heldBookings[bid] ?? 0) + amt;
      } else if (type.isCredit) {
        total += amt;
      } else {
        total -= amt;
      }
    }
    // Available = total - held (held entries don't add to total)
    _mockHeldByBooking.clear();
    _mockHeldByBooking.addAll(heldBookings);
    return total - held;
  }

  /// Total balance = available + currently held in escrow.
  /// In live mode we sum directly from the wallet_transactions table.
  Future<double> getTotalBalance() async {
    if (!SupabaseService.isConfigured) return _mockAvailable + _mockHeld;
    final userId = AuthService().currentUserId;
    if (userId == null || userId.isEmpty) return 0.0;
    final supabase = Supabase.instance.client;
    final res = await supabase
        .from('wallet_transactions')
        .select('amount, type')
        .eq('user_id', userId);
    double total = 0;
    for (final row in (res as List)) {
      final type = WalletTxnType.values.firstWhere(
        (t) => t.name == row['type'],
        orElse: () => WalletTxnType.topup,
      );
      final amt = (row['amount'] as num).toDouble();
      if (type == WalletTxnType.depositPaid) {
        // held escrow counts toward the user's total
        total += amt;
      } else if (type.isCredit) {
        total += amt;
      } else {
        total -= amt;
      }
    }
    return total;
  }

  /// Currently held in escrow (depositPaid minus any matching depositRefund).
  Future<double> getHeldBalance() async {
    if (!SupabaseService.isConfigured) return _mockHeld;
    final userId = AuthService().currentUserId;
    if (userId == null || userId.isEmpty) return 0.0;
    final supabase = Supabase.instance.client;
    final res = await supabase
        .from('wallet_transactions')
        .select('amount, order_id, type')
        .eq('user_id', userId)
        .inFilter('type', [
          WalletTxnType.depositPaid.code,
          WalletTxnType.depositRefund.code,
        ]);
    final heldByBooking = <String, double>{};
    for (final row in (res as List)) {
      final type = WalletTxnType.values.firstWhere(
        (t) => t.name == row['type'],
        orElse: () => WalletTxnType.topup,
      );
      final amt = (row['amount'] as num).toDouble();
      final bid = row['order_id'] as String?;
      if (bid == null) continue;
      heldByBooking[bid] = (heldByBooking[bid] ?? 0) +
          (type == WalletTxnType.depositPaid ? amt : -amt);
    }
    _mockHeldByBooking.clear();
    heldByBooking.forEach((k, v) {
      if (v > 0) _mockHeldByBooking[k] = v;
    });
    return heldByBooking.values.fold<double>(0, (s, v) => s + (v > 0 ? v : 0));
  }

  // ------------------------ CHECKS ------------------------

  /// True if available balance can fully cover the deposit.
  Future<bool> canCoverDeposit(double amount) async {
    final bal = await getAvailableBalance();
    return bal >= amount;
  }

  /// 0 if balance covers the deposit; otherwise the shortfall that must be topped up.
  Future<double> depositShortfall(double amount) async {
    final bal = await getAvailableBalance();
    final gap = amount - bal;
    return gap > 0 ? gap : 0;
  }

  // ------------------------ TRANSACTIONS ------------------------

  /// Top up wallet via external payment (Cashfree).
  Future<WalletTransaction> topUp({
    required double amount,
    String source = 'cashfree',
    String? externalRef,
  }) async {
    if (amount <= 0) throw ArgumentError('Top-up amount must be > 0');
    final userId = AuthService().currentUserId ?? 'mock_user';
    final id = 'wt_${DateTime.now().millisecondsSinceEpoch}';

    if (!SupabaseService.isConfigured) {
      _mockAvailable += amount;
      final txn = WalletTransaction(
        id: id,
        userId: userId,
        type: WalletTxnType.topup,
        amount: amount,
        description: 'Added ₹${amount.toStringAsFixed(0)} via $source',
        sourceTxnId: externalRef,
        balanceAfter: _mockAvailable,
        createdAt: DateTime.now(),
      );
      _mockTxns.add(txn);
      await Future.delayed(const Duration(milliseconds: 200));
      return txn;
    }

    final supabase = Supabase.instance.client;
    final res = await supabase.from('wallet_transactions').insert({
      'user_id': userId,
      'type': WalletTxnType.topup.code,
      'amount': amount,
      'description': 'Added ₹${amount.toStringAsFixed(0)} via $source',
      'source_txn_id': externalRef,
    }).select().single();
    return WalletTransaction.fromJson(res);
  }

  /// Lock `amount` from the available balance as escrow for a booking.
  /// Returns the held amount and the shortfall (0 if fully covered).
  /// If `amountToChargeExternally` > 0, that amount is also recorded as a topup
  /// (representing a Cashfree top-up for the shortfall) before locking.
  Future<({double held, double shortfall, double externalTopup})> lockDeposit({
    required double amount,
    required String bookingId,
    double amountToChargeExternally = 0,
  }) async {
    final userId = AuthService().currentUserId ?? 'mock_user';

    // No deposit required for this booking — no-op.
    if (amount <= 0) {
      return (held: 0.0, shortfall: 0.0, externalTopup: 0.0);
    }

    if (!SupabaseService.isConfigured) {
      // 1. Top up if needed
      if (amountToChargeExternally > 0) {
        await topUp(amount: amountToChargeExternally, source: 'cashfree_deposit_topup');
      }
      // 2. Lock the deposit
      _mockAvailable -= amount;
      _mockHeld += amount;
      _mockHeldByBooking[bookingId] = amount;
      final txn = WalletTransaction(
        id: 'wt_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        type: WalletTxnType.depositPaid,
        amount: amount,
        description: 'Deposit held for booking $bookingId',
        bookingId: bookingId,
        balanceAfter: _mockAvailable,
        createdAt: DateTime.now(),
      );
      _mockTxns.add(txn);
      await Future.delayed(const Duration(milliseconds: 200));
      return (held: amount.toDouble(), shortfall: 0.0, externalTopup: amountToChargeExternally);
    }

    final supabase = Supabase.instance.client;
    // 1. Top up shortfall if any
    if (amountToChargeExternally > 0) {
      await topUp(amount: amountToChargeExternally, source: 'cashfree_deposit_topup');
    }
    // 2. Record the hold
    await supabase.from('wallet_transactions').insert({
      'user_id': userId,
      'type': WalletTxnType.depositPaid.code,
      'amount': amount,
      'description': 'Deposit held for booking $bookingId',
      'order_id': bookingId,
    });
    return (held: amount.toDouble(), shortfall: 0.0, externalTopup: amountToChargeExternally);
  }

  /// Release the held deposit back to the available balance.
  /// Called after the item is safely returned.
  Future<WalletTransaction> releaseDeposit(String bookingId) async {
    final userId = AuthService().currentUserId ?? 'mock_user';
    final heldAmount = _mockHeldByBooking[bookingId] ?? 0.0;

    if (!SupabaseService.isConfigured) {
      _mockHeld -= heldAmount;
      _mockAvailable += heldAmount;
      _mockHeldByBooking.remove(bookingId);
      final txn = WalletTransaction(
        id: 'wt_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        type: WalletTxnType.depositRefund,
        amount: heldAmount,
        description: 'Deposit refunded for booking $bookingId',
        bookingId: bookingId,
        balanceAfter: _mockAvailable,
        createdAt: DateTime.now(),
      );
      _mockTxns.add(txn);
      await Future.delayed(const Duration(milliseconds: 200));
      return txn;
    }

    final supabase = Supabase.instance.client;
    // Find the original depositPaid record for this booking
    final orig = await supabase
        .from('wallet_transactions')
        .select()
        .eq('order_id', bookingId)
        .eq('type', WalletTxnType.depositPaid.code)
        .maybeSingle();
    final amt = orig == null ? 0.0 : (orig['amount'] as num).toDouble();
    final origId = orig?['id'] as String?;
    if (amt > 0) {
      await supabase.from('wallet_transactions').insert({
        'user_id': userId,
        'type': WalletTxnType.depositRefund.code,
        'amount': amt,
        'description': 'Deposit refunded for booking $bookingId',
        'order_id': bookingId,
        'source_txn_id': origId,
      });
    }
    // Use the freshly recomputed balance so the UI stays in sync.
    final newBalance = await getAvailableBalance();
    return WalletTransaction(
      id: 'refund_$bookingId',
      userId: userId,
      type: WalletTxnType.depositRefund,
      amount: amt,
      description: 'Deposit refunded',
      bookingId: bookingId,
      balanceAfter: newBalance,
      createdAt: DateTime.now(),
    );
  }

  /// Claim part of the deposit for damage. Releases the remainder.
  Future<WalletTransaction> claimDeposit({
    required String bookingId,
    required double claimAmount,
    String? notes,
  }) async {
    final userId = AuthService().currentUserId ?? 'mock_user';
    final held = _mockHeldByBooking[bookingId] ?? 0;
    final refund = (held - claimAmount).clamp(0, held).toDouble();

    if (!SupabaseService.isConfigured) {
      _mockHeld -= held;
      if (refund > 0) _mockAvailable += refund;
      _mockHeldByBooking.remove(bookingId);
      final txn = WalletTransaction(
        id: 'wt_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        type: WalletTxnType.damageClaim,
        amount: claimAmount,
        description: 'Damage claim: ₹${claimAmount.toStringAsFixed(0)} (refunded ₹${refund.toStringAsFixed(0)})',
        bookingId: bookingId,
        balanceAfter: _mockAvailable,
        createdAt: DateTime.now(),
      );
      _mockTxns.add(txn);
      await Future.delayed(const Duration(milliseconds: 200));
      return txn;
    }

    final supabase = Supabase.instance.client;
    // record the claim
    await supabase.from('wallet_transactions').insert({
      'user_id': userId,
      'type': WalletTxnType.damageClaim.code,
      'amount': claimAmount,
      'description': notes ?? 'Damage claim',
      'order_id': bookingId,
    });
    // release remainder
    if (refund > 0) {
      await releaseDeposit(bookingId);
    }
    final newBalance = await getAvailableBalance();
    return WalletTransaction(
      id: 'claim_$bookingId',
      userId: userId,
      type: WalletTxnType.damageClaim,
      amount: claimAmount,
      description: notes ?? 'Damage claim',
      bookingId: bookingId,
      balanceAfter: newBalance,
      createdAt: DateTime.now(),
    );
  }

  // ------------------------ HISTORY ------------------------

  Future<List<WalletTransaction>> recentTransactions({int limit = 50}) async {
    if (!SupabaseService.isConfigured) {
      return List.of(_mockTxns.reversed).take(limit).toList();
    }
    final userId = AuthService().currentUserId;
    if (userId == null || userId.isEmpty) return [];
    final supabase = Supabase.instance.client;
    final res = await supabase
        .from('wallet_transactions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);
    return (res as List).map((m) => WalletTransaction.fromJson(m)).toList();
  }
}
