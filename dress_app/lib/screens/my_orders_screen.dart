import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/order_status/requested_order_screen.dart';
import 'package:dress_app/screens/order_status/preparing_order_screen.dart';
import 'package:dress_app/screens/order_status/out_for_delivery_screen.dart';
import 'package:dress_app/screens/order_status/delivered_order_screen.dart';
import 'package:dress_app/screens/order_status/refunded_order_screen.dart';
import 'package:dress_app/models/booking.dart';
import 'package:dress_app/models/order.dart';
import 'package:dress_app/services/booking_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  late Future<List<Booking>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _load();
  }

  Future<List<Booking>> _load() async {
    return BookingService().getMyBookings();
  }

  void _refresh() {
    setState(() {
      _ordersFuture = _load();
    });
  }

  _StatusVisual _statusFor(BookingStatus s) {
    switch (s) {
      case BookingStatus.pendingPayment:
        return const _StatusVisual(
          label: 'Awaiting payment',
          color: Color(0xFF6B7280),
          bg: Color(0xFFF3F4F6),
        );
      case BookingStatus.pendingLenderAcceptance:
        return const _StatusVisual(
          label: 'Requested',
          color: Color(0xFF1D4ED8),
          bg: Color(0xFFEFF6FF),
        );
      case BookingStatus.accepted:
      case BookingStatus.lenderPreparing:
        return const _StatusVisual(
          label: 'Preparing',
          color: Color(0xFFB45309),
          bg: Color(0xFFFFF7ED),
        );
      case BookingStatus.pickupScheduled:
      case BookingStatus.inTransitToRenter:
        return const _StatusVisual(
          label: 'Out for delivery',
          color: Color(0xFF0F766E),
          bg: Color(0xFFF0FDFA),
        );
      case BookingStatus.deliveredToRenter:
      case BookingStatus.inUse:
      case BookingStatus.returnScheduled:
      case BookingStatus.inTransitToLender:
        return const _StatusVisual(
          label: 'Delivered',
          color: Color(0xFF15803D),
          bg: Color(0xFFF0FDF4),
        );
      case BookingStatus.returned:
      case BookingStatus.completed:
        return const _StatusVisual(
          label: 'Completed',
          color: Color(0xFF15803D),
          bg: Color(0xFFF0FDF4),
        );
      case BookingStatus.cancelledByRenter:
      case BookingStatus.cancelledByLender:
      case BookingStatus.rejectedByLender:
        return const _StatusVisual(
          label: 'Cancelled',
          color: Color(0xFF991B1B),
          bg: Color(0xFFFEF2F2),
        );
      case BookingStatus.disputed:
        return const _StatusVisual(
          label: 'Dispute',
          color: Color(0xFFB45309),
          bg: Color(0xFFFFF7ED),
        );
    }
  }

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
          'MY RENTALS',
          style: GoogleFonts.inter(
            fontSize: 12,
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
              Color(0xFFE4F4FA),
              Color(0xFFF7F9FB),
              Color(0xFFF7F9FB),
            ],
            stops: [0.0, 0.2, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: FutureBuilder<List<Booking>>(
            future: _ordersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryLime),
                );
              }
              if (snapshot.hasError) {
                return _buildError(snapshot.error.toString());
              }
              final orders = snapshot.data ?? [];
              if (orders.isEmpty) return _buildEmpty();
              return RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  children: [
                    ...orders.map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildOrderCard(b),
                        )),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FluentIcons.box_24_regular,
            size: 48,
            color: AppTheme.textLight.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No rentals yet',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your rental history will appear here.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryLime,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: Text(
              'START RENTING',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FluentIcons.error_circle_24_regular,
                size: 40, color: Colors.red.shade400),
            const SizedBox(height: 12),
            Text(
              'Could not load your rentals',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _refresh, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Booking b) {
    final visual = _statusFor(b.status);
    final dateFmt = DateFormat('d MMM yyyy');
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => _openLegacyStatus(b)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _displayOrderId(b),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                      letterSpacing: 0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: visual.bg,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    visual.label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: visual.color,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                height: 1,
                color: AppTheme.textLight.withOpacity(0.1),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: b.listingImage != null && b.listingImage!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: b.listingImage!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade200,
                            child: const Icon(FluentIcons.box_24_regular, size: 20),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade200,
                          child: const Icon(FluentIcons.box_24_regular, size: 20),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${dateFmt.format(b.startDate)} → ${dateFmt.format(b.endDate)}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        b.listingTitle ?? 'Rental',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${b.rentalDays} day${b.rentalDays == 1 ? '' : 's'}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textLight,
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
                        fontSize: 10,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹ ${b.total.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View details',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  FluentIcons.chevron_right_24_regular,
                  size: 14,
                  color: AppTheme.textDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _displayOrderId(Booking b) {
    final num = b.orderNumber;
    if (num != null && num.isNotEmpty) return '#$num';
    final short = b.id.length >= 8 ? b.id.substring(0, 8).toUpperCase() : b.id.toUpperCase();
    return '#$short';
  }

  Widget _openLegacyStatus(Booking b) {
    final order = _toOrder(b);
    switch (b.status) {
      case BookingStatus.pendingLenderAcceptance:
        return RequestedOrderScreen(order: order);
      case BookingStatus.accepted:
      case BookingStatus.lenderPreparing:
        return PreparingOrderScreen(order: order);
      case BookingStatus.pickupScheduled:
      case BookingStatus.inTransitToRenter:
        return OutForDeliveryScreen(order: order);
      case BookingStatus.deliveredToRenter:
      case BookingStatus.inUse:
      case BookingStatus.returnScheduled:
      case BookingStatus.inTransitToLender:
      return DeliveredOrderScreen(order: order);
      case BookingStatus.returned:
      case BookingStatus.completed:
        return DeliveredOrderScreen(order: order);
      case BookingStatus.cancelledByRenter:
      case BookingStatus.cancelledByLender:
      case BookingStatus.rejectedByLender:
        return RefundedOrderScreen(order: order);
      case BookingStatus.disputed:
        return RefundedOrderScreen(order: order);
      case BookingStatus.pendingPayment:
        return RequestedOrderScreen(order: order);
    }
  }

  /// Adapt a `Booking` into a real `Order`. Uses the raw Supabase UUID for
  /// `id` (so cancel/return services work) and a pretty `displayId` for UI.
  Order _toOrder(Booking b) {
    final displayId = _formatDisplay(b);
    return Order(
      id: b.id,
      displayId: displayId,
      orderNumber: b.orderNumber,
      date: DateFormat('d MMM yyyy').format(b.createdAt),
      createdAt: b.createdAt,
      itemsCount: 1,
      totalPrice: b.total,
      status: _mapStatus(b.status),
      imageUrl: b.listingImage ?? '',
    );
  }

  static String _formatDisplay(Booking b) {
    final n = b.orderNumber;
    if (n != null && n.isNotEmpty) return '#$n';
    final short = b.id.length >= 8 ? b.id.substring(0, 8).toUpperCase() : b.id.toUpperCase();
    return '#$short';
  }

  static OrderStatus _mapStatus(BookingStatus s) {
    switch (s) {
      case BookingStatus.pendingPayment:
        return OrderStatus.requested;
      case BookingStatus.pendingLenderAcceptance:
        return OrderStatus.requested;
      case BookingStatus.accepted:
      case BookingStatus.lenderPreparing:
        return OrderStatus.preparing;
      case BookingStatus.pickupScheduled:
      case BookingStatus.inTransitToRenter:
        return OrderStatus.outForDelivery;
      case BookingStatus.deliveredToRenter:
      case BookingStatus.inUse:
      case BookingStatus.returnScheduled:
      case BookingStatus.inTransitToLender:
        return OrderStatus.delivered;
      case BookingStatus.returned:
      case BookingStatus.completed:
        return OrderStatus.delivered;
      case BookingStatus.cancelledByRenter:
      case BookingStatus.cancelledByLender:
      case BookingStatus.rejectedByLender:
        return OrderStatus.refunded;
      case BookingStatus.disputed:
        return OrderStatus.refunded;
    }
  }
}

class _StatusVisual {
  final String label;
  final Color color;
  final Color bg;
  const _StatusVisual({required this.label, required this.color, required this.bg});
}
