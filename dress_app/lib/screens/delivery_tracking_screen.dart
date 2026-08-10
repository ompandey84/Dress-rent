import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/booking.dart';
import 'package:dress_app/services/database_service.dart';
import 'package:dress_app/services/mock_data_service.dart';
import 'package:dress_app/screens/reject_at_delivery_screen.dart';

/// Live delivery tracking — both renter & lender see this.
class DeliveryTrackingScreen extends StatefulWidget {
  final Booking booking;
  const DeliveryTrackingScreen({Key? key, required this.booking}) : super(key: key);

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  String _stage = 'in_transit_to_renter';

  // Rider info will be loaded from the order / vendor data.
  String? _riderName;
  String? _riderPhone;
  String? _riderAvatar;
  String? _productImage;

  @override
  void initState() {
    super.initState();
    _stage = _stageFromBooking();
    _loadRider();
  }

  String _stageFromBooking() {
    switch (widget.booking.status.name) {
      case 'pickup_scheduled':
        return 'pickup_scheduled';
      case 'in_transit_to_renter':
        return 'in_transit_to_renter';
      case 'delivered_to_renter':
        return 'delivered_to_renter';
      case 'in_transit_to_lender':
        return 'in_transit_to_lender';
      case 'returned':
        return 'returned';
      default:
        return 'in_transit_to_renter';
    }
  }

  Future<void> _loadRider() async {
    // Live mode: try to fetch rider assignment from the order row.
    // Fallback to a sensible default in mock mode.
    final db = DatabaseService();
    try {
      final order = await db.getOrderDetails(widget.booking.id);
      final rider = (order['rider'] as Map?) ?? {};
      if (!mounted) return;
      setState(() {
        _riderName = (rider['name'] as String?) ?? 'Your rider';
        _riderPhone = (rider['phone'] as String?) ?? '+91 98765 43210';
        _riderAvatar = (rider['avatar'] as String?) ??
            'https://i.pravatar.cc/150?img=12';
        _productImage = widget.booking.listingImage;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _riderName = 'Your rider';
        _riderPhone = '+91 98765 43210';
        _riderAvatar = 'https://i.pravatar.cc/150?img=12';
        _productImage = widget.booking.listingImage ??
            (MockDataService.mockProducts.isNotEmpty
                ? MockDataService.mockProducts.first.images.first
                : null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReturn = widget.booking.status == BookingStatus.inTransitToLender;
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isReturn ? 'RETURN TRACKING' : 'DELIVERY TRACKING',
            style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Map placeholder
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: _GridPainter())),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryLime,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(FluentIcons.vehicle_truck_24_regular, size: 24, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isReturn ? 'Returning to lender' : 'Out for delivery',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        Text(
                          'ETA 25 mins',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Rider card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: _riderAvatar != null
                        ? NetworkImage(_riderAvatar!)
                        : null,
                    child: _riderAvatar == null
                        ? Text(
                            _riderName?.isNotEmpty == true
                                ? _riderName![0].toUpperCase()
                                : 'R',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w800, color: AppTheme.textDark),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_riderName ?? 'Your rider',
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                        Text('Rider • ⭐ 4.9 (1,240 deliveries)',
                            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _dialRider(context, phone: _riderPhone),
                    child: Tooltip(
                      message: 'Call rider',
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: AppTheme.primaryLime, shape: BoxShape.circle),
                        child: const Icon(FluentIcons.call_24_regular, size: 16, color: AppTheme.textDark),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _chatRider(context),
                    child: Tooltip(
                      message: 'Chat with rider',
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                        child: const Icon(FluentIcons.chat_24_regular, size: 16, color: AppTheme.textDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Status timeline
            Text('Status', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 10),
            _buildTimeline(),
            const SizedBox(height: 20),

            // Actions
            if (widget.booking.status == BookingStatus.inTransitToRenter && !isReturn) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RejectAtDeliveryScreen(booking: widget.booking)),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                  ),
                  child: Text('Reject at delivery',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _dialRider(context, phone: _riderPhone),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  elevation: 0,
                ),
                child: Text('CALL RIDER',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final stages = [
      {'key': 'pickup_scheduled', 'label': 'Pickup scheduled', 'time': 'Yesterday 6:00 PM'},
      {'key': 'picked_up', 'label': 'Picked up from lender', 'time': 'Today 9:15 AM'},
      {'key': 'qc', 'label': 'QC completed', 'time': 'Today 9:45 AM'},
      {'key': 'in_transit', 'label': 'Out for delivery', 'time': 'Today 10:30 AM'},
      {'key': 'delivered', 'label': 'Delivered to you', 'time': '~ 11:00 AM'},
    ];
    final currentIndex = stages.indexWhere((s) => s['key'] == _stage.replaceAll('_to_renter', '').replaceAll('_to_lender', ''));
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: List.generate(stages.length, (i) {
          final stage = stages[i];
          final isCompleted = i < (currentIndex == -1 ? 4 : currentIndex + 1);
          final isActive = i == (currentIndex == -1 ? 4 : currentIndex);
          return TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.15,
            isFirst: i == 0,
            isLast: i == stages.length - 1,
            indicatorStyle: IndicatorStyle(
              width: 24,
              color: isCompleted || isActive ? AppTheme.textDark : Colors.grey.shade200,
              padding: const EdgeInsets.all(4),
              iconStyle: IconStyle(
                color: isCompleted || isActive ? Colors.white : Colors.grey.shade400,
                iconData: isCompleted
                    ? FluentIcons.checkmark_24_regular
                    : (isActive ? FluentIcons.circle_24_filled : FluentIcons.circle_24_regular),
                fontSize: 12,
              ),
            ),
            beforeLineStyle: LineStyle(
              color: i <= (currentIndex == -1 ? 3 : currentIndex) ? AppTheme.textDark : Colors.grey.shade200,
              thickness: 2,
            ),
            endChild: Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 14, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stage['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                        color: AppTheme.textDark,
                      )),
                  const SizedBox(height: 2),
                  Text(stage['time'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

Future<void> _dialRider(BuildContext context, {String? phone}) async {
  final dial = phone ?? '+919876543210';
  final uri = Uri(scheme: 'tel', path: dial);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open dialer. Rider: $dial')),
    );
  }
}

void _chatRider(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Rider chat is coming soon — call them for now.')),
  );
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    const cellSize = 30.0;
    for (double x = 0; x < size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
