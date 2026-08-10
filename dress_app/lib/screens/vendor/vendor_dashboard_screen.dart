import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/services/database_service.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/screens/vendor/vendor_inventory_screen.dart';
import 'package:dress_app/screens/vendor/vendor_add_item_screen.dart';
import 'package:dress_app/screens/vendor/vendor_bookings_screen.dart';
import 'package:dress_app/screens/vendor/vendor_financials_screen.dart';
import 'package:dress_app/screens/vendor/vendor_ratings_screen.dart';
import 'package:dress_app/screens/vendor/vendor_notifications_screen.dart';
import 'package:dress_app/screens/vendor/vendor_availability_screen.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  Map<String, dynamic> _analytics = const {};
  List<Map<String, dynamic>> _bookings = [];
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
      if (!mounted) return;
      setState(() {
        _analytics = analytics;
        _bookings = bookings;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _fmt(num? v) {
    if (v == null) return '0';
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE4F4FA),
              Color(0xFFF7F9FB),
              Color(0xFFF7F9FB),
            ],
            stops: [0.0, 0.2, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildOverviewCards(),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 16),
                  _buildRecentBookings(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isVendor = context.watch<AppState>().currentUser.isVendor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DASHBOARD',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              isVendor ? 'Business overview' : 'Become a lender',
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const VendorNotificationsScreen()));
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: const Icon(FluentIcons.alert_24_regular,
                color: AppTheme.textDark, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCards() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final totalRevenue = (_analytics['total_revenue'] as num?) ?? 0;
    final totalOrders = (_analytics['total_orders'] as num?) ?? 0;
    final activeListings = (_analytics['active_listings'] as num?) ?? 0;
    final pendingReturns = (_analytics['pending_returns'] as num?) ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    'Listings', _fmt(activeListings),
                    FluentIcons.box_24_regular, const Color(0xFF2E8A99))),
            const SizedBox(width: 10),
            Expanded(
                child: _buildStatCard('Rentals', _fmt(totalOrders),
                    FluentIcons.people_24_regular, Colors.orange)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: _buildStatCard('Pending', _fmt(pendingReturns),
                    FluentIcons.arrow_undo_24_regular, const Color(0xFFE53935))),
            const SizedBox(width: 10),
            Expanded(
                child: _buildStatCard('Earnings', '₹${_fmt(totalRevenue)}',
                    FluentIcons.money_24_regular, Colors.green)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick actions',
            style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: _buildActionCard(
                    context,
                    'Add item',
                    FluentIcons.add_circle_24_regular,
                    const Color(0xFF2E8A99), () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const VendorAddItemScreen()));
            })),
            const SizedBox(width: 10),
            Expanded(
                child: _buildActionCard(context, 'Bookings',
                    FluentIcons.calendar_24_regular, Colors.orange, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const VendorBookingsScreen()));
            })),
            const SizedBox(width: 10),
            Expanded(
                child: _buildActionCard(context, 'Earnings',
                    FluentIcons.money_24_regular, Colors.green, () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const VendorFinancialsScreen()));
            })),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: _buildActionCard(context, 'Inventory',
                    FluentIcons.box_24_regular, const Color(0xFF7B1FA2), () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const VendorInventoryScreen()));
            })),
            const SizedBox(width: 10),
            Expanded(
                child: _buildActionCard(context, 'Availability',
                    FluentIcons.calendar_clock_24_regular, const Color(0xFFE53935), () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const VendorAvailabilityScreen()));
            })),
            const SizedBox(width: 10),
            Expanded(
                child: _buildActionCard(context, 'Ratings',
                    FluentIcons.star_24_regular, Colors.amber, () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const VendorRatingsScreen()));
            })),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBookings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent bookings',
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const VendorBookingsScreen()));
              },
              child: Text('See all',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_bookings.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Center(
              child: Text('No bookings yet',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppTheme.textLight)),
            ),
          )
        else
          ...(_bookings.take(3).map((b) => _buildBookingRow(b))),
      ],
    );
  }

  Widget _buildBookingRow(Map<String, dynamic> b) {
    final status = (b['status'] ?? 'pending').toString();
    final total = (b['total_amount'] as num?)?.toDouble() ?? 0;
    final id = (b['id'] ?? '').toString();
    final idShort = id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
    Color statusColor;
    switch (status) {
      case 'completed':
      case 'returned':
        statusColor = Colors.green.shade700;
        break;
      case 'cancelled':
        statusColor = Colors.grey.shade700;
        break;
      case 'in_transit_to_renter':
      case 'return_scheduled':
        statusColor = Colors.teal.shade700;
        break;
      default:
        statusColor = Colors.orange.shade700;
    }
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
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(FluentIcons.calendar_24_regular, color: statusColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Booking #$idShort',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark)),
                Text(status.replaceAll('_', ' '),
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text('₹ ${total.toStringAsFixed(0)}',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark)),
        ],
      ),
    );
  }
}
