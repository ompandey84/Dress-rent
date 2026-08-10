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
import 'package:dress_app/screens/login_screen.dart';
import 'package:dress_app/screens/lend/lend_flow_screen.dart';
import 'package:dress_app/screens/wallet/wallet_screen.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/models/order.dart';
import 'package:dress_app/screens/vendor/vendor_signup_screen.dart';
import 'package:dress_app/screens/vendor/vendor_inventory_screen.dart';
import 'package:dress_app/screens/vendor/vendor_financials_screen.dart';
import 'package:dress_app/screens/legal_content_screen.dart';
import 'package:dress_app/services/auth_service.dart';
import 'package:dress_app/screens/main_navigation.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            if (appState.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryLime),
              );
            }

            final user = appState.currentUser;
            final isGuest = appState.isGuest;
            final inProgressOrders = appState.orders
                .where((o) =>
                    o.status != OrderStatus.delivered &&
                    o.status != OrderStatus.refunded)
                .length;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Header
                  _buildAvatar(user.avatarUrl, user.name),
                  const SizedBox(height: 12),
                  Text(
                    isGuest ? 'GUEST USER' : user.name.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isGuest) ...[
                        Text(
                          user.isVerified ? 'Verified' : 'Unverified',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          size: 12,
                          color: user.isVerified
                              ? Colors.green
                              : AppTheme.textLight,
                        ),
                        const SizedBox(width: 14),
                        const Icon(Icons.star,
                            size: 12, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          user.rating.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          ' (${user.reviewsCount})',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Sign in to access all features',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isGuest) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryLime,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'SIGN IN / SIGN UP',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Lend your wardrobe CTA (moved from home)
                  _buildLendCta(context),
                  const SizedBox(height: 20),

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
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          'On progress',
                          inProgressOrders.toString(),
                          FluentIcons.clipboard_24_regular,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 10),
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
                  const SizedBox(height: 24),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Settings',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Settings List
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyOrdersScreen(),
                        ),
                      );
                    },
                    child: _buildSettingsItem(
                      FluentIcons.receipt_24_regular,
                      'My Rentals',
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WalletScreen(),
                        ),
                      );
                    },
                    child: _buildSettingsItem(
                      FluentIcons.wallet_24_regular,
                      'My Wallet',
                    ),
                  ),
                  if (user.isVendor) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VendorInventoryScreen(),
                          ),
                        );
                      },
                      child: _buildSettingsItem(
                        FluentIcons.tag_24_regular,
                        'My Listings',
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const VendorFinancialsScreen(),
                          ),
                        );
                      },
                      child: _buildSettingsItem(
                        FluentIcons.money_24_regular,
                        'Earnings',
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                    child: _buildSettingsItem(
                      FluentIcons.person_24_regular,
                      'Personal Information',
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WishlistScreen(),
                        ),
                      );
                    },
                    child: _buildSettingsItem(
                      FluentIcons.heart_24_regular,
                      'My Wishlist',
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RatingScreen(),
                        ),
                      );
                    },
                    child: _buildSettingsItem(
                      FluentIcons.star_24_regular,
                      'App Feedback',
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen(),
                        ),
                      );
                    },
                    child: _buildSettingsItem(
                      FluentIcons.chat_help_24_regular,
                      'Help & Support',
                    ),
                  ),
                  if (!user.isVendor) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VendorSignupScreen(),
                          ),
                        );
                      },
                      child: _buildSettingsItem(
                        FluentIcons.building_shop_24_regular,
                        'Become a Vendor',
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalContentScreen(
                            title: 'Terms & Conditions',
                          ),
                        ),
                      );
                    },
                    child: _buildSettingsItem(
                      FluentIcons.document_text_24_regular,
                      'Terms & Conditions',
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalContentScreen(
                            title: 'Privacy Policy',
                          ),
                        ),
                      );
                    },
                    child: _buildSettingsItem(
                      FluentIcons.shield_24_regular,
                      'Privacy Policy',
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalContentScreen(
                            title: 'About App',
                          ),
                        ),
                      );
                    },
                    child: _buildSettingsItem(
                      FluentIcons.info_24_regular,
                      'About App',
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 20),

                  // Logout Button
                  if (!isGuest)
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () async {
                          await AuthService().signOut();
                          if (context.mounted) {
                            await context.read<AppState>().signOut();
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const MainNavigation(),
                                ),
                                (route) => false,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Signed out'),
                                ),
                              );
                            }
                          }
                        },
                        style: TextButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.red.shade100),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              FluentIcons.arrow_exit_20_regular,
                              color: Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'SIGN OUT',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatar(String avatarUrl, String name) {
    final hasAvatar = avatarUrl.isNotEmpty;
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.primaryLime, width: 2.5),
        color: AppTheme.primaryLime,
      ),
      alignment: Alignment.center,
      child: hasAvatar
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatarUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _initialLetter(name),
              ),
            )
          : _initialLetter(name),
    );
  }

  Widget _initialLetter(String name) {
    final letter =
        name.isNotEmpty && name != 'Guest' ? name[0].toUpperCase() : '?';
    return Text(
      letter,
      style: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: AppTheme.textDark,
      ),
    );
  }

  Widget _buildLendCta(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LendFlowScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1C222B), Color(0xFF2E3A4A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
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
              child: const Icon(
                FluentIcons.tag_24_regular,
                size: 16,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lend your wardrobe',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Earn ₹3k–8k / month from idle outfits',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white60,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryLime,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'START',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.textLight.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Account?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            color: Colors.red,
            fontSize: 14,
          ),
        ),
        content: Text(
          'This action is permanent and cannot be undone. All your data will be removed.',
          style: GoogleFonts.inter(
            color: AppTheme.textLight,
            fontSize: 12,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: AppTheme.textLight,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (context.mounted) {
                await context.read<AppState>().signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const MainNavigation(),
                    ),
                    (route) => false,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Account deletion requested — we'll be in touch.",
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(
              'DELETE',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title, {
    bool isDestructive = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.textLight.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive ? Colors.red : AppTheme.textLight,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.red : AppTheme.textDark,
              ),
            ),
          ),
          Icon(
            FluentIcons.chevron_right_24_regular,
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.3)
                : AppTheme.textLight,
            size: 16,
          ),
        ],
      ),
    );
  }
}
