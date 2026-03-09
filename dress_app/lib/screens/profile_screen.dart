import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/rating_screen.dart';
import 'package:dress_app/screens/my_orders_screen.dart';
import 'package:dress_app/screens/edit_profile_screen.dart';
import 'package:dress_app/screens/wishlist_screen.dart';
import 'package:dress_app/screens/help_support_screen.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/models/order.dart';
import 'package:dress_app/screens/vendor/vendor_signup_screen.dart';
import 'package:dress_app/screens/legal_content_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        // Removed leading back button since this is a bottom nav screen
      ),
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            final user = appState.currentUser;
            final inProgressOrders = appState.orders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.refunded).length;
            
            return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Header
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryLime, width: 3),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(user.avatarUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.name.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Verified',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, size: 14, color: Colors.green),
                  const SizedBox(width: 16),
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    user.rating.toStringAsFixed(1),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    ' (${user.reviewsCount} Reviews)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Order',
                      appState.orders.length.toString(),
                      FluentIcons.cart_24_regular,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'On progress',
                      inProgressOrders.toString(),
                      FluentIcons.clipboard_24_regular,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Reviews',
                      user.rating.toStringAsFixed(1),
                      FluentIcons.star_24_regular,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Settings',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Settings List
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                  );
                },
                child: _buildSettingsItem(
                  FluentIcons.receipt_24_regular,
                  'My Orders',
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
                child: _buildSettingsItem(
                  FluentIcons.person_24_regular,
                  'Personal Information',
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WishlistScreen()),
                  );
                },
                child: _buildSettingsItem(
                  FluentIcons.heart_24_regular,
                  'My Wishlist',
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RatingScreen()),
                  );
                },
                child: _buildSettingsItem(
                  FluentIcons.star_24_regular,
                  'App Feedback',
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                  );
                },
                child: _buildSettingsItem(
                  FluentIcons.chat_help_24_regular,
                  'Help & Support',
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VendorSignupScreen()),
                  );
                },
                child: _buildSettingsItem(
                  FluentIcons.building_shop_24_regular,
                  'Become a Vendor',
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LegalContentScreen(title: 'Terms & Conditions')),
                  );
                },
                child: _buildSettingsItem(
                  FluentIcons.document_text_24_regular,
                  'Terms & Conditions',
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LegalContentScreen(title: 'Privacy Policy')),
                  );
                },
                child: _buildSettingsItem(
                  FluentIcons.shield_24_regular,
                  'Privacy Policy',
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LegalContentScreen(title: 'About App')),
                  );
                },
                child: _buildSettingsItem(
                  FluentIcons.info_24_regular,
                  'About App',
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  _showDeleteAccountDialog(context);
                },
                child: _buildSettingsItem(
                  FluentIcons.delete_24_regular,
                  'Delete Account',
                  isDestructive: true,
                ),
              ),
              const SizedBox(height: 32),
              
              // Logout Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    // Navigate back to login (mock)
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.red.shade100)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(FluentIcons.arrow_exit_20_regular, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'SIGN OUT',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textLight.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
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
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Delete Account?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.red),
        ),
        content: Text(
          'This action is permanent and cannot be undone. All your data will be removed.',
          style: GoogleFonts.inter(color: AppTheme.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.textLight),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: Text(
              'DELETE',
              style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, {bool isDestructive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textLight.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDestructive ? Colors.red : AppTheme.textLight, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.red : AppTheme.textDark,
              ),
            ),
          ),
          Icon(
            FluentIcons.chevron_right_24_regular,
            color: isDestructive ? Colors.red.withValues(alpha: 0.3) : AppTheme.textLight,
            size: 20,
          ),
        ],
      ),
    );
  }
}
