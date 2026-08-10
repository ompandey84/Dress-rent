import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/booking.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:dress_app/services/database_service.dart';
import 'package:dress_app/screens/pack_item_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lender's detail view of a pending booking — accept or reject.
class LenderBookingDetailScreen extends StatefulWidget {
  final Booking booking;
  const LenderBookingDetailScreen({Key? key, required this.booking}) : super(key: key);

  @override
  State<LenderBookingDetailScreen> createState() => _LenderBookingDetailScreenState();
}

class _LenderBookingDetailScreenState extends State<LenderBookingDetailScreen> {
  bool _processing = false;
  late Duration _remaining;
  Timer? _timer;

  // Real data fetched from the DB instead of hardcoded mock values.
  Map<String, dynamic>? _productData;
  Map<String, dynamic>? _renterData;
  String _renterName = 'Renter';
  String _renterInitial = 'R';
  String _renterAvatar = '';
  String _productName = 'Loading…';
  String _productSize = 'M';
  String _productColor = 'Default';
  String _productImage = 'https://placehold.co/200x250';

  @override
  void initState() {
    super.initState();
    _remaining = _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = _calculateRemaining());
    });
    _loadExtras();
  }

  Duration _calculateRemaining() {
    final accepted = widget.booking.acceptedAt ?? widget.booking.createdAt;
    final deadline = accepted.add(const Duration(hours: 4));
    return deadline.difference(DateTime.now());
  }

  Future<void> _loadExtras() async {
    try {
      final db = DatabaseService();
      final product = await db.getProductDetails(widget.booking.listingId);
      Map<String, dynamic>? renter;
      if (SupabaseService.isConfigured) {
        renter = await db.getProfile(widget.booking.renterId);
      }
      if (!mounted) return;
      setState(() {
        _productData = product;
        _renterData = renter;
        _productName = (product['name'] ?? product['title'] ?? 'Item').toString();
        // The first image from the product_images join, fall back to images[0]
        String? img;
        if (product['product_images'] is List &&
            (product['product_images'] as List).isNotEmpty) {
          img = (product['product_images'] as List).first['image_url'] as String?;
        } else if (product['images'] is List &&
            (product['images'] as List).isNotEmpty) {
          img = (product['images'] as List).first as String?;
        }
        if (img != null && img.isNotEmpty) _productImage = img;
        // Size & color
        if (product['product_sizes'] is List &&
            (product['product_sizes'] as List).isNotEmpty) {
          _productSize =
              ((product['product_sizes'] as List).first['size'] ?? 'M').toString();
        }
        if (product['product_colors'] is List &&
            (product['product_colors'] as List).isNotEmpty) {
          _productColor =
              ((product['product_colors'] as List).first['color_name'] ?? 'Default')
                  .toString();
        }
        if (renter != null) {
          _renterName = (renter['full_name'] ?? renter['name'] ?? 'Renter').toString();
          _renterInitial =
              _renterName.isNotEmpty ? _renterName[0].toUpperCase() : 'R';
          _renterAvatar = (renter['avatar_url'] ?? '').toString();
        }
      });
    } catch (_) {
      // Stay with defaults; the screen will still render.
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _accept() async {
    if (_processing) return;
    setState(() => _processing = true);
    try {
      if (SupabaseService.isConfigured) {
        final supabase = Supabase.instance.client;
        await supabase.from('orders').update({
          'status': 'accepted',
          'accepted_at': DateTime.now().toIso8601String(),
        }).eq('id', widget.booking.id);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking accepted — renter notified.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PackItemScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _reject() async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _RejectReasonSheet(),
    );
    if (reason == null) return;

    setState(() => _processing = true);
    try {
      if (SupabaseService.isConfigured) {
        final supabase = Supabase.instance.client;
        await supabase.from('orders').update({
          'status': 'rejected_by_lender',
          'cancellation_reason': reason,
          'cancelled_at': DateTime.now().toIso8601String(),
        }).eq('id', widget.booking.id);
        // (Cashfree refund would be triggered via Edge Function in production)
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking declined. Renter will be fully refunded.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, d MMM yyyy');
    final urgent = _remaining.inMinutes < 60;
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('BOOKING REQUEST',
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
                letterSpacing: 1.0)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Countdown banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: urgent
                    ? const Color(0xFFFFEBEE)
                    : AppTheme.primaryLime.withOpacity(0.2),
              ),
              child: Row(
                children: [
                  Icon(
                    urgent
                        ? FluentIcons.alert_24_filled
                        : FluentIcons.timer_24_regular,
                    color: urgent ? Colors.red.shade700 : AppTheme.textDark,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          urgent ? 'Urgent — respond now' : 'You have time',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: urgent ? Colors.red.shade700 : AppTheme.textDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Auto-cancels in ${_formatRemaining(_remaining)}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: urgent ? Colors.red.shade700 : AppTheme.textDark,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Item
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: _productImage,
                      width: 70,
                      height: 90,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 70,
                        height: 90,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(FluentIcons.box_24_regular, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${widget.booking.orderNumber.isNotEmpty ? widget.booking.orderNumber : widget.booking.id.substring(0, 8).toUpperCase()}',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppTheme.textLight,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _productName,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                              height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Size $_productSize • $_productColor',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppTheme.textLight,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Renter info
            _buildSection(
              title: 'RENTER',
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.primaryLime,
                      backgroundImage: _renterAvatar.isNotEmpty
                          ? CachedNetworkImageProvider(_renterAvatar)
                          : null,
                      child: _renterAvatar.isEmpty
                          ? Text(
                              _renterInitial,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textDark),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_renterName,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 11, color: Color(0xFFFBBC05)),
                              const SizedBox(width: 2),
                              Text(
                                _renterData?['rating'] != null
                                    ? '${_renterData!['rating']} (${_renterData!['reviews_count'] ?? 0} rentals)'
                                    : 'New renter',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppTheme.textLight,
                                    fontWeight: FontWeight.w600),
                              ),
                              if (_renterData?['is_verified'] == true) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'VERIFIED',
                                    style: GoogleFonts.inter(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.green.shade700,
                                        letterSpacing: 0.5),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(FluentIcons.chat_24_regular,
                          color: AppTheme.textDark, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Open chat with renter')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Rental period
            _buildSection(
              title: 'RENTAL PERIOD',
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PICKUP',
                                  style: GoogleFonts.inter(
                                      fontSize: 9,
                                      color: AppTheme.textLight,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0)),
                              const SizedBox(height: 2),
                              Text(dateFormat.format(widget.booking.startDate),
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textDark)),
                              Text('10:00 AM',
                                  style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: AppTheme.textLight,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Container(
                            width: 1,
                            height: 36,
                            color: Colors.grey.shade200),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('RETURN',
                                    style: GoogleFonts.inter(
                                        fontSize: 9,
                                        color: AppTheme.textLight,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.0)),
                                const SizedBox(height: 2),
                                Text(dateFormat.format(widget.booking.endDate),
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textDark)),
                                Text('6:00 PM',
                                    style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: AppTheme.textLight,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppTheme.primaryLime,
                          borderRadius: BorderRadius.circular(100)),
                      child: Text('${widget.booking.rentalDays} day rental',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark)),
                    ),
                  ],
                ),
              ),
            ),
            // Earnings
            _buildSection(
              title: 'YOUR EARNINGS',
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _MoneyRow('Rental fee',
                        '₹${widget.booking.rentalFee.toStringAsFixed(0)}'),
                    if (widget.booking.insuranceFee > 0)
                      _MoneyRow('Damage protection fee',
                          '₹${widget.booking.insuranceFee.toStringAsFixed(0)}'),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Divider(height: 1)),
                    _MoneyRow(
                        'Platform fee (15%)',
                        '-₹${(widget.booking.rentalFee * 0.15).toStringAsFixed(0)}',
                        isNegative: true),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Divider(height: 1)),
                    // Lender keeps 70% of insurance premium (per lend flow copy).
                    _MoneyRow(
                        'You earn (held until return)',
                        '₹${((widget.booking.rentalFee * 0.85) + (widget.booking.insuranceFee * 0.7)).toStringAsFixed(0)}',
                        isBold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextButton(
                    onPressed: _processing ? null : _reject,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        side: BorderSide(color: Colors.red.shade200),
                      ),
                    ),
                    child: Text('Decline',
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _processing ? null : _accept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.textDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)),
                      elevation: 0,
                    ),
                    child: _processing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text('Accept',
                            style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textLight,
                  letterSpacing: 0.6)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  String _formatRemaining(Duration d) {
    if (d.isNegative) return '00:00:00';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _MoneyRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final bool isNegative;
  const _MoneyRow(this.label, this.value, {this.isBold = false, this.isNegative = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                fontSize: isBold ? 12 : 11,
                color: AppTheme.textDark,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              )),
          Text(value,
              style: GoogleFonts.inter(
                fontSize: isBold ? 13 : 11,
                color: isNegative ? Colors.red.shade700 : AppTheme.textDark,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w800,
              )),
        ],
      ),
    );
  }
}

