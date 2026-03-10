class VendorAnalytics {
  final String id;
  final String vendorProfileId;
  final int totalInventory;
  final int activeRentals;
  final int pendingReturns;
  final double totalEarnings;
  final double thisMonthEarnings;
  final double pendingPayments;
  final double earningsTrendPercent;

  VendorAnalytics({
    required this.id,
    required this.vendorProfileId,
    this.totalInventory = 0,
    this.activeRentals = 0,
    this.pendingReturns = 0,
    this.totalEarnings = 0.0,
    this.thisMonthEarnings = 0.0,
    this.pendingPayments = 0.0,
    this.earningsTrendPercent = 0.0,
  });

  factory VendorAnalytics.fromJson(Map<String, dynamic> json) {
    return VendorAnalytics(
      id: json['id'] as String,
      vendorProfileId: json['vendor_profile_id'] as String? ?? '',
      totalInventory: json['total_inventory'] as int? ?? 0,
      activeRentals: json['active_rentals'] as int? ?? 0,
      pendingReturns: json['pending_returns'] as int? ?? 0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      thisMonthEarnings: (json['this_month_earnings'] as num?)?.toDouble() ?? 0.0,
      pendingPayments: (json['pending_payments'] as num?)?.toDouble() ?? 0.0,
      earningsTrendPercent: (json['earnings_trend_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
