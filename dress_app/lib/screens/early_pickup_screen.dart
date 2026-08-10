import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/services/database_service.dart';

class EarlyPickupScreen extends StatefulWidget {
  /// Required: the booking this request is about. Replaces the old
  /// hardcoded `'unspecified'` orderId.
  final String bookingId;
  const EarlyPickupScreen({super.key, required this.bookingId});

  @override
  State<EarlyPickupScreen> createState() => _EarlyPickupScreenState();
}

class _EarlyPickupScreenState extends State<EarlyPickupScreen> {
  String? selectedReason;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  final List<String> reasons = [
    'I am done using the item early',
    'The item does not fit well',
    'Item is defective or damaged',
    'I ordered the wrong item by mistake',
    'Other reason',
  ];

  bool _submitting = false;

  Future<void> _submitRequest() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await DatabaseService().requestEarlyPickup(
        widget.bookingId,
        selectedReason ?? '',
        '',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Early pickup requested — we\'ll be in touch shortly.',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not submit: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'EARLY PICKUP',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request early pickup',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Need to return earlier? Tell us why so we can arrange a rider.',
                  style: GoogleFonts.inter(
                    fontSize: 13, color: AppTheme.textLight, height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Reason',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                ...reasons.map((reason) => _buildReasonOption(reason)).toList(),
                const SizedBox(height: 24),
                Text(
                  'Add photos (optional)',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'If the item is damaged, attach a photo so we can act fast.',
                  style: GoogleFonts.inter(
                    fontSize: 12, color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: _buildAddPhotoButton(),
                      ),
                      const SizedBox(width: 10),
                      ..._images.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _buildImageTile(entry.value, entry.key),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Bottom Button
          Positioned(
            bottom: 12,
            left: 20,
            right: 20,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: selectedReason != null
                    ? AppTheme.primaryLime
                    : const Color(0xFFF1F4F5),
                borderRadius: BorderRadius.circular(100),
                boxShadow: selectedReason != null
                    ? [
                        BoxShadow(
                            color: AppTheme.primaryLime.withOpacity(0.4),
                            offset: const Offset(0, 8),
                            blurRadius: 15),
                      ]
                    : [],
              ),
              child: ElevatedButton(
                onPressed: selectedReason != null && !_submitting
                    ? _submitRequest
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledForegroundColor: AppTheme.textLight,
                  disabledBackgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
                child: Center(
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.textDark),
                        )
                      : Text(
                          'SUBMIT REQUEST',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: selectedReason != null
                                  ? AppTheme.textDark
                                  : AppTheme.textLight.withOpacity(0.5),
                              letterSpacing: 0.5),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonOption(String reason) {
    bool isSelected = selectedReason == reason;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedReason = reason;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryLime.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryLime : AppTheme.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryLime : AppTheme.textLight,
                  width: isSelected ? 5 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                reason,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: AppTheme.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FluentIcons.camera_add_24_regular, color: AppTheme.textDark, size: 20),
          const SizedBox(height: 2),
          Text(
            'Add',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageTile(XFile file, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(file.path),
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _images.removeAt(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Color(0xCC000000),
                shape: BoxShape.circle,
              ),
              child: const Icon(FluentIcons.dismiss_12_regular, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }
}
