import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:intl/intl.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/booking.dart';
import 'package:dress_app/services/return_service.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/screens/main_navigation.dart';

/// Return Pickup — renter schedules return, tracks late fees.
class ReturnPickupScreen extends StatefulWidget {
  final Booking booking;
  const ReturnPickupScreen({Key? key, required this.booking}) : super(key: key);

  @override
  State<ReturnPickupScreen> createState() => _ReturnPickupScreenState();
}

class _ReturnPickupScreenState extends State<ReturnPickupScreen> {
  String _method = 'rider';
  bool _scheduling = false;

  int get _daysLate {
    final now = DateTime.now();
    if (now.isAfter(widget.booking.endDate)) {
      return now.difference(widget.booking.endDate).inDays;
    }
    return 0;
  }

  double get _lateFee {
    return ReturnService().calculateLateFee(
      booking: widget.booking,
      daysLate: _daysLate,
    );
  }

  Future<void> _scheduleReturn() async {
    setState(() => _scheduling = true);
    try {
      if (SupabaseService.isConfigured) {
        final supabase = Supabase.instance.client;
        await supabase.from('orders').update({
          'status': 'return_scheduled',
        }).eq('id', widget.booking.id);
      }
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FluentIcons.checkmark_circle_24_filled, color: AppTheme.textDark, size: 48),
                const SizedBox(height: 12),
                Text('Return scheduled!',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                const SizedBox(height: 8),
                Text(
                  'A rider will collect the item today. Make sure it\'s packed and ready.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight, height: 1.4),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainNavigation()),
                    (route) => false,
                  );
                },
                child: Text('Done', style: GoogleFonts.inter(color: AppTheme.textDark, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _scheduling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = widget.booking.endDate.difference(DateTime.now()).inDays;
    final isLate = _daysLate > 0;
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('RETURN ITEM',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isLate
                      ? [const Color(0xFFB71C1C), const Color(0xFFD32F2F)]
                      : [const Color(0xFF1A1A1A), const Color(0xFF2D2D2D)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isLate ? FluentIcons.alert_24_filled : FluentIcons.calendar_24_regular,
                        color: isLate ? Colors.amber.shade300 : AppTheme.primaryLime,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isLate
                              ? '${_daysLate} day${_daysLate > 1 ? 's' : ''} overdue'
                              : (daysLeft == 0
                                  ? 'Return today'
                                  : daysLeft == 1
                                      ? 'Return tomorrow'
                                      : '${daysLeft} days left'),
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLate
                        ? 'A late fee of ₹${_lateFee.toStringAsFixed(0)} has been added to your refund.'
                        : 'Schedule return pickup. Your deposit will be refunded after QC.',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.4),
                  ),
                  if (isLate) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(FluentIcons.clock_24_regular, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Late fee accrues daily until returned',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Return method
            Text('How will you return?',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            _buildMethodCard(
              id: 'rider',
              icon: FluentIcons.vehicle_truck_24_regular,
              title: 'Request a rider',
              subtitle: 'Rider picks up from your address. Free for all returns.',
              badge: 'FREE',
            ),
            const SizedBox(height: 8),
            _buildMethodCard(
              id: 'drop',
              icon: FluentIcons.building_24_regular,
              title: 'Drop off',
              subtitle: 'Drop at our nearest collection point. Get ₹50 credit.',
              badge: 'EARN ₹50',
            ),
            const SizedBox(height: 24),

            // Deposit info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _Row('Rental fee', '₹${widget.booking.rentalFee.toStringAsFixed(0)}'),
                  if (_lateFee > 0)
                    _Row('Late fee (${_daysLate}d)', '₹${_lateFee.toStringAsFixed(0)}',
                        valueColor: Colors.red.shade700),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
                  _Row('Security deposit (refundable)', '₹${widget.booking.securityDeposit.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(FluentIcons.shield_checkmark_24_regular, color: AppTheme.textDark, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Deposit refunded within 24h after lender approves condition',
                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Reminders
            Text('Before you return', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            _Reminder(icon: FluentIcons.sparkle_24_regular, label: 'Item is cleaned/steamed'),
            _Reminder(icon: FluentIcons.box_24_regular, label: 'All accessories included'),
            _Reminder(icon: FluentIcons.camera_24_regular, label: 'Take pre-return photos (just in case)'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _scheduling ? null : _scheduleReturn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  elevation: 0,
                ),
                child: _scheduling
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('SCHEDULE RETURN PICKUP',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard({required String id, required IconData icon, required String title, required String subtitle, required String badge}) {
    final isSelected = _method == id;
    return GestureDetector(
      onTap: () => setState(() => _method = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLime.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppTheme.textDark : Colors.grey.shade200, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppTheme.primaryLime.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppTheme.textDark, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, height: 1.3)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.textDark, borderRadius: BorderRadius.circular(100)),
              child: Text(badge, style: GoogleFonts.inter(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _Row(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w600)),
          Text(value, style: GoogleFonts.inter(fontSize: 13, color: valueColor ?? AppTheme.textDark, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _Reminder extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Reminder({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppTheme.textDark, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
