import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/order_status/requested_order_screen.dart';
import 'package:dress_app/screens/order_status/preparing_order_screen.dart';
import 'package:dress_app/screens/order_status/out_for_delivery_screen.dart';
import 'package:dress_app/screens/order_status/delivered_order_screen.dart';
import 'package:dress_app/screens/order_status/refunded_order_screen.dart';
import 'package:dress_app/models/order.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final orders = context.watch<AppState>().orders;

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FluentIcons.box_24_regular, size: 60, color: AppTheme.textLight.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No Orders Yet',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Your rental history will appear here.',
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLime,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: Text(
                'START RENTING',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ...orders.map((order) {
          Color statusColor;
                Color bgColor;
                String statusLabel;
                Widget targetScreen;

                switch (order.status) {
                  case OrderStatus.requested:
                    statusColor = Colors.blue.shade700;
                    bgColor = Colors.blue.shade50;
                    statusLabel = 'Requested';
                    targetScreen = RequestedOrderScreen(order: order);
                    break;
                  case OrderStatus.preparing:
                    statusColor = Colors.orange.shade800;
                    bgColor = Colors.orange.shade50;
                    statusLabel = 'Preparing Order';
                    targetScreen = PreparingOrderScreen(order: order);
                    break;
                  case OrderStatus.outForDelivery:
                    statusColor = Colors.teal.shade700;
                    bgColor = Colors.teal.shade50;
                    statusLabel = 'Out for Delivery';
                    targetScreen = OutForDeliveryScreen(order: order);
                    break;
                  case OrderStatus.delivered:
                    statusColor = Colors.green.shade700;
                    bgColor = Colors.green.shade50;
                    statusLabel = 'Delivered';
                    targetScreen = DeliveredOrderScreen(order: order);
                    break;
                  case OrderStatus.refunded:
                    statusColor = Colors.red.shade700;
                    bgColor = Colors.red.shade50;
                    statusLabel = 'Refunded';
                    targetScreen = RefundedOrderScreen(order: order);
                    break;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildOrderItem(
                    context,
                    id: order.id,
                    date: order.date,
                    items: order.itemsCount,
                    price: 'AED ${order.totalPrice.toStringAsFixed(2)}',
                    status: statusLabel,
                    statusColor: statusColor,
                    bgColor: bgColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => targetScreen),
                    ),
                    imageUrl: order.imageUrl,
                  ),
                );
              }).toList(),
      ],
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
    required String imageUrl,
  }) {

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
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
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
