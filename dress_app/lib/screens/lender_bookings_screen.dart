import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/booking.dart';
import 'package:dress_app/services/booking_service.dart';
import 'package:dress_app/services/mock_data_service.dart';
import 'package:dress_app/services/auth_service.dart';
import 'package:dress_app/screens/lender_booking_detail_screen.dart';
import 'package:dress_app/screens/pack_item_screen.dart';

/// Lender view: incoming rental requests & active rentals.
class LenderBookingsScreen extends StatefulWidget {
  const LenderBookingsScreen({Key? key}) : super(key: key);

  @override
  State<LenderBookingsScreen> createState() => _LenderBookingsScreenState();
}

class _LenderBookingsScreenState extends State<LenderBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Booking>> _pendingFuture;
  late Future<List<Booking>> _activeFuture;
  late Future<List<Booking>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
  }

  void _loadAll() {
    _pendingFuture = _loadBookingsByStatus([
      BookingStatus.pendingLenderAcceptance,
    ]);
    _activeFuture = _loadBookingsByStatus([
      BookingStatus.accepted,
      BookingStatus.lenderPreparing,
      BookingStatus.pickupScheduled,
      BookingStatus.inTransitToRenter,
      BookingStatus.deliveredToRenter,
      BookingStatus.inUse,
      BookingStatus.returnScheduled,
      BookingStatus.inTransitToLender,
    ]);
    _historyFuture = _loadBookingsByStatus([
      BookingStatus.returned,
      BookingStatus.completed,
      BookingStatus.cancelledByRenter,
      BookingStatus.cancelledByLender,
      BookingStatus.rejectedByLender,
    ]);
  }

  Future<List<Booking>> _loadBookingsByStatus(List<BookingStatus> statuses) async {
    // In mock mode, synthesize some lender-side bookings
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return [];
    final all = await BookingService().getMyBookings();
    return all;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('MY RENTALS',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.textDark,
          unselectedLabelColor: AppTheme.textLight,
          labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          indicatorColor: AppTheme.textDark,
          indicatorWeight: 2.5,
          tabs: const [
            Tab(text: 'NEW'),
            Tab(text: 'ACTIVE'),
            Tab(text: 'HISTORY'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BookingList(future: _pendingFuture, emptyMessage: 'No pending requests'),
          _BookingList(future: _activeFuture, emptyMessage: 'No active rentals'),
          _BookingList(future: _historyFuture, emptyMessage: 'No past rentals'),
        ],
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final Future<List<Booking>> future;
  final String emptyMessage;
  const _BookingList({required this.future, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Booking>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryLime));
        }
        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FluentIcons.calendar_24_regular, size: 48, color: AppTheme.textLight.withOpacity(0.5)),
                const SizedBox(height: 12),
                Text(emptyMessage, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _BookingCard(booking: bookings[i]),
          ),
        );
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final isPending = booking.status == BookingStatus.pendingLenderAcceptance;
    final isPreparing = booking.status == BookingStatus.lenderPreparing || booking.status == BookingStatus.accepted;
    return GestureDetector(
      onTap: () {
        if (isPending) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => LenderBookingDetailScreen(booking: booking)));
        } else if (isPreparing) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PackItemScreen()));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: booking.listingImage ?? 'https://placehold.co/200x250',
                      width: 70,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${booking.orderNumber}',
                          style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight, fontWeight: FontWeight.w800, letterSpacing: 1.0),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          booking.listingTitle ?? 'Premium Outfit',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, height: 1.2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${DateFormat('d MMM').format(booking.startDate)} → ${DateFormat('d MMM').format(booking.endDate)}',
                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: booking.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      booking.status.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: booking.status.color,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isPending) _AcceptTimerBar(booking: booking),
            if (isPreparing) _PackActionBar(),
          ],
        ),
      ),
    );
  }
}

/// Bar showing 4h countdown to auto-cancel.
class _AcceptTimerBar extends StatefulWidget {
  final Booking booking;
  const _AcceptTimerBar({required this.booking});

  @override
  State<_AcceptTimerBar> createState() => _AcceptTimerBarState();
}

class _AcceptTimerBarState extends State<_AcceptTimerBar> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining = _calculateRemaining();
        if (_remaining.isNegative) {
          _timer?.cancel();
        }
      });
    });
  }

  Duration _calculateRemaining() {
    final accepted = widget.booking.acceptedAt ?? widget.booking.createdAt;
    final deadline = accepted.add(const Duration(hours: 4));
    return deadline.difference(DateTime.now());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urgent = _remaining.inMinutes < 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: urgent ? const Color(0xFFFFEBEE) : AppTheme.primaryLime.withOpacity(0.2),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(
            urgent ? FluentIcons.alert_24_regular : FluentIcons.timer_24_regular,
            size: 14,
            color: urgent ? Colors.red.shade700 : AppTheme.textDark,
          ),
          const SizedBox(width: 6),
          Text(
            urgent ? 'Auto-cancel in ' : 'Accept within ',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: urgent ? Colors.red.shade700 : AppTheme.textDark,
            ),
          ),
          Text(
            _formatRemaining(_remaining),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: urgent ? Colors.red.shade700 : AppTheme.textDark,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LenderBookingDetailScreen(booking: widget.booking)),
              );
            },
            child: Row(
              children: [
                Text('Review', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                const SizedBox(width: 4),
                const Icon(FluentIcons.chevron_right_24_regular, size: 12, color: AppTheme.textDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatRemaining(Duration d) {
    if (d.isNegative) return 'Expired';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _PackActionBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8E1),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const Icon(FluentIcons.box_24_regular, size: 14, color: Color(0xFFE65100)),
          const SizedBox(width: 6),
          Text('Pack item & schedule pickup', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textDark, fontWeight: FontWeight.w700)),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PackItemScreen())),
            child: Row(
              children: [
                Text('Pack now', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                const SizedBox(width: 4),
                const Icon(FluentIcons.chevron_right_24_regular, size: 12, color: AppTheme.textDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
