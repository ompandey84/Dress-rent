import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/services/storage_service.dart';
import 'package:dress_app/services/booking_service.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/screens/schedule_pickup_screen.dart';

/// Pack & ship item screen with checklist + photo upload.
class PackItemScreen extends StatefulWidget {
  const PackItemScreen({Key? key}) : super(key: key);

  @override
  State<PackItemScreen> createState() => _PackItemScreenState();
}

class _PackItemScreenState extends State<PackItemScreen> {
  final Set<String> _checked = {};
  final List<File> _photos = [];
  bool _uploading = false;

  final _checklist = [
    {'key': 'cleaned', 'label': 'Item is freshly cleaned/steamed', 'icon': FluentIcons.sparkle_24_regular},
    {'key': 'inspected', 'label': 'No new damage since last rental', 'icon': FluentIcons.shield_checkmark_24_regular},
    {'key': 'tags', 'label': 'Designer tags still attached (if any)', 'icon': FluentIcons.tag_24_regular},
    {'key': 'accessories', 'label': 'All accessories included (belt, scarf, etc.)', 'icon': FluentIcons.box_24_regular},
    {'key': 'packed', 'label': 'Folded neatly in dust bag / cover', 'icon': FluentIcons.box_24_regular},
  ];

  bool get _allChecked => _checked.length == _checklist.length;
  bool get _hasPhotos => _photos.isNotEmpty;

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
                final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                if (file != null) setState(() => _photos.add(File(file.path)));
              },
            ),
            ListTile(
              leading: const Icon(FluentIcons.image_24_regular),
              title: Text('Choose from Gallery', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              onTap: () async {
                Navigator.pop(context);
                final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                if (file != null) setState(() => _photos.add(File(file.path)));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_allChecked || !_hasPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete checklist and add at least 1 photo')),
      );
      return;
    }
    setState(() => _uploading = true);
    try {
      // Upload photos
      final urls = <String>[];
      for (var i = 0; i < _photos.length; i++) {
        final url = await StorageService().uploadAvatar(_photos[i], 'pickup-${DateTime.now().millisecondsSinceEpoch}-$i');
        urls.add(url);
      }
      // Update booking status
      if (SupabaseService.isConfigured) {
        final supabase = Supabase.instance.client;
        await supabase.from('orders').update({
          'status': 'lender_preparing',
        }).eq('id', 'pending-booking-id'); // mock
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Item packed! Schedule pickup next.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SchedulePickupScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
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
        title: Text('PACK ITEM',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${_checked.length}/${_checklist.length}',
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(FluentIcons.box_24_regular, size: 32, color: AppTheme.primaryLime),
                  const SizedBox(height: 12),
                  Text('Pack this item for shipping',
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
                  const SizedBox(height: 4),
                  Text('Complete the checklist, take photos, and schedule pickup. Renter will see condition photos.',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Checklist
            Text('Pre-shipment checklist', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            ..._checklist.map((c) => _buildChecklistItem(c)),
            const SizedBox(height: 24),

            // Photo upload
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Condition photos',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                Text('${_photos.length}/4',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 4),
            Text('Take at least 1 photo. These protect both of you in case of damage disputes.',
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
                if (_photos.length < 4)
                  GestureDetector(
                    onTap: _addPhoto,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid, width: 1.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(FluentIcons.camera_add_24_regular, color: AppTheme.textLight, size: 24),
                          const SizedBox(height: 4),
                          Text('Add', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // QC reminder
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(FluentIcons.info_24_regular, color: Color(0xFFE65100), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'QC photos are timestamped automatically. They are used as evidence in damage claims.',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Submit
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _uploading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _allChecked && _hasPhotos ? AppTheme.textDark : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  elevation: 0,
                ),
                child: _uploading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('PACKED & READY',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(Map<String, dynamic> item) {
    final isChecked = _checked.contains(item['key']);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isChecked) {
              _checked.remove(item['key']);
            } else {
              _checked.add(item['key']);
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isChecked ? AppTheme.textDark : Colors.grey.shade200,
              width: isChecked ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isChecked ? AppTheme.textDark : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: isChecked ? Colors.white : AppTheme.textLight,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['label'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                    decorationColor: AppTheme.textLight,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isChecked ? FluentIcons.checkmark_circle_24_filled : FluentIcons.circle_24_regular,
                color: isChecked ? AppTheme.textDark : AppTheme.textLight,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
