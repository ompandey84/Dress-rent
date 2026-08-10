import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:intl/intl.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/screens/lender_bookings_screen.dart';

/// Schedule how the item gets to the renter — self-drop or request a rider.
class SchedulePickupScreen extends StatefulWidget {
  const SchedulePickupScreen({Key? key}) : super(key: key);

  @override
  State<SchedulePickupScreen> createState() => _SchedulePickupScreenState();
}

class _SchedulePickupScreenState extends State<SchedulePickupScreen> {
  String _method = 'rider';
  DateTime? _selectedDate;
  String? _selectedSlot;
  String? _address;
  bool _submitting = false;

  final _timeSlots = [
    '09:00 - 11:00',
    '11:00 - 13:00',
    '13:00 - 15:00',
    '15:00 - 17:00',
    '17:00 - 19:00',
    '19:00 - 21:00',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
  }

  Future<void> _schedule() async {
    if (_selectedDate == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a date and time slot')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      if (SupabaseService.isConfigured) {
        // Create delivery record
        final supabase = Supabase.instance.client;
        await supabase.from('deliveries').insert({
          'booking_id': 'pending-booking-id',
          'type': 'outbound',
          'status': 'scheduled',
          'scheduled_at': _selectedDate!.toIso8601String(),
          'rider_phone': '+919999999999',
        });
        await supabase.from('orders').update({
          'status': 'pickup_scheduled',
        }).eq('id', 'pending-booking-id');
      }

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: AppTheme.primaryLime, shape: BoxShape.circle),
                  child: const Icon(FluentIcons.checkmark_24_regular, size: 32, color: AppTheme.textDark),
                ),
                const SizedBox(height: 16),
                Text('Pickup scheduled!',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                const SizedBox(height: 8),
                Text(
                  _method == 'rider'
                      ? 'A rider will arrive on ${DateFormat('EEE, d MMM').format(_selectedDate!)} between $_selectedSlot to collect the item.'
                      : 'Please drop off the item at the collection point on ${DateFormat('EEE, d MMM').format(_selectedDate!)} between $_selectedSlot.',
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
                    MaterialPageRoute(builder: (_) => const LenderBookingsScreen()),
                    (route) => false,
                  );
                },
                child: Text('View my rentals', style: GoogleFonts.inter(color: AppTheme.textDark, fontWeight: FontWeight.w800)),
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
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('SCHEDULE PICKUP',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Method selection
            Text('How will the item reach the renter?',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark, height: 1.3)),
            const SizedBox(height: 12),
            _buildMethodCard(
              id: 'rider',
              icon: FluentIcons.vehicle_truck_24_regular,
              title: 'Request a rider',
              subtitle: 'Our delivery partner picks up from your address. Free for 3+ day rentals.',
              badge: 'FREE',
            ),
            const SizedBox(height: 8),
            _buildMethodCard(
              id: 'self',
              icon: FluentIcons.building_24_regular,
              title: 'Self drop-off',
              subtitle: 'Drop off at our nearest collection point. Get ₹50 credit.',
              badge: 'EARN ₹50',
            ),
            const SizedBox(height: 24),

            // Date picker
            Text('Pick a date', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final date = DateTime.now().add(Duration(days: i + 1));
                  final isSelected = _selectedDate != null && _isSameDay(date, _selectedDate!);
                  final isToday = _isSameDay(date, DateTime.now());
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    child: Container(
                      width: 64,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.textDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? AppTheme.textDark : Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('E').format(date).toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? AppTheme.primaryLime : AppTheme.textLight,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.day.toString(),
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: isSelected ? Colors.white : AppTheme.textDark,
                            ),
                          ),
                          Text(
                            DateFormat('MMM').format(date),
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white70 : AppTheme.textLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (isToday) ...[
                            const SizedBox(height: 2),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primaryLime : AppTheme.textDark,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Time slot
            Text('Pick a time slot', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots.map((s) {
                final isSelected = _selectedSlot == s;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSlot = s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.textDark : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppTheme.textDark : Colors.grey.shade200),
                    ),
                    child: Text(
                      s,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Address
            if (_method == 'rider') ...[
              Text('Pickup address', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  setState(() => _address = '123 Marina Blvd, Dubai Marina, UAE');
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(FluentIcons.location_24_regular, color: AppTheme.textDark, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _address ?? 'Choose pickup address',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: _address != null ? AppTheme.textDark : AppTheme.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(FluentIcons.chevron_right_24_regular, color: AppTheme.textLight, size: 16),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submitting ? null : _schedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.textDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('CONFIRM SCHEDULE',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard({
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
  }) {
    final isSelected = _method == id;
    return GestureDetector(
      onTap: () => setState(() => _method = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLime.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.textDark : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryLime.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
