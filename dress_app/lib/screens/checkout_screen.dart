import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/product.dart';
import 'package:dress_app/screens/shipping_address_screen.dart';
import 'dart:async';
import 'package:dress_app/screens/add_card_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Product product;
  const CheckoutScreen({super.key, required this.product});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Mock Data
  String rentalDates = 'Mar 15 - Mar 18, 2026';
  bool isPromoApplied = false;
  Duration timeRemaining = const Duration(minutes: 10, seconds: 0);
  Timer? _timer;
  final TextEditingController _promoController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining.inSeconds > 0) {
        setState(() {
          timeRemaining -= const Duration(seconds: 1);
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _promoController.dispose();
    super.dispose();
  }

  int _selectedAddressIndex = 0;
  final List<Map<String, dynamic>> _addresses = [
    {
      'title': 'Home',
      'address': '123 Marina Blvd, Dubai Marina, UAE',
      'icon': FluentIcons.home_24_regular,
    },
    {
      'title': 'Office',
      'address': '456 Business Bay, Dubai, UAE',
      'icon': FluentIcons.building_24_regular,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ORDER PREPARATION',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Inventory Lock Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(FluentIcons.timer_24_regular, color: Colors.orange.shade800, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Item reserved. Complete checkout in ${timeRemaining.inMinutes.toString().padLeft(2, '0')}:${(timeRemaining.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.orange.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Cart Item Section
                Text('YOUR ITEM', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textLight, letterSpacing: 1.0)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: widget.product.images.isNotEmpty ? Image.network(
                          widget.product.images.first,
                          width: 80,
                          height: 100,
                          fit: BoxFit.cover,
                        ) : Container(
                          width: 80,
                          height: 100,
                          color: Colors.grey.shade200,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name.toUpperCase(),
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Size: ${widget.product.sizes.isNotEmpty ? widget.product.sizes.first : 'N/A'} • ${widget.product.colors.isNotEmpty ? widget.product.colors.first : 'N/A'}',
                              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight),
                            ),
                            const SizedBox(height: 12),
                            // Rental Dates
                            Row(
                              children: [
                                const Icon(FluentIcons.calendar_ltr_24_regular, size: 14, color: AppTheme.textLight),
                                const SizedBox(width: 4),
                                Text(
                                  rentalDates,
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Delivery Address Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('SHIPPING TO', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textLight, letterSpacing: 1.0)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ShippingAddressScreen(product: widget.product))).then((newAddress) {
                          if (newAddress != null) {
                            setState(() {
                              _addresses.add(newAddress as Map<String, dynamic>);
                              _selectedAddressIndex = _addresses.length - 1;
                            });
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLime.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primaryLime),
                        ),
                        child: Text('+ Add New Address', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryLime)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: List.generate(_addresses.length, (index) {
                    bool isSelected = _selectedAddressIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAddressIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryLime.withValues(alpha: 0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isSelected ? AppTheme.primaryLime : Colors.grey.shade200, width: isSelected ? 2 : 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : const Color(0xFFF6F8FA),
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected ? Border.all(color: AppTheme.primaryLime.withValues(alpha: 0.3)) : null,
                              ),
                              child: Icon(_addresses[index]['icon'] as IconData, color: isSelected ? AppTheme.primaryLime : AppTheme.textDark),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_addresses[index]['title'] as String, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                                      if (isSelected) 
                                        const Icon(FluentIcons.checkmark_circle_24_filled, color: AppTheme.primaryLime, size: 20),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(_addresses[index]['address'] as String, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Promo Code
                Text('PROMO CODE', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textLight, letterSpacing: 1.0)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F8FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(FluentIcons.ticket_diagonal_24_regular, color: AppTheme.textDark, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _promoController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter promo code',
                            hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_promoController.text.trim().isNotEmpty) {
                            setState(() {
                              isPromoApplied = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Promo code applied successfully!'), backgroundColor: Colors.green));
                          }
                        },
                        child: Text('Apply', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Price Breakdown
                Text('ORDER SUMMARY', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textLight, letterSpacing: 1.0)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Builder(
                    builder: (context) {
                      double discount = isPromoApplied ? 20.0 : 0.0;
                      double total = widget.product.price + 20 + 100 - discount;
                      
                      return Column(
                        children: [
                          _buildSummaryRow('Rental Price (3 days)', 'AED ${widget.product.price.toStringAsFixed(2)}'),
                          const SizedBox(height: 12),
                          _buildSummaryRow('Delivery Fee (2.5 km)', 'AED 20.00'),
                          const SizedBox(height: 12),
                          _buildSummaryRow('Security Deposit (Refundable)', 'AED 100.00'),
                          const SizedBox(height: 12),
                          _buildSummaryRow('Discount', '- AED ${discount.toStringAsFixed(2)}', color: Colors.green),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                              Text('AED ${total.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFF0C6B86))),
                            ],
                          ),
                        ],
                      );
                    }
                  ),
                ),
              ],
            ),
          ),
          
          // Floating Bottom Continue Button
          Positioned(
            bottom: 15, // 15px padding
            left: 24,
            right: 24,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryLime,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryLime.withValues(alpha: 0.3), offset: const Offset(0, 8), blurRadius: 15),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddCardScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: Center(
                  child: Text(
                    'CONTINUE TO PAYMENT',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight)),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color ?? AppTheme.textDark)),
      ],
    );
  }
}
