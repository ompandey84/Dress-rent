import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/product.dart';
import 'package:dress_app/services/wishlist_service.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/screens/login_screen.dart';
import 'package:dress_app/widgets/product_card.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late Future<List<Product>> _wishlistFuture;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  void _loadWishlist() {
    final userId = context.read<AppState>().currentUser.id;
    setState(() {
      _wishlistFuture = WishlistService().getWishlist(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = context.watch<AppState>().isGuest;
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'MY WISHLIST',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0),
        ),
      ),
      body: isGuest
          ? _buildGuestPrompt(context)
          : FutureBuilder<List<Product>>(
              future: _wishlistFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primaryLime));
                }
                if (snapshot.hasError) {
                  return _buildEmptyState(
                    'Your wishlist is empty',
                    'Save items you love 💛',
                  );
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return _buildEmptyState(
                    'Your wishlist is empty',
                    'Save items you love 💛',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _loadWishlist(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final product = items[index];
                      return ProductCard(
                        product: product,
                        imageHeight: 200,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FluentIcons.heart_24_regular,
              size: 64, color: AppTheme.textLight.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppTheme.textLight)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppTheme.textLight)),
        ],
      ),
    );
  }

  Widget _buildGuestPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FluentIcons.heart_24_regular,
                size: 64, color: AppTheme.textLight.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Sign in to save items',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your wishlist will sync across devices once you sign up.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textLight,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'SIGN IN',
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
        ),
      ),
    );
  }
}