/// Bottom sheet to capture reject reason.
class _RejectReasonSheet extends StatefulWidget {
  @override
  State<_RejectReasonSheet> createState() => _RejectReasonSheetState();
}

class _RejectReasonSheetState extends State<_RejectReasonSheet> {
  final _customReason = TextEditingController();
  String? _selected;

  static const _options = [
    'Item not available',
    'Date conflict',
    'Pricing concern',
    'Borrower has poor rating',
    'Other',
  ];

  @override
  void dispose() {
    _customReason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Decline this booking',
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
            const SizedBox(height: 4),
            Text(
              'The renter will be fully refunded.',
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight),
            ),
            const SizedBox(height: 16),
            ..._options.map((opt) => GestureDetector(
                  onTap: () => setState(() => _selected = opt),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selected == opt
                          ? AppTheme.primaryLime.withOpacity(0.1)
                          : const Color(0xFFF6F8FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selected == opt
                            ? AppTheme.primaryLime
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selected == opt
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 18,
                          color: _selected == opt
                              ? AppTheme.primaryLime
                              : AppTheme.textLight,
                        ),
                        const SizedBox(width: 10),
                        Text(opt,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark)),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 8),
            TextField(
              controller: _customReason,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Add a note (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final reason = _selected == 'Other'
                      ? _customReason.text.trim()
                      : _selected ?? _customReason.text.trim();
                  if (reason.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pick a reason first')),
                    );
                    return;
                  }
                  Navigator.pop(context, reason);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
                child: Text('Decline booking',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
