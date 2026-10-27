import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/models/cart_item.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/screens/select_dates_screen.dart';
import 'package:dress_app/utils/auth_guard.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const _currency = '₹';

  Future<void> _proceedToCheckout() async {
    // Require login before checkout
    if (!await AuthGuard.requireLogin(
      context,
      message: 'Please sign in to checkout. You need an account to place orders and track deliveries.',
    )) return;
    if (!mounted) return;

    final cartItems = context.read<AppState>().cartItems;
    if (cartItems.isEmpty) return;

    // Show a note when there are multiple items — each rental is a separate order.
    if (cartItems.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Each rental is a separate order. You\'ll check out ${cartItems.length} items one at a time.',
            style: GoogleFonts.inter(),
          ),
        ),
      );
      // Continue after 1.2s so the user sees the message.
      await Future.delayed(const Duration(milliseconds: 1200));
    }

    if (!mounted) return;
    final first = cartItems.first;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectDatesScreen(
          product: first.product,
          selectedSize: first.selectedSize,
          selectedColor: first.selectedColor,
        ),
      ),
    );
  }

  /// Live delivery fee for the cart preview (mirrors BookingService rules).
  /// Free for 3+ day rentals, otherwise ₹49.
  double _deliveryFee() {
    if (context.watch<AppState>().cartItems.isEmpty) return 0;
    return 49.0;
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = context.watch<AppState>().cartItems;
    final subtotal = context.watch<AppState>().cartTotal;
    final delivery = subtotal > 0 ? _deliveryFee() : 0.0;
    final total = subtotal + delivery;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'BAG',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppTheme.textDark,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FluentIcons.shopping_bag_24_regular,
                    size: 64,
                    color: AppTheme.textLight.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your bag is empty',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Browse and tap the cart icon on any product',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 24,
                      bottom: 100,
                    ),
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) => const Divider(height: 32),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartRow(item);
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
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
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
                            Text(
                              'Subtotal',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.textLight,
                              ),
                            ),
                            Text(
                              '$_currency ${subtotal.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Delivery (est.)',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.textLight,
                              ),
                            ),
                            Text(
                              delivery == 0 ? 'FREE' : '$_currency ${delivery.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: delivery == 0 ? AppTheme.success : AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Estimated Total',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                            ),
                            Text(
                              '$_currency ${total.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryLime,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Final price depends on rental dates & insurance',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _proceedToCheckout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.textDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'SELECT DATES & BOOK',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
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

  Widget _buildCartRow(CartItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                item.product.images.isNotEmpty ? item.product.images.first : '',
              ),
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
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.read<AppState>().removeFromCart(item.id);
                    },
                    child: const Icon(
                      FluentIcons.dismiss_20_regular,
                      size: 20,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.product.name,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
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
                    child: Text(
                      'Size: ${item.selectedSize}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8FA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.rentalDates,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '$_currency ${item.product.price.toStringAsFixed(0)} / day',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryLime,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
