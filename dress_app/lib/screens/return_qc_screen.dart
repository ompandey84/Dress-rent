import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/booking.dart';
import 'package:dress_app/models/product.dart';
import 'package:dress_app/services/return_service.dart';
import 'package:dress_app/services/storage_service.dart';
import 'package:dress_app/services/mock_data_service.dart';
import 'package:dress_app/services/auth_service.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:dress_app/services/cashfree_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/screens/damage_claim_screen.dart';
import 'package:dress_app/screens/main_navigation.dart';
import 'package:dress_app/screens/rating_screen.dart';

/// Return QC screen — lender inspects the returned item, takes photos,
/// optionally raises a damage claim, or accepts the return.
class ReturnQcScreen extends StatefulWidget {
  final Booking booking;
  const ReturnQcScreen({Key? key, required this.booking}) : super(key: key);

  @override
  State<ReturnQcScreen> createState() => _ReturnQcScreenState();
}

class _ReturnQcScreenState extends State<ReturnQcScreen> {
  final List<File> _returnPhotos = [];
  String _itemCondition = 'excellent';
  bool _submitting = false;

  // QC Checklist
  final Map<String, bool> _checklist = {
    'Item received in original packaging': false,
    'No visible stains or marks': false,
    'No rips, tears, or loose threads': false,
    'No new damage since pickup': false,
    'All accessories present': false,
  };

  bool get _allChecked => _checklist.values.every((v) => v);
  bool get _hasPhotos => _returnPhotos.isNotEmpty;

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
                if (file != null) setState(() => _returnPhotos.add(File(file.path)));
              },
            ),
            ListTile(
              leading: const Icon(FluentIcons.image_24_regular),
              title: Text('Choose from Gallery', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              onTap: () async {
                Navigator.pop(context);
                final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                if (file != null) setState(() => _returnPhotos.add(File(file.path)));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptReturn() async {
    if (!_allChecked || !_hasPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete the checklist and add at least 1 photo')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      // Upload photos
      final urls = <String>[];
      for (var i = 0; i < _returnPhotos.length; i++) {
        final url = await StorageService().uploadAvatar(_returnPhotos[i], 'return-${widget.booking.id}-$i');
        urls.add(url);
      }
      await ReturnService().completeReturn(bookingId: widget.booking.id, hasDamage: false);

      if (SupabaseService.isConfigured) {
        // Release escrow: full rental fee to lender, full deposit back to renter
        final supabase = Supabase.instance.client;
        await supabase.from('orders').update({
          'payment_status': 'paid',
          'escrow_status': 'released',
          'status': 'completed',
          'completed_at': DateTime.now().toIso8601String(),
        }).eq('id', widget.booking.id);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => _ReturnReleasedScreen(booking: widget.booking)),
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
    final product = MockDataService.mockProducts.firstWhere(
      (p) => p.id == widget.booking.listingId,
      orElse: () => MockDataService.mockProducts.first,
    );
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('RETURN QC',
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
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(FluentIcons.box_24_regular, size: 28, color: AppTheme.primaryLime),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Inspect returned item',
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
                        const SizedBox(height: 4),
                        Text('#${widget.booking.orderNumber}',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Item condition
            Text('Item condition', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildConditionChip('New', 'excellent'),
                const SizedBox(width: 8),
                _buildConditionChip('Minor wear', 'good'),
                const SizedBox(width: 8),
                _buildConditionChip('Stains/Damage', 'damaged'),
              ],
            ),
            const SizedBox(height: 24),

            // QC Checklist
            Text('Inspection checklist', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 4),
            Text('Compare to the photos you took at pickup.',
                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, height: 1.4)),
            const SizedBox(height: 12),
            ..._checklist.keys.map((k) => _buildChecklistItem(k)),
            const SizedBox(height: 24),

            // Return photos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Return condition photos',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                Text('${_returnPhotos.length}/6',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                ..._returnPhotos.map((p) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(p, fit: BoxFit.cover),
                    )),
                if (_returnPhotos.length < 6)
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
            const SizedBox(height: 24),

            // Reference pickup photos
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(FluentIcons.history_24_regular, color: Color(0xFF1976D2), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Compare to pickup photos from ${DateTime.now().subtract(const Duration(days: 3)).toString().substring(0, 10)}',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark, height: 1.4),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Showing pickup photos...')),
                      );
                    },
                    child: Text('View', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF1976D2), fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Actions
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: TextButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DamageClaimScreen(booking: widget.booking),
                                ),
                              ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: BorderSide(color: Colors.red.shade200),
                        ),
                      ),
                      child: Text('Report damage', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _acceptReturn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _allChecked && _hasPhotos ? AppTheme.textDark : Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        elevation: 0,
                      ),
                      child: _submitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('ACCEPT & RELEASE',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.3)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Accepting returns the deposit to the renter and releases your earnings.',
                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionChip(String label, String value) {
    final isSelected = _itemCondition == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _itemCondition = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.textDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppTheme.textDark : Colors.grey.shade200),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppTheme.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String label) {
    final isChecked = _checklist[label] ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => _checklist[label] = !isChecked),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isChecked ? AppTheme.textDark : Colors.grey.shade200, width: isChecked ? 2 : 1),
          ),
          child: Row(
            children: [
              Icon(
                isChecked ? FluentIcons.checkmark_circle_24_filled : FluentIcons.circle_24_regular,
                color: isChecked ? AppTheme.textDark : AppTheme.textLight,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReturnReleasedScreen extends StatelessWidget {
  final Booking booking;
  const _ReturnReleasedScreen({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppTheme.primaryLime, shape: BoxShape.circle),
                child: const Icon(FluentIcons.checkmark_24_regular, size: 60, color: AppTheme.textDark),
              ),
              const SizedBox(height: 24),
              Text(
                'Return Accepted!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Deposit refunded to renter.\nYour earnings are released to your wallet.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight, height: 1.4),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _Row('Deposit refunded', '₹${booking.securityDeposit.toStringAsFixed(0)}'),
                    _Row('Your earnings', '₹${(booking.rentalFee * 0.85 + booking.insuranceFee).toStringAsFixed(0)}', isBold: true),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppTheme.primaryLime, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(FluentIcons.clock_24_regular, size: 14, color: AppTheme.textDark),
                          const SizedBox(width: 6),
                          Text('Payout every Friday',
                              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RatingScreen(booking: booking, isLenderRating: true),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textDark,
                    side: BorderSide(color: AppTheme.textDark.withOpacity(0.3), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(FluentIcons.star_24_regular, size: 18, color: AppTheme.textDark),
                      const SizedBox(width: 8),
                      Text('RATE RENTER', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainNavigation()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.textDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    elevation: 0,
                  ),
                  child: Text('DONE', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _Row(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: isBold ? 14 : 13, color: AppTheme.textDark, fontWeight: isBold ? FontWeight.w900 : FontWeight.w600)),
          Text(value, style: GoogleFonts.inter(fontSize: isBold ? 16 : 13, color: AppTheme.textDark, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
