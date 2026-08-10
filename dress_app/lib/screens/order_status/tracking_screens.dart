import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/rating_screen.dart';
import 'package:dress_app/screens/early_pickup_screen.dart';
import 'package:dress_app/services/booking_service.dart';

import 'package:dress_app/models/order.dart';

class RequestedOrderScreen extends StatelessWidget {
  final Order order;
  const RequestedOrderScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _BaseTrackingScreen(
      title: 'REQUESTED ORDER',
      currentStep: 0,
      orderCost: '₹ ${order.totalPrice.toStringAsFixed(0)}',
      canCancel: true,
      order: order,
    );
  }
}

class PreparingOrderScreen extends StatelessWidget {
  final Order order;
  const PreparingOrderScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _BaseTrackingScreen(
      title: 'PREPARING ORDER',
      currentStep: 1,
      orderCost: '₹ ${order.totalPrice.toStringAsFixed(0)}',
      canCancel: true,
      order: order,
    );
  }
}

class OutForDeliveryScreen extends StatelessWidget {
  final Order order;
  const OutForDeliveryScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _BaseTrackingScreen(
      title: 'OUT FOR DELIVERY',
      currentStep: 2,
      orderCost: '₹ ${order.totalPrice.toStringAsFixed(0)}',
      order: order,
    );
  }
}

class DeliveredOrderScreen extends StatelessWidget {
  final Order order;
  const DeliveredOrderScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _BaseTrackingScreen(
      title: 'DELIVERED ORDER',
      currentStep: 3,
      orderCost: '₹ ${order.totalPrice.toStringAsFixed(0)}',
      showActionButtons: true,
      canExtend: true,
      canReturn: true,
      order: order,
    );
  }
}

class _BaseTrackingScreen extends StatelessWidget {
  final int currentStep;
  final String title;
  final String orderCost;
  final bool showActionButtons;
  final bool canCancel;
  final bool canExtend;
  final bool canReturn;
  final Order? order;

