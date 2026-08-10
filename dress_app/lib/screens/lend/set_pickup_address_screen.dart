import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/listing_draft.dart';

/// Step 4: Pickup address + delivery preference.
class SetPickupAddressScreen extends StatefulWidget {
  final ListingDraft draft;
  const SetPickupAddressScreen({Key? key, required this.draft}) : super(key: key);

  @override
  State<SetPickupAddressScreen> createState() => _SetPickupAddressScreenState();
}

class _SetPickupAddressScreenState extends State<SetPickupAddressScreen> {
  late final TextEditingController _line1;
  late final TextEditingController _line2;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _pincode;
  late final TextEditingController _landmark;

  @override
  void initState() {
    super.initState();
    _line1 = TextEditingController(text: widget.draft.pickupAddressLine1);
    _line2 = TextEditingController(text: widget.draft.pickupAddressLine2 ?? '');
    _city = TextEditingController(text: widget.draft.pickupCity);
    _state = TextEditingController(text: widget.draft.pickupState);
    _pincode = TextEditingController(text: widget.draft.pickupPincode);
    _landmark = TextEditingController(text: widget.draft.landmark ?? '');
  }

  @override
  void dispose() {
    _line1.dispose();
    _line2.dispose();
    _city.dispose();
    _state.dispose();
    _pincode.dispose();
    _landmark.dispose();
    super.dispose();
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (v) {
            if (onChanged != null) onChanged(v);
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.textDark, width: 1.5)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pickup address', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
        const SizedBox(height: 4),
        Text('Only shown to confirmed renters. Riders will use this for delivery.',
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w500)),
        const SizedBox(height: 20),
        _field(
          label: 'ADDRESS LINE 1 *',
          controller: _line1,
          hint: 'Flat 302, Sunshine Apartments',
          onChanged: (v) => widget.draft.pickupAddressLine1 = v,
        ),
        _field(
          label: 'ADDRESS LINE 2 (OPTIONAL)',
          controller: _line2,
          hint: 'Near City Mall',
          onChanged: (v) => widget.draft.pickupAddressLine2 = v.isEmpty ? null : v,
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _field(
                label: 'CITY *',
                controller: _city,
                hint: 'Mumbai',
                onChanged: (v) => widget.draft.pickupCity = v,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field(
                label: 'PINCODE *',
                controller: _pincode,
                hint: '400001',
                keyboardType: TextInputType.number,
                onChanged: (v) => widget.draft.pickupPincode = v,
              ),
            ),
          ],
        ),
        _field(
          label: 'STATE *',
          controller: _state,
          hint: 'Maharashtra',
          onChanged: (v) => widget.draft.pickupState = v,
        ),
        _field(
          label: 'LANDMARK (OPTIONAL)',
          controller: _landmark,
          hint: 'Opposite Starbucks',
          onChanged: (v) => widget.draft.landmark = v.isEmpty ? null : v,
        ),
        const SizedBox(height: 12),
        // Delivery method
        Text('DELIVERY METHOD', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Column(
          children: [
            _deliveryOption(
              id: 'both',
              icon: FluentIcons.vehicle_car_24_regular,
              title: 'Both rider & self-drop',
              subtitle: 'Most flexible — boost bookings by ~30%',
            ),
            _deliveryOption(
              id: 'rider',
              icon: FluentIcons.vehicle_car_24_regular,
              title: 'Rider pickup only',
              subtitle: 'No meetups. ₹50-80 delivery fee to renter.',
            ),
            _deliveryOption(
              id: 'self',
              icon: FluentIcons.person_24_regular,
              title: 'Self drop-off only',
              subtitle: 'Renter picks up at your address.',
            ),
          ],
        ),
        const SizedBox(height: 100),
      ],
      ),
    );
  }

  Widget _deliveryOption({
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = widget.draft.pickupMethod == id;
    return GestureDetector(
      onTap: () => setState(() => widget.draft.pickupMethod = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLime.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.textDark : AppTheme.textLight.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.textDark : AppTheme.primaryLime,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: isSelected ? Colors.white : AppTheme.textDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.textDark, size: 20),
          ],
        ),
      ),
    );
  }
}
