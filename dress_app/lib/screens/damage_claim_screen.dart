import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/booking.dart';
import 'package:dress_app/services/return_service.dart';
import 'package:dress_app/services/storage_service.dart';
import 'package:dress_app/screens/main_navigation.dart';

/// Damage Claim form — raised by lender on item return.
class DamageClaimScreen extends StatefulWidget {
  final Booking booking;
  const DamageClaimScreen({Key? key, required this.booking}) : super(key: key);

  @override
  State<DamageClaimScreen> createState() => _DamageClaimScreenState();
}

class _DamageClaimScreenState extends State<DamageClaimScreen> {
  String _type = 'damage';
  String? _subtype;
  double _amount = 0;
  final _description = TextEditingController();
  final List<File> _photos = [];
  bool _submitting = false;
  static const _currency = '₹';

  final _damageTypes = [
    {'id': 'stain', 'label': 'Stain', 'icon': FluentIcons.drop_24_regular, 'avg': 500},
    {'id': 'tear', 'label': 'Tear / Rip', 'icon': FluentIcons.cut_24_regular, 'avg': 1200},
    {'id': 'color', 'label': 'Color transfer', 'icon': FluentIcons.color_24_regular, 'avg': 800},
    {'id': 'burn', 'label': 'Burn mark', 'icon': FluentIcons.fire_24_regular, 'avg': 2000},
    {'id': 'missing', 'label': 'Missing accessory', 'icon': FluentIcons.box_24_regular, 'avg': 600},
    {'id': 'lost', 'label': 'Lost item', 'icon': FluentIcons.search_24_regular, 'avg': 5000},
  ];

  Future<void> _addPhoto() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(FluentIcons.camera_24_regular),
              title: Text('Take Photo', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              onTap: () async {
                Navigator.pop(context);
                final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
                if (file != null) setState(() => _photos.add(File(file.path)));
              },
            ),
            ListTile(
              leading: const Icon(FluentIcons.image_24_regular),
              title: Text('Choose from Gallery', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              onTap: () async {
                Navigator.pop(context);
                final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
                if (file != null) setState(() => _photos.add(File(file.path)));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_subtype == null || _photos.isEmpty || _amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a damage type, add photos, and set amount')),
      );
      return;
    }
    if (_amount > widget.booking.securityDeposit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Amount cannot exceed security deposit (₹${widget.booking.securityDeposit.toStringAsFixed(0)})'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      // Upload photos
      final urls = <String>[];
      for (var i = 0; i < _photos.length; i++) {
        final url = await StorageService().uploadAvatar(_photos[i], 'claim-${widget.booking.id}-$i');
        urls.add(url);
      }

      // Submit claim
      await ReturnService().submitDamageClaim(
        booking: widget.booking,
        type: _type,
        description: _description.text,
        amountClaimed: _amount,
        photoUrls: urls,
      );

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
                Text('Claim submitted',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                const SizedBox(height: 8),
                Text(
                  'The renter will be notified. They can accept the deduction or dispute it. Our team reviews all disputes within 24h.',
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
          icon: const Icon(FluentIcons.dismiss_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('DAMAGE CLAIM',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Row(
                children: [
                  const Icon(FluentIcons.alert_24_regular, color: Color(0xFFE65100), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Claims are deducted from the renter's security deposit. We only approve claims with photo evidence.",
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Damage type
            Text('What happened?', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _damageTypes.map((t) => _buildTypeChip(t)).toList(),
            ),
            const SizedBox(height: 24),

            // Description
            Text('Description', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe what happened...',
                hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.textDark, width: 2)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 24),

            // Amount
            Text('Claim amount', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 4),
            Text(
              'Maximum: $_currency${widget.booking.securityDeposit.toStringAsFixed(0)} (security deposit)',
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text('$_currency', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.textDark, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (v) => _amount = double.tryParse(v) ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Photos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Photo evidence',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                Text('${_photos.length} photo${_photos.length == 1 ? '' : 's'}',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 4),
            Text('Timestamped automatically. Compare to pickup photos.',
                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, height: 1.4)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                ..._photos.map((p) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(p, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _photos.remove(p)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                              child: const Icon(FluentIcons.dismiss_24_regular, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    )),
                if (_photos.length < 6)
                  GestureDetector(
                    onTap: _addPhoto,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid, width: 1.5),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FluentIcons.camera_add_24_regular, color: AppTheme.textLight, size: 24),
                          SizedBox(height: 4),
                          Text('Add', style: TextStyle(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('SUBMIT CLAIM',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(Map<String, dynamic> t) {
    final isSelected = _subtype == t['id'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _subtype = t['id'] as String;
          _type = (t['id'] == 'lost') ? 'lost' : 'damage';
          if (_amount == 0) _amount = (t['avg'] as int).toDouble();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textDark : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: isSelected ? AppTheme.textDark : Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(t['icon'] as IconData, size: 14, color: isSelected ? Colors.white : AppTheme.textDark),
            const SizedBox(width: 6),
            Text(
              '${t['label']} • ₹${t['avg']}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }
}
