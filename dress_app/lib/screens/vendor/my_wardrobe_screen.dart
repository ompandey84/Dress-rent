import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/screens/vendor/vendor_signup_screen.dart';
import 'package:dress_app/screens/vendor/vendor_dashboard_screen.dart';
import 'package:dress_app/screens/profile_screen.dart';
import 'package:dress_app/screens/my_orders_screen.dart';

class MyWardrobeScreen extends StatefulWidget {
  const MyWardrobeScreen({Key? key}) : super(key: key);

  @override
  State<MyWardrobeScreen> createState() => _MyWardrobeScreenState();
}

class _MyWardrobeScreenState extends State<MyWardrobeScreen> {

  @override
  Widget build(BuildContext context) {
    final isVendor = Provider.of<AppState>(context).currentUser.isVendor;

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
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                if (!isVendor) ...[
                  _buildBecomeVendorCard(context),
                  const SizedBox(height: 32),
                  _buildRentalHistory(),
                ] else ...[
                  _buildVendorQuickAccess(context),
                  const SizedBox(height: 24),
                  _buildRentalHistory(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MY WARDROBE',
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your rentals & vendor hub',
              style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textLight),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              FluentIcons.settings_24_regular,
              color: AppTheme.textDark,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBecomeVendorCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C222B), Color(0xFF2E3A4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C222B).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryLime.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              FluentIcons.store_microsoft_24_regular,
              color: AppTheme.primaryLime,
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'BECOME A VENDOR',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start renting out your dresses and earn money. Join our vendor community today!',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildBenefitChip('💰 Earn Money'),
              const SizedBox(width: 8),
              _buildBenefitChip('📦 Easy Setup'),
              const SizedBox(width: 8),
              _buildBenefitChip('⭐ Grow'),
            ],
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VendorSignupScreen()),
              );
              // State is handled by AppState now, no need to manually setState
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppTheme.primaryLime,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Text(
                  'GET STARTED',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildVendorQuickAccess(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1C222B), Color(0xFF2E3A4A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1C222B).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLime.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      FluentIcons.store_microsoft_24_regular,
                      color: AppTheme.primaryLime,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VENDOR MODE',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage your dress listings',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Active',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VendorDashboardScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLime,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      'OPEN VENDOR DASHBOARD',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildQuickStatCard('Active\nListings', '12', FluentIcons.tag_24_regular, const Color(0xFF2E8A99))),
            const SizedBox(width: 12),
            Expanded(child: _buildQuickStatCard('Pending\nOrders', '3', FluentIcons.clock_24_regular, Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _buildQuickStatCard('This Month\nEarnings', 'AED 8.5K', FluentIcons.money_24_regular, Colors.green)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textLight.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, height: 1.3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRentalHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Rentals',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen()));
              },
              child: Text(
                'See All',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildRentalCard(
          'Premium Hoodie',
          'Mar 15 – Mar 18',
          'AED 295.00',
          'Active',
          'https://images.unsplash.com/photo-1556821840-3a63f95609a7?q=80&w=200&auto=format&fit=crop',
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildRentalCard(
          'Denim Jacket',
          'Feb 20 – Feb 23',
          'AED 350.00',
          'Returned',
          'https://images.unsplash.com/photo-1516257984-b1b4d707412e?q=80&w=200&auto=format&fit=crop',
          AppTheme.textLight,
        ),
        const SizedBox(height: 12),
        _buildRentalCard(
          'Casual T-Shirt',
          'Feb 10 – Feb 12',
          'AED 150.00',
          'Returned',
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=200&auto=format&fit=crop',
          AppTheme.textLight,
        ),
      ],
    );
  }

  Widget _buildRentalCard(String name, String dates, String price, String status, String imgUrl, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textLight.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imgUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                const SizedBox(height: 4),
                Text(dates, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
