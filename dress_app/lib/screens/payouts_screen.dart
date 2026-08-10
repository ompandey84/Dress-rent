import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:intl/intl.dart';
import 'package:dress_app/theme.dart';

/// Lender payouts — earnings, history, upcoming payout.
class PayoutsScreen extends StatelessWidget {
  PayoutsScreen({Key? key}) : super(key: key);

  // Mock data
  final _thisWeekEarnings = 12450.0;
  final _pendingEarnings = 3200.0;
  final _nextPayoutDate = DateTime.now().add(const Duration(days: 3));
  final _lifetimeEarnings = 84200.0;
  final _totalBookings = 47;

  final List<Map<String, dynamic>> _history = [
    {'date': DateTime(2026, 8, 8), 'amount': 8500.0, 'bookings': 4, 'status': 'paid'},
    {'date': DateTime(2026, 8, 1), 'amount': 11200.0, 'bookings': 6, 'status': 'paid'},
    {'date': DateTime(2026, 7, 25), 'amount': 9800.0, 'bookings': 5, 'status': 'paid'},
    {'date': DateTime(2026, 7, 18), 'amount': 7300.0, 'bookings': 3, 'status': 'paid'},
  ];

  final List<double> _weeklyEarnings = [7800, 9200, 8500, 11200, 9800, 7300, 12450];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('EARNINGS & PAYOUTS',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0)),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Bank', style: GoogleFonts.inter(color: AppTheme.textDark, fontWeight: FontWeight.w800, fontSize: 13)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('THIS WEEK',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white70, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text('₹${_thisWeekEarnings.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.primaryLime, borderRadius: BorderRadius.circular(100)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(FluentIcons.arrow_trending_24_regular, size: 12, color: AppTheme.textDark),
                            const SizedBox(width: 4),
                            Text('+12% vs last week', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text('${_totalBookings} total bookings',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Pending',
                    value: '₹${_pendingEarnings.toStringAsFixed(0)}',
                    icon: FluentIcons.clock_24_regular,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Lifetime',
                    value: '₹${(_lifetimeEarnings / 1000).toStringAsFixed(1)}k',
                    icon: FluentIcons.trophy_24_regular,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Next payout
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryLime, width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppTheme.primaryLime, shape: BoxShape.circle),
                    child: Icon(FluentIcons.building_bank_24_regular, color: AppTheme.textDark, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Next payout',
                            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                        Text('${DateFormat('EEEE, d MMM').format(_nextPayoutDate)}',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                        Text('HDFC ****1234',
                            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Text('₹${_thisWeekEarnings.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Custom bar chart (no fl_chart dependency)
            Text('Last 7 weeks', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                height: 180,
                child: _buildWeeklyChart(),
              ),
            ),
            const SizedBox(height: 24),

            // History
            Text('Recent payouts', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            ..._history.map((h) => _buildHistoryRow(h)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    if (_weeklyEarnings.isEmpty) {
      return Center(
        child: Text('No payout history yet',
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
      );
    }
    const labels = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'];
    final maxVal = _weeklyEarnings.fold<double>(
        0, (m, v) => v > m ? v : m);
    final maxY = maxVal <= 0 ? 1.0 : maxVal * 1.2;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(_weeklyEarnings.length, (i) {
        final ratio = maxY == 0 ? 0.0 : _weeklyEarnings[i] / maxY;
        final isLatest = i == _weeklyEarnings.length - 1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '₹${_weeklyEarnings[i].toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isLatest ? AppTheme.textDark : AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: ratio * 110 + 4,
                  decoration: BoxDecoration(
                    color: isLatest
                        ? AppTheme.primaryLime
                        : AppTheme.textDark,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  i < labels.length ? labels[i] : 'W${i + 1}',
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHistoryRow(Map<String, dynamic> h) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
            child: Icon(FluentIcons.checkmark_24_regular, color: Colors.green.shade700, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${h['bookings']} bookings • Week of ${DateFormat('d MMM').format(h['date'])}',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                Text('Bank transfer',
                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text('₹${(h['amount'] as double).toStringAsFixed(0)}',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
        ],
      ),
    );
  }
}
