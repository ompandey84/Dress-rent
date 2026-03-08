import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/vendor/vendor_inventory_screen.dart';
import 'package:dress_app/screens/vendor/vendor_add_item_screen.dart';
import 'package:dress_app/screens/vendor/vendor_bookings_screen.dart';
import 'package:dress_app/screens/vendor/vendor_financials_screen.dart';
import 'package:dress_app/screens/vendor/vendor_ratings_screen.dart';
import 'package:dress_app/screens/vendor/vendor_notifications_screen.dart';
import 'package:dress_app/screens/vendor/vendor_availability_screen.dart';

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildOverviewCards(),
                const SizedBox(height: 24),
                _buildAnalyticsSection(),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildNotificationsPanel(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark, size: 20),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VENDOR DASHBOARD',
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  'Business Overview',
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorNotificationsScreen()));
          },
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Icon(FluentIcons.alert_24_regular, color: AppTheme.textDark, size: 22),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Total\nInventory', '48', FluentIcons.box_24_regular, const Color(0xFF2E8A99))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Active\nRentals', '12', FluentIcons.people_24_regular, Colors.orange)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Pending\nReturns', '5', FluentIcons.arrow_undo_24_regular, const Color(0xFFE53935))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Total\nEarnings', '₹45.2K', FluentIcons.money_24_regular, Colors.green)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
              const SizedBox(height: 2),
              Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, height: 1.3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Analytics', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
        const SizedBox(height: 16),

        // Weekly Rentals Graph
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Weekly Rentals', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF6F8FA), borderRadius: BorderRadius.circular(100)),
                    child: Text('This Week', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildBarChart(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Popular Dresses
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Popular Dresses', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
              const SizedBox(height: 16),
              _buildPopularItem('Premium Hoodie', '23 rentals', '⭐ 4.9', 0.9),
              const SizedBox(height: 12),
              _buildPopularItem('Denim Jacket', '18 rentals', '⭐ 4.7', 0.75),
              const SizedBox(height: 12),
              _buildPopularItem('Casual T-Shirt', '14 rentals', '⭐ 4.5', 0.6),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final data = [
      {'day': 'Mon', 'value': 0.4},
      {'day': 'Tue', 'value': 0.7},
      {'day': 'Wed', 'value': 0.5},
      {'day': 'Thu', 'value': 0.9},
      {'day': 'Fri', 'value': 0.6},
      {'day': 'Sat', 'value': 1.0},
      {'day': 'Sun', 'value': 0.3},
    ];

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((item) {
          final isMax = item['value'] == 1.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${((item['value'] as double) * 10).round()}',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textLight),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: (item['value'] as double) * 80,
                    decoration: BoxDecoration(
                      color: isMax ? AppTheme.primaryLime : const Color(0xFF2E8A99).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['day'] as String,
                    style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPopularItem(String name, String rentals, String rating, double progress) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8FA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(child: Icon(FluentIcons.tag_24_regular, size: 18, color: AppTheme.textDark)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: const Color(0xFFF6F8FA),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E8A99)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(rentals, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(rating, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildActionCard(context, 'Add New\nItem', FluentIcons.add_circle_24_regular, const Color(0xFF2E8A99), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorAddItemScreen()));
            })),
            const SizedBox(width: 12),
            Expanded(child: _buildActionCard(context, 'View\nBookings', FluentIcons.calendar_24_regular, Colors.orange, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorBookingsScreen()));
            })),
            const SizedBox(width: 12),
            Expanded(child: _buildActionCard(context, 'View\nEarnings', FluentIcons.money_24_regular, Colors.green, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorFinancialsScreen()));
            })),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionCard(context, 'Inventory', FluentIcons.box_24_regular, const Color(0xFF7B1FA2), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorInventoryScreen()));
            })),
            const SizedBox(width: 12),
            Expanded(child: _buildActionCard(context, 'Availability', FluentIcons.calendar_clock_24_regular, const Color(0xFFE53935), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorAvailabilityScreen()));
            })),
            const SizedBox(width: 12),
            Expanded(child: _buildActionCard(context, 'Ratings', FluentIcons.star_24_regular, Colors.amber, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorRatingsScreen()));
            })),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textDark, height: 1.3),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Notifications', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorNotificationsScreen()));
              },
              child: Text('See All', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildNotificationCard('New Booking', 'Premium Hoodie booked for Mar 20-23', '2m ago', FluentIcons.cart_24_regular, Colors.green),
        const SizedBox(height: 10),
        _buildNotificationCard('Return Reminder', 'Denim Jacket return due tomorrow', '1h ago', FluentIcons.arrow_undo_24_regular, Colors.orange),
        const SizedBox(height: 10),
        _buildNotificationCard('Payment Processed', '₹2,450 credited to your account', '3h ago', FluentIcons.money_24_regular, const Color(0xFF2E8A99)),
      ],
    );
  }

  Widget _buildNotificationCard(String title, String description, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textLight.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                const SizedBox(height: 3),
                Text(description, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(time, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight)),
        ],
      ),
    );
  }
}
