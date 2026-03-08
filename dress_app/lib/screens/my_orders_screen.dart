import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/order_status/requested_order_screen.dart';
import 'package:dress_app/screens/order_status/preparing_order_screen.dart';
import 'package:dress_app/screens/order_status/out_for_delivery_screen.dart';
import 'package:dress_app/screens/order_status/delivered_order_screen.dart';
import 'package:dress_app/screens/order_status/refunded_order_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            FluentIcons.chevron_left_24_regular,
            color: AppTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'MY ORDERS',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE4F4FA), // Very light pale blue at top
              Color(0xFFF7F9FB), // Light background
              Color(0xFFF7F9FB),
            ],
            stops: [0.0, 0.2, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildOrderItem(
                context,
                id: '#ORD-9821',
                date: '18 Oct 2023',
                items: 2,
                price: 'AED 415.00',
                status: 'Requested',
                statusColor: Colors.blue.shade700,
                bgColor: Colors.blue.shade50,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RequestedOrderScreen()),
                ),
                imageIndex: 1,
              ),
              const SizedBox(height: 16),
              _buildOrderItem(
                context,
                id: '#ORD-9820',
                date: '17 Oct 2023',
                items: 1,
                price: 'AED 295.00',
                status: 'Preparing Order',
                statusColor: Colors.orange.shade800,
                bgColor: Colors.orange.shade50,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PreparingOrderScreen()),
                ),
                imageIndex: 2,
              ),
              const SizedBox(height: 16),
              _buildOrderItem(
                context,
                id: '#ORD-9815',
                date: '16 Oct 2023',
                items: 3,
                price: 'AED 850.00',
                status: 'Out for Delivery',
                statusColor: Colors.teal.shade700,
                bgColor: Colors.teal.shade50,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const OutForDeliveryScreen()),
                ),
                imageIndex: 3,
              ),
              const SizedBox(height: 16),
              _buildOrderItem(
                context,
                id: '#ORD-9799',
                date: '10 Oct 2023',
                items: 1,
                price: 'AED 150.00',
                status: 'Delivered',
                statusColor: Colors.green.shade700,
                bgColor: Colors.green.shade50,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DeliveredOrderScreen()),
                ),
                imageIndex: 4,
              ),
              const SizedBox(height: 16),
              _buildOrderItem(
                context,
                id: '#ORD-9750',
                date: '5 Oct 2023',
                items: 1,
                price: 'AED 350.00',
                status: 'Refunded',
                statusColor: Colors.red.shade700,
                bgColor: Colors.red.shade50,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RefundedOrderScreen()),
                ),
                imageIndex: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(
    BuildContext context, {
    required String id,
    required String date,
    required int items,
    required String price,
    required String status,
    required Color statusColor,
    required Color bgColor,
    required VoidCallback onTap,
    required int imageIndex,
  }) {
    // Generate different placeholder images
    final images = [
      'https://images.unsplash.com/photo-1516257984-b1b4d707412e?q=80&w=200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1618932260643-eee4a2f652a6?q=80&w=200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1556821840-3a63f95609a7?q=80&w=200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?q=80&w=200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1529374255404-311a2a4f1fd9?q=80&w=200&auto=format&fit=crop',
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  id,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                  height: 1, color: AppTheme.textLight.withOpacity(0.1)),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    images[imageIndex],
                    width: 65,
                    height: 65,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$items Items',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      price,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0C6B86),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View Details',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  FluentIcons.chevron_right_24_regular,
                  size: 16,
                  color: AppTheme.textDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
