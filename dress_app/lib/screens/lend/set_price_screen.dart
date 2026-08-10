import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/listing_draft.dart';

/// Step 3: Set per-day price, deposit, optional insurance, and rental window.
class SetPriceScreen extends StatefulWidget {
  final ListingDraft draft;
  const SetPriceScreen({Key? key, required this.draft}) : super(key: key);

  @override
  State<SetPriceScreen> createState() => _SetPriceScreenState();
}

class _SetPriceScreenState extends State<SetPriceScreen> {
  late final TextEditingController _pricePerDay;
  late final TextEditingController _deposit;
  late final TextEditingController _insurance;
  late final TextEditingController _minDays;
  late final TextEditingController _maxDays;

  @override
  void initState() {
    super.initState();
    _pricePerDay = TextEditingController(text: widget.draft.pricePerDay == 0 ? '' : widget.draft.pricePerDay.toStringAsFixed(0));
    _deposit = TextEditingController(text: widget.draft.securityDeposit == 0 ? '' : widget.draft.securityDeposit.toStringAsFixed(0));
    _insurance = TextEditingController(text: widget.draft.insuranceFee?.toStringAsFixed(0) ?? '');
    _minDays = TextEditingController(text: widget.draft.minDays.toString());
    _maxDays = TextEditingController(text: widget.draft.maxDays.toString());
  }

  @override
  void dispose() {
    _pricePerDay.dispose();
    _deposit.dispose();
    _insurance.dispose();
    _minDays.dispose();
    _maxDays.dispose();
    super.dispose();
  }

  Widget _priceField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
    String? helper,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (v) {
            onChanged(v);
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
            prefixText: prefix,
            prefixStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.textDark, width: 1.5)),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(helper, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight)),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  /// AI-style suggested price based on category.
  String? get _suggestedPrice {
    final cat = widget.draft.category;
    if (cat == 'Bridal') return '₹3,500-6,000';
    if (cat == 'Ethnic') return '₹1,500-3,000';
    if (cat == 'Formal' || cat == 'Party') return '₹1,200-2,500';
    if (cat == 'Sports') return '₹600-1,200';
    return '₹800-1,800';
  }

  /// Earnings calculator: rough 85% share per 4-day booking.
  String get _earningsEstimate {
    final p = double.tryParse(_pricePerDay.text) ?? 0;
    if (p == 0) return '—';
    final est = (p * 4 * 0.85).round();
    return '₹$est per 4-day booking';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Suggested price card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryLime.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(FluentIcons.lightbulb_24_regular, size: 18, color: AppTheme.textDark),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Suggested for ${widget.draft.category}: ${_suggestedPrice ?? "₹800-1,800"}/day',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _priceField(
            label: 'PRICE PER DAY *',
            controller: _pricePerDay,
            hint: '1500',
            prefix: '₹ ',
            onChanged: (v) => widget.draft.pricePerDay = double.tryParse(v) ?? 0,
          ),
          _priceField(
            label: 'SECURITY DEPOSIT *',
            controller: _deposit,
            hint: '3000',
            prefix: '₹ ',
            helper: 'Fully refundable. Capped at claim amount if damaged.',
            onChanged: (v) => widget.draft.securityDeposit = double.tryParse(v) ?? 0,
          ),
          _priceField(
            label: 'INSURANCE FEE (OPTIONAL)',
            controller: _insurance,
            hint: '100',
            prefix: '₹ ',
            helper: 'Renter can opt-in. You get 70% of this fee.',
            onChanged: (v) => widget.draft.insuranceFee = double.tryParse(v),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _priceField(
                  label: 'MIN DAYS',
                  controller: _minDays,
                  hint: '1',
                  onChanged: (v) => widget.draft.minDays = int.tryParse(v) ?? 1,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _priceField(
                  label: 'MAX DAYS',
                  controller: _maxDays,
                  hint: '14',
                  onChanged: (v) => widget.draft.maxDays = int.tryParse(v) ?? 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Earnings estimate
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.textDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: AppTheme.primaryLime, shape: BoxShape.circle),
                  child: const Icon(FluentIcons.wallet_24_regular, size: 20, color: AppTheme.textDark),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('YOUR EARNINGS', style: GoogleFonts.inter(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                      const SizedBox(height: 2),
                      Text(_earningsEstimate, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryLime)),
                      Text('After 15% platform fee', style: GoogleFonts.inter(fontSize: 11, color: Colors.white60)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
