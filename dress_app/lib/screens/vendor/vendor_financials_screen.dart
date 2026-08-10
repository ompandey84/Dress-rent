import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/services/database_service.dart';
import 'package:dress_app/services/wallet_service.dart';
import 'package:dress_app/services/auth_service.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:dress_app/screens/payouts_screen.dart';

class VendorFinancialsScreen extends StatefulWidget {
  const VendorFinancialsScreen({super.key});

  @override
  State<VendorFinancialsScreen> createState() => _VendorFinancialsScreenState();
}

class _VendorFinancialsScreenState extends State<VendorFinancialsScreen> {
  Map<String, dynamic> _analytics = const {};
  List<Map<String, dynamic>> _transactions = [];
  double _walletBalance = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = DatabaseService();
    try {
      final analytics = await db.getVendorAnalytics() ?? const {};
      final bookings = await db.getVendorBookings();
      final wallet = WalletService();
      final balance = await wallet.getAvailableBalance();
      // Build a transactions list from completed orders.
      final txns = bookings
          .where((b) =>
              (b['status'] == 'completed' || b['status'] == 'returned'))
          .map((b) => {
                'id': b['id'] ?? '',
                'amount': (b['total_amount'] as num?)?.toDouble() ?? 0,
                'created_at': b['created_at'],
                'status': 'Credited',
              })
          .toList();
      if (!mounted) return;
      setState(() {
        _analytics = analytics;
        _transactions = txns;
        _walletBalance = balance;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _fmt(num? v) {
    if (v == null || v == 0) return '0';
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(2)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'FINANCIALS',
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
              letterSpacing: 1.0),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryLime))
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTotalEarningsCard(),
                    const SizedBox(height: 20),
                    _buildMonthlyChart(),
                    const SizedBox(height: 20),
                    _buildRecentTransactions(),
                    const SizedBox(height: 20),
                    _buildDownloadButton(),
                    const SizedBox(height: 12),
                    _buildPayoutsButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTotalEarningsCard() {
    final total = (_analytics['total_revenue'] as num?) ?? 0;
    final pending = (_walletBalance * 0).toDouble();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C222B), Color(0xFF2E3A4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1C222B).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total earnings',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('₹ ${_fmt(total)}',
              style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5)),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text('All-time',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.green.shade300,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 6),
              Text('across ${_transactions.length} rentals',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Wallet',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('₹ ${_fmt(_walletBalance)}',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Orders',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(_fmt(_analytics['total_orders'] as num?),
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryLime)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    // Aggregate transactions by month
    final byMonth = <String, double>{};
    for (final t in _transactions) {
      final ts = t['created_at']?.toString();
      if (ts == null) continue;
      try {
        final dt = DateTime.parse(ts);
        final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
        byMonth[key] = (byMonth[key] ?? 0) + ((t['amount'] as num?)?.toDouble() ?? 0);
      } catch (_) {}
    }
    final entries = byMonth.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final maxVal = entries.isEmpty
        ? 1.0
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly earnings',
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('No completed rentals yet',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppTheme.textLight)),
              ),
            )
          else
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: entries.map((e) {
                  final ratio = maxVal == 0 ? 0.0 : e.value / maxVal;
                  final month = e.key.split('-').last;
                  final isLatest = e == entries.last;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('₹ ${_fmt(e.value)}',
                              style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: isLatest
                                      ? AppTheme.textDark
                                      : AppTheme.textLight)),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: ratio * 70 + 4,
                            decoration: BoxDecoration(
                              color: isLatest
                                  ? AppTheme.primaryLime
                                  : const Color(0xFF2E8A99).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(month,
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppTheme.textLight,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent transactions',
            style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
        const SizedBox(height: 10),
        if (_transactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Center(
              child: Text('No completed rentals to show yet',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppTheme.textLight)),
            ),
          )
        else
          ..._transactions.take(10).map((t) {
            final id = (t['id'] ?? '').toString();
            final idShort = id.length > 8
                ? id.substring(0, 8).toUpperCase()
                : id.toUpperCase();
            final amount = (t['amount'] as num?)?.toDouble() ?? 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(FluentIcons.arrow_download_24_regular,
                        color: Colors.green, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Booking #$idShort',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark)),
                        Text('Credited',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppTheme.textLight,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Text('₹ ${amount.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark)),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildDownloadButton() {
    return GestureDetector(
      onTap: () {
        final total = (_analytics['total_revenue'] as num?) ?? 0;
        final bookings = (_analytics['total_orders'] as num?) ?? 0;
        final summary =
            'Dress vendor financial summary\n'
            'Lifetime: ₹${total.toStringAsFixed(0)} across $bookings bookings';
        Share.share(summary, subject: 'Dress — Financial Report');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report ready to share',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.primaryLime,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
                color: AppTheme.primaryLime.withOpacity(0.3),
                offset: const Offset(0, 6),
                blurRadius: 12),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(FluentIcons.arrow_download_24_regular,
                color: AppTheme.textDark, size: 18),
            const SizedBox(width: 8),
            Text(
              'SHARE REPORT',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                  letterSpacing: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoutsButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => PayoutsScreen()));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.textDark, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppTheme.primaryLime,
                shape: BoxShape.circle,
              ),
              child: const Icon(FluentIcons.wallet_credit_card_24_regular,
                  size: 18, color: AppTheme.textDark),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('View detailed payouts',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark)),
                  Text('Weekly cycle, history & next payout',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppTheme.textLight)),
                ],
              ),
            ),
            const Icon(FluentIcons.chevron_right_24_regular,
                size: 16, color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }
}
