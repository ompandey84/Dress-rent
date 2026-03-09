import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistedProducts = context.watch<AppState>().wishlistedProducts;

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
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0),
        ),
      ),
      body: wishlistedProducts.isEmpty 
        ? _buildEmptyState() 
        : GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
              childAspectRatio: 0.5,
            ),
            itemCount: wishlistedProducts.length,
            itemBuilder: (context, index) {
              return ProductCard(product: wishlistedProducts[index], imageHeight: 180);
            },
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FluentIcons.heart_24_regular, size: 60, color: AppTheme.textLight.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Your Wishlist is Empty',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Save your favorite dresses to rent later.',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }

}