  const _BaseTrackingScreen({
    required this.currentStep,
    required this.title,
    required this.orderCost,
    this.showActionButtons = false,
    this.canCancel = false,
    this.canExtend = false,
    this.canReturn = false,
    this.order,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mapHeight = size.height * 0.55;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // MAP BACKGROUND
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: mapHeight,
            child: Container(
              color: const Color(0xFFF1F4F5), // Light map background color
              child: Stack(
                children: [
                  // Placeholder "city" roads pattern
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.15,
                      child: Image.network(
                        'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=800&auto=format&fit=crop',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // The blue path
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MapPathPainter(),
                    ),
                  ),

                  // Start Marker (Bottom Left)
                  Positioned(
                    left: size.width * 0.18 - 18,
                    top: mapHeight * 0.48 - 18,
                    child: _buildMapMarker(
                      color: AppTheme.primaryLime,
                      borderColor: Colors.lightBlueAccent.withOpacity(0.5),
                      icon: Icons.navigation_rounded,
                      iconColor: AppTheme.textDark,
                      angle: 0.8, // Slightly rotate origin pointer
                    ),
                  ),

                  // End Marker (Top Right)
                  Positioned(
                    left: size.width * 0.8 - 18,
                    top: mapHeight * 0.28 - 18,
                    child: _buildMapMarker(
                      color: Colors.white,
                      borderColor: const Color(0xFF0C6B86),
                      icon: FluentIcons.location_24_regular,
                      iconColor: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BOTTOM SHEET CONTENT
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                      height: mapHeight *
                          0.8), // Start overlapping the map slightly
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    padding: const EdgeInsets.only(
                        top: 32, left: 24, right: 24, bottom: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTimeline(),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoCol(
                                'Created', _formatDate(order?.createdAt),
                                crossAlignment: CrossAxisAlignment.start),
                            _buildInfoCol(
                                'Order ID',
                                (order?.displayId.isNotEmpty ?? false)
                                    ? order!.displayId
                                    : (order?.id ?? '—'),
                                crossAlignment: CrossAxisAlignment.end),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFE5E5E5), thickness: 1.5),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoCol('Pickup', _formatDate(order?.createdAt),
                                crossAlignment: CrossAxisAlignment.start),
                            _buildInfoCol('Return', _formatDate(_returnDate(order?.createdAt)),
                                crossAlignment: CrossAxisAlignment.end),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoCol('Items', '${order?.itemsCount ?? 1}',
                                crossAlignment: CrossAxisAlignment.start),
                            _buildInfoCol('Order Total', orderCost,
                                crossAlignment: CrossAxisAlignment.end),
                          ],
                        ),
                        if (canCancel || canExtend || canReturn || showActionButtons) _buildManagementButtons(context),
                        if (showActionButtons) _buildActionButtons(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CUSTOM APP BAR Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAppBarButton(
                      icon: FluentIcons.chevron_left_24_regular,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                    _buildAppBarButton(
                      icon: Icons.shopping_basket_outlined,
                      onTap: () {
                        // Pop back to the main tab bar and switch to Bag tab.
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: AppTheme.textDark, size: 22),
      ),
    );
  }

  Widget _buildMapMarker({
    required Color color,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    double angle = 0,
  }) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: iconColor, size: 18),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 3,
                    color: currentStep >= 1
                        ? AppTheme.primaryLime
                        : const Color(0xFFEAEAEA),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 3,
                    color: currentStep >= 2
                        ? AppTheme.primaryLime
                        : const Color(0xFFEAEAEA),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 3,
                    color: currentStep >= 3
                        ? AppTheme.primaryLime
                        : const Color(0xFFEAEAEA),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimelineDot(
                  icon: Icons.check_circle_outline,
                  isActive: currentStep >= 0,
                ),
                _buildTimelineDot(
                  icon: FluentIcons.spinner_ios_20_regular,
                  isActive: currentStep >= 1,
                ),
                _buildTimelineDot(
                  icon: FluentIcons.vehicle_truck_24_regular,
                  isActive: currentStep >= 2,
                ),
                _buildTimelineDot(
                  icon: FluentIcons.box_24_regular,
                  isActive: currentStep >= 3,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTimelineText('Confirmed', isActive: currentStep >= 0),
            _buildTimelineText('Processing', isActive: currentStep >= 1),
            _buildTimelineText('Pickup', isActive: currentStep >= 2),
            _buildTimelineText('Delivered', isActive: currentStep >= 3),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineDot({
    required IconData icon,
    required bool isActive,
  }) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryLime : Colors.white,
        shape: BoxShape.circle,
        border: isActive
            ? null
            : Border.all(color: const Color(0xFFEAEAEA), width: 1.5),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppTheme.primaryLime.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          icon,
          size: 24,
          color: isActive ? AppTheme.textDark : const Color(0xFF9E9E9E),
        ),
      ),
    );
  }

  Widget _buildTimelineText(String text, {required bool isActive}) {
    return SizedBox(
      width: 72,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
          color:
              isActive ? AppTheme.textDark : AppTheme.textDark.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildInfoCol(
    String label,
    String value, {
    required CrossAxisAlignment crossAlignment,
  }) {
    return Column(
      crossAxisAlignment: crossAlignment,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textLight,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildManagementButtons(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        if (canCancel)
          _buildLongButton(
            context,
            'CANCEL ORDER',
            Colors.red,
            () => _confirmCancel(context),
          ),
        if (canExtend)
          _buildLongButton(
            context,
            'EXTEND RENTAL',
            const Color(0xFF0C6B86),
            () => _showInfoDialog(
              context,
              'Extend rental',
              'To extend your rental, please message the lender directly. We\'ll add the extra days to your order once they confirm.',
            ),
          ),
        if (canReturn)
          _buildLongButton(
            context,
            'RETURN ORDER',
            AppTheme.primaryLime,
            () => _confirmReturn(context),
            isPrimary: true,
          ),
      ],
    );
  }

  Widget _buildLongButton(BuildContext context, String label, Color color, VoidCallback onTap, {bool isPrimary = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: isPrimary ? color : Colors.white,
            borderRadius: BorderRadius.circular(100),
            border: isPrimary ? null : Border.all(color: color.withOpacity(0.3)),
            boxShadow: isPrimary ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))] : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: isPrimary ? AppTheme.textDark : color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _ReasonDialog(
        title: 'Cancel order?',
        message: 'Are you sure? A 20% cancellation fee may apply per our policy.',
        reasons: const [
          'Changed my mind',
          'Found a better option',
          'Item not available',
          'Scheduling conflict',
          'Other',
        ],
      ),
    );
    if (reason == null || !context.mounted) return;
    final orderId = order?.id.replaceAll('#', '') ?? '';
    if (orderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order ID missing')),
      );
      return;
    }
    final ok = await BookingService().cancelBooking(orderId, reason);
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled. Refund will reflect in 3–5 business days.'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not cancel right now. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmReturn(BuildContext context) async {
    if (order == null) return;
    final orderId = order!.id.replaceAll('#', '');
    final ok = await BookingService().markReturnRequested(orderId);
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Return requested. Our rider will contact you shortly.'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not request return. Try again.')),
      );
    }
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Text(message, style: GoogleFonts.inter(height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    return DateFormat('d MMM, h:mm a').format(d);
  }

  DateTime? _returnDate(DateTime? pickup) {
    if (pickup == null) return null;
    return pickup.add(const Duration(days: 3));
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EarlyPickupScreen(
                        bookingId: order?.id ?? '',
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  side: BorderSide(color: AppTheme.textLight.withOpacity(0.2)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Request Early Pickup',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryLime,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryLime.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RatingScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    'Review Rating',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MapPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0C6B86) // Teal color from the image path
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // Replicating the squiggle shape from the mockup map
    path.moveTo(size.width * 0.18, size.height * 0.48);
    path.cubicTo(
      size.width * 0.3, size.height * 0.2, // ctrl1
      size.width * 0.4, size.height * 0.45, // ctrl2
      size.width * 0.55, size.height * 0.45, // point
    );
    path.cubicTo(
      size.width * 0.65,
      size.height * 0.45,
      size.width * 0.65,
      size.height * 0.25,
      size.width * 0.8,
      size.height * 0.28,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Reason picker dialog for cancellation/return flows.
class _ReasonDialog extends StatefulWidget {
  final String title;
  final String message;
  final List<String> reasons;
  const _ReasonDialog({
    required this.title,
    required this.message,
    required this.reasons,
  });

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.title, style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppTheme.textDark)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message, style: GoogleFonts.inter(color: AppTheme.textLight, height: 1.4)),
            const SizedBox(height: 16),
            ...widget.reasons.map((r) => RadioListTile<String>(
                  value: r,
                  groupValue: _selected,
                  onChanged: (v) => setState(() => _selected = v),
                  title: Text(r, style: GoogleFonts.inter(fontSize: 14)),
                  activeColor: AppTheme.textDark,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('CANCEL', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.textLight)),
        ),
        ElevatedButton(
          onPressed: _selected == null
              ? null
              : () => Navigator.pop(context, _selected),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.textDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            elevation: 0,
          ),
          child: Text('CONFIRM', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}
