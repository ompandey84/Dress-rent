import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/booking.dart';
import 'package:dress_app/services/storage_service.dart';
import 'package:dress_app/services/cashfree_service.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/screens/main_navigation.dart';

/// Reject at Delivery — renter has 5 minutes to inspect and reject
/// if item doesn't match listing. Instant refund triggered.
class RejectAtDeliveryScreen extends StatefulWidget {
  final Booking booking;
  const RejectAtDeliveryScreen({Key? key, required this.booking}) : super(key: key);

  @override
  State<RejectAtDeliveryScreen> createState() => _RejectAtDeliveryScreenState();
}

class _RejectAtDeliveryScreenState extends State<RejectAtDeliveryScreen> {
  String? _selectedReason;
  final _description = TextEditingController();
  final List<File> _photos = [];
  bool _submitting = false;
  int _secondsLeft = 300; // 5 minutes to inspect

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _secondsLeft = (_secondsLeft - 1).clamp(0, 300));
      return _secondsLeft > 0;
    });
  }

  final _reasons = [
    {'id': 'wrong_item', 'label': 'Wrong item received'},
    {'id': 'damaged', 'label': 'Item is damaged'},
    {'id': 'not_as_described', 'label': 'Not as described'},
    {'id': 'missing_accessories', 'label': 'Missing accessories'},
    {'id': 'late', 'label': 'Significantly late'},
  ];

  Future<void> _submit() async {
    if (_selectedReason == null || _photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a reason and add at least 1 photo')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      // Upload photos
      final urls = <String>[];
      for (var i = 0; i < _photos.length; i++) {
        final url = await StorageService().uploadAvatar(_photos[i], 'reject-${widget.booking.id}-$i');
        urls.add(url);
      }

      if (SupabaseService.isConfigured) {
        final supabase = Supabase.instance.client;
        await supabase.from('orders').update({
          'status': 'cancelled_by_renter',
          'cancellation_reason': '$_selectedReason: ${_description.text}',
          'cancelled_at': DateTime.now().toIso8601String(),
          'rejection_photos': urls,
        }).eq('id', widget.booking.id);
        // Refund in full
        if (widget.booking.cashfreeOrderId != null) {
          await CashfreeService().refund(
            orderId: widget.booking.cashfreeOrderId!,
            amount: widget.booking.total,
            reason: 'Item rejected at delivery',
          );
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => _RefundIssuedScreen(amount: widget.booking.total),
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

  Future<void> _addPhoto() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mins = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final secs = (_secondsLeft % 60).toString().padLeft(2, '0');
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FluentIcons.dismiss_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('REJECT AT DELIVERY',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.textDark, borderRadius: BorderRadius.circular(100)),
                child: Row(
                  children: [
                    const Icon(FluentIcons.timer_24_regular, color: AppTheme.primaryLime, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$mins:$secs',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.primaryLime,
                        fontWeight: FontWeight.w900,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(FluentIcons.alert_24_regular, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Inspect the item now. Once accepted, no claims allowed.',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark, height: 1.4, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Why are you rejecting?',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            ..._reasons.map((r) => _buildReasonTile(r)),
            const SizedBox(height: 16),
            Text('Describe the issue', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tell us what\'s wrong...',
                hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.textDark, width: 2)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 16),
            Text('Photo evidence', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
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
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(FluentIcons.arrow_reset_24_regular, color: AppTheme.textDark, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Full refund of ₹${widget.booking.total.toStringAsFixed(0)} will be issued within 24h',
                          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('REJECT & REQUEST REFUND',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonTile(Map<String, dynamic> r) {
    final isSelected = _selectedReason == r['id'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedReason = r['id'] as String),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.textDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppTheme.textDark : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? FluentIcons.checkmark_circle_24_filled : FluentIcons.circle_24_regular,
                color: isSelected ? Colors.white : AppTheme.textLight,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(r['label'] as String, style: GoogleFonts.inter(
                fontSize: 14,
                color: isSelected ? Colors.white : AppTheme.textDark,
                fontWeight: FontWeight.w700,
              )),
            ],
          ),
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

class _RefundIssuedScreen extends StatelessWidget {
  final double amount;
  const _RefundIssuedScreen({required this.amount});

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
                child: const Icon(FluentIcons.arrow_reset_24_regular, size: 60, color: AppTheme.textDark),
              ),
              const SizedBox(height: 24),
              Text('Refund Initiated',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text(
                '₹${amount.toStringAsFixed(0)} will be refunded within 24h. We\'ve also reported this to the lender.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight, height: 1.4),
              ),
              const SizedBox(height: 32),
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
                  child: Text('BACK TO HOME', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
