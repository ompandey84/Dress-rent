import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/screens/checkout_screen.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartItems = context.watch<AppState>().cartItems;
    final double subtotal = context.watch<AppState>().cartTotal;
    final double total = subtotal > 0 ? subtotal + 25.0 : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'BAG',
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5),
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FluentIcons.shopping_bag_24_regular, size: 64, color: AppTheme.textLight.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Your bag is empty',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 100),
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) => const Divider(height: 32),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(item.product.images.isNotEmpty ? item.product.images.first : ''),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.product.storeName,
                                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        context.read<AppState>().removeFromCart(item.id);
                                      },
                                      child: const Icon(FluentIcons.dismiss_20_regular, size: 20, color: AppTheme.textLight),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.product.name,
                                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF6F8FA),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text('Size: ${item.selectedSize}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF6F8FA),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(item.rentalDates, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'AED ${item.product.price.toStringAsFixed(2)}',
                                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryLime),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                
                // Bottom section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight)),
                            Text('AED ${subtotal.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Estimated Total', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                            Text('AED ${total.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryLime)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              if (cartItems.isNotEmpty) {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(cartItems: cartItems)));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.textDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              elevation: 0,
                            ),
                            child: Text(
                              'PROCEED TO CHECKOUT',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
