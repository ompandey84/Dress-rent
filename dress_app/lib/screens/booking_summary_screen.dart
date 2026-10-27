import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/product.dart';
import 'package:dress_app/models/cart_item.dart';
import 'package:dress_app/services/booking_service.dart';
import 'package:dress_app/services/wallet_service.dart';
import 'package:dress_app/screens/payment_screen.dart';
import 'package:dress_app/screens/wallet/wallet_screen.dart';
import 'package:dress_app/utils/auth_guard.dart';

class BookingSummaryScreen extends StatefulWidget {
  final Product product;
  final CartItem cartItem;
  const BookingSummaryScreen({super.key, required this.product, required this.cartItem});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  late BookingPricing _pricing;
  final _promoController = TextEditingController();
  static const _currency = '₹';

  // Wallet state
  double _walletAvailable = 0;
  double _walletTopUp = 0; // amount the user has chosen to add to cover shortfall
  bool _walletChecked = false;
  bool _useWalletForDeposit = true;

  @override
  void initState() {
    super.initState();
    _pricing = BookingService().calculatePricing(
      product: widget.product,
      startDate: widget.cartItem.rentalStartDate,
      endDate: widget.cartItem.rentalEndDate,
      includeInsurance: false,
    );
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    final bal = await WalletService().getAvailableBalance();
    if (!mounted) return;
    setState(() {
      _walletAvailable = bal;
      _walletChecked = true;
    });
  }

  void _recalculate({bool? includeInsurance, double? discount}) {
    setState(() {
      _pricing = BookingService().calculatePricing(
        product: widget.product,
        startDate: widget.cartItem.rentalStartDate,
        endDate: widget.cartItem.rentalEndDate,
        includeInsurance: includeInsurance ?? _pricing.includeInsurance,
        discount: discount ?? _pricing.discount,
      );
    });
  }

  double get _depositShortfall {
    if (!_useWalletForDeposit) return _pricing.securityDeposit;
    final gap = _pricing.securityDeposit - _walletAvailable - _walletTopUp;
    return gap > 0 ? gap : 0;
  }

  /// What the renter pays RIGHT NOW via Cashfree.
  /// = rental + insurance + delivery - discount + (deposit shortfall)
  /// The deposit that IS already in the wallet is locked (not paid again).
  double get _amountToPayNow {
    final base = _pricing.rentalFee + _pricing.insuranceFee + _pricing.deliveryFee - _pricing.discount;
    return base + _depositShortfall;
  }

  /// What the lender can claim later (held in wallet as escrow).
  double get _amountHeldInWallet {
    if (!_useWalletForDeposit) return 0;
    final covered = (_pricing.securityDeposit - _depositShortfall).clamp(0, _pricing.securityDeposit).toDouble();
    return covered;
  }

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    if (code == 'DRESS20') {
      _recalculate(discount: _pricing.rentalFee * 0.2);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 20% promo applied!')),
      );
    } else if (code == 'FIRST50') {
      _recalculate(discount: 50);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 ₹50 off applied!')),
      );
    } else if (code.isEmpty) {
      return;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid promo code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullDateFormat = DateFormat('EEE, d MMM yyyy');

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('BOOKING SUMMARY',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: widget.product.images.isNotEmpty
                                ? widget.product.images.first
                                : 'https://placehold.co/200x250',
                            width: 80,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.storeName,
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textLight, letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.product.name,
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, height: 1.2),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  if (widget.cartItem.selectedSize.isNotEmpty) ...[
                                    Text('Size: ${widget.cartItem.selectedSize}',
                                        style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 8),
                                  ],
                                  if (widget.cartItem.selectedColor.isNotEmpty)
                                    Text('Color: ${widget.cartItem.selectedColor}',
                                        style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Rental period
                  _buildSection(
                    title: 'Rental Period',
                    icon: FluentIcons.calendar_24_regular,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _DateBox(
                              label: 'PICKUP',
                              date: fullDateFormat.format(widget.cartItem.rentalStartDate),
                              time: '10:00 AM',
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Center(
                              child: Icon(FluentIcons.arrow_right_24_regular, color: AppTheme.textLight, size: 20),
                            ),
                          ),
                          Expanded(
                            child: _DateBox(
                              label: 'RETURN',
                              date: fullDateFormat.format(widget.cartItem.rentalEndDate),
                              time: '6:00 PM',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLime.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(FluentIcons.clock_24_regular, size: 14, color: AppTheme.textDark),
                        const SizedBox(width: 6),
                        Text(
                          '${_pricing.rentalDays} day${_pricing.rentalDays > 1 ? 's' : ''} rental',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Rental terms (moved from the product page)
                  _buildRentalTerms(),
                  const SizedBox(height: 24),

                  // Insurance
                  _buildInsuranceCard(),
                  const SizedBox(height: 16),

                  // Promo code
                  _buildSection(
                    title: 'Have a promo code?',
                    icon: FluentIcons.ticket_horizontal_24_regular,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _promoController,
                              decoration: InputDecoration(
                                hintText: 'Enter code',
                                hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              textCapitalization: TextCapitalization.characters,
                            ),
                          ),
                          TextButton(
                            onPressed: _applyPromo,
                            child: Text('Apply',
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_pricing.discount > 0) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '💡 Try: DRESS20 (20% off) or FIRST50 (₹50 off)',
                        style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Price breakdown
                  _buildPriceBreakdown(),
                  const SizedBox(height: 16),

                  // Wallet deposit engine
                  _buildWalletSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom action
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pay now',
                            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('$_currency${_amountToPayNow.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                        if (_amountHeldInWallet > 0)
                          Text('+ ${_currency}${_amountHeldInWallet.toStringAsFixed(0)} in wallet',
                              style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textLight, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!await AuthGuard.requireLogin(
                          context,
                          message: 'Please sign in to proceed to payment and confirm your booking.',
                        )) return;
                        if (!context.mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentScreen(
                              product: widget.product,
                              cartItem: widget.cartItem,
                              pricing: _pricing,
                              amountToPayNow: _amountToPayNow,
                              walletTopUp: _walletTopUp,
                              useWalletForDeposit: _useWalletForDeposit,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.textDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        elevation: 0,
                      ),
                      child: Row(
                        children: [
                          Text('Continue',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                          const SizedBox(width: 6),
                          const Icon(FluentIcons.arrow_right_24_regular, size: 18, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.textDark),
            const SizedBox(width: 8),
            Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildRentalTerms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rental terms',
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFE082)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(FluentIcons.info_24_regular,
                  size: 16, color: Color(0xFFE65100)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Full refund if cancelled 48h before rental start. Within 48h, 50% refund. No refund once item is shipped.',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textDark,
                      height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsuranceCard() {
    final rentalDays = _pricing.rentalDays;
    final insuranceFee = BookingService().calculatePricing(
      product: widget.product,
      startDate: widget.cartItem.rentalStartDate,
      endDate: widget.cartItem.rentalEndDate,
      includeInsurance: true,
    ).insuranceFee;

    return Container(
      decoration: BoxDecoration(
        color: _pricing.includeInsurance
            ? AppTheme.primaryLime.withOpacity(0.15)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _pricing.includeInsurance ? AppTheme.primaryLime : Colors.grey.shade200,
          width: _pricing.includeInsurance ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // RECOMMENDED pill at the very top of the section so it can't wrap
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.textDark,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'RECOMMENDED',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: icon + title + price + toggle
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLime.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                          FluentIcons.shield_checkmark_24_regular,
                          color: AppTheme.textDark,
                          size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Damage Protection',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Covers up to 100% of damage for just 5% of rental fee',
                            style: GoogleFonts.inter(
                                fontSize: 10, color: AppTheme.textLight),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (_pricing.includeInsurance) ...[
                      Text(
                        '+₹${insuranceFee.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textDark),
                      ),
                      const SizedBox(width: 8),
                    ],
                    GestureDetector(
                      onTap: () => _recalculate(
                          includeInsurance: !_pricing.includeInsurance),
                      child: Container(
                        width: 44,
                        height: 26,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: _pricing.includeInsurance
                              ? AppTheme.textDark
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Stack(
                          children: [
                            AnimatedAlign(
                              duration: const Duration(milliseconds: 180),
                              alignment: _pricing.includeInsurance
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                    color: Colors.white, shape: BoxShape.circle),
                                child: _pricing.includeInsurance
                                    ? const Icon(Icons.check,
                                        size: 12, color: AppTheme.textDark)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // T&Cs disclosure
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 14),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              shape: const Border(),
              collapsedShape: const Border(),
              title: Row(
                children: [
                  const Icon(FluentIcons.document_24_regular,
                      size: 13, color: AppTheme.textLight),
                  const SizedBox(width: 6),
                  Text('Read full T&Cs',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textLight,
                          decoration: TextDecoration.underline)),
                ],
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _tc(
                          'Covers accidental stains (wine, food, makeup), small tears, color transfer, broken zippers & buttons up to 100% of item value.'),
                      _tc(
                          'Does NOT cover: lost items, intentional damage, normal wear & tear, alterations made by renter.'),
                      _tc(
                          'Claim must be filed within 24 hours of return with photo evidence. Lender verifies and approves the claim.'),
                      _tc(
                          'Premium = 5% of rental subtotal (₹${(widget.product.rentalPricePerDay * rentalDays * 0.05).toStringAsFixed(0)} for this booking).'),
                      _tc(
                          'By toggling ON, you agree to the Damage Protection terms. Toggle is instant — no extra page.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tc(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 8),
            child: Icon(FluentIcons.checkmark_24_regular, size: 12, color: AppTheme.textLight),
          ),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textDark, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _priceLine('${widget.product.name} × ${_pricing.rentalDays} day${_pricing.rentalDays > 1 ? 's' : ''}',
              '${_currency}${(widget.product.rentalPricePerDay * _pricing.rentalDays).toStringAsFixed(0)}'),
          if (_pricing.deliveryFee > 0)
            _priceLine('Delivery fee', '${_currency}${_pricing.deliveryFee.toStringAsFixed(0)}')
          else
            _priceLine('Delivery', 'FREE', valueColor: Colors.green.shade700),
          if (_pricing.insuranceFee > 0)
            _priceLine('Damage protection (5%)', '${_currency}${_pricing.insuranceFee.toStringAsFixed(0)}'),
          if (_pricing.discount > 0)
            _priceLine('Promo discount', '-${_currency}${_pricing.discount.toStringAsFixed(0)}',
                valueColor: Colors.green.shade700),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
          _priceLine('Pay now (rental + insurance + top-up)',
              '${_currency}${_amountToPayNow.toStringAsFixed(0)}',
              valueColor: AppTheme.textDark, isBold: true),
          if (_useWalletForDeposit && _amountHeldInWallet > 0)
            _priceLine('Held in wallet (refundable deposit)',
                '${_currency}${_amountHeldInWallet.toStringAsFixed(0)}',
                helper: 'Locked & refunded after safe return',
                valueColor: AppTheme.info),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(FluentIcons.shield_checkmark_24_regular, size: 14, color: Colors.green.shade700),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${_currency}${_pricing.securityDeposit.toStringAsFixed(0)} deposit refunded after safe return',
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Wallet section: shows available balance, deposit coverage, and a quick
  /// top-up row if the balance is short. Hidden when this product has no
  /// security deposit (deposit = 0).
  Widget _buildWalletSection() {
    // No deposit required for this listing — skip the entire wallet block.
    if (_pricing.securityDeposit <= 0) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF8F4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFCBE9D8)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: Color(0xFF2E7D5B), shape: BoxShape.circle),
              child: const Icon(FluentIcons.checkmark_24_regular,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No deposit needed',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark)),
                  Text('This item is fully covered by the rental fee.',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppTheme.textLight)),
                ],
              ),
            ),
          ],
        ),
      );
    }
    if (!_walletChecked) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryLime),
            ),
            const SizedBox(width: 12),
            Text('Checking wallet…', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight)),
          ],
        ),
      );
    }
    final covers = _walletAvailable >= _pricing.securityDeposit;
    final shortfall = _depositShortfall;
    final useTopUp = _useWalletForDeposit && _walletTopUp > 0;
    final effectiveBalance = _walletAvailable + _walletTopUp;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: covers || (useTopUp && effectiveBalance >= _pricing.securityDeposit)
              ? AppTheme.primaryLime
              : Colors.grey.shade200,
          width: covers ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppTheme.primaryLime, shape: BoxShape.circle),
                child: const Icon(FluentIcons.wallet_credit_card_24_regular, size: 18, color: AppTheme.textDark),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Wallet deposit', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                    Text(
                      covers
                          ? 'Your wallet covers the deposit'
                          : 'Wallet short by ${_currency}${shortfall.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(fontSize: 11, color: covers ? AppTheme.success : AppTheme.warning, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _useWalletForDeposit,
                onChanged: (v) => setState(() {
                  _useWalletForDeposit = v;
                  if (v) {
                    _walletTopUp = 0;
                  }
                }),
                activeColor: AppTheme.textDark,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Balance + deposit info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Wallet balance', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                    Text('${_currency}${_walletAvailable.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Required deposit', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                    Text('${_currency}${_pricing.securityDeposit.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  ],
                ),
                if (useTopUp) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Top-up selected', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                      Text('+${_currency}${_walletTopUp.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.success)),
                    ],
                  ),
                ],
                const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Divider(height: 1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Held as escrow', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark, fontWeight: FontWeight.w800)),
                    Text('${_currency}${_amountHeldInWallet.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: covers || useTopUp ? AppTheme.textDark : AppTheme.danger)),
                  ],
                ),
              ],
            ),
          ),
          // Shortfall quick top-up chips
          if (_useWalletForDeposit && shortfall > 0) ...[
            const SizedBox(height: 14),
            Text('Top up to cover deposit', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _topUpOptions(shortfall).map((amt) {
                final isSelected = _walletTopUp == amt;
                return GestureDetector(
                  onTap: () => setState(() => _walletTopUp = amt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.textDark : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: isSelected ? AppTheme.textDark : Colors.grey.shade300, width: 1.5),
                    ),
                    child: Text('+ ${_currency}${amt.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : AppTheme.textDark)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push<double>(context, MaterialPageRoute(builder: (_) => const _QuickTopUpScreen()));
                if (result != null) {
                  setState(() => _walletTopUp = result);
                }
              },
              child: Row(
                children: [
                  const Icon(FluentIcons.add_circle_24_regular, size: 14, color: AppTheme.textLight),
                  const SizedBox(width: 4),
                  Text('Custom amount', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w700, decoration: TextDecoration.underline)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Compute the top-up chips. Must be enough to cover the shortfall.
  List<double> _topUpOptions(double shortfall) {
    // Round shortfall up to a friendly number for chips
    final options = <double>{};
    options.add(shortfall);
    if (shortfall < 500) {
      options.addAll([500.0, 1000.0, 2000.0]);
    } else if (shortfall < 1000) {
      options.addAll([1000.0, 2000.0, 5000.0]);
    } else {
      options.addAll([(shortfall / 1000).ceil() * 1000.0, ((shortfall / 1000).ceil() + 1) * 1000.0]);
    }
    return options.toList()..sort();
  }

  Widget _priceLine(String label, String value, {String? helper, Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(
                  fontSize: isBold ? 14 : 13,
                  color: AppTheme.textDark,
                  fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
                )),
                if (helper != null)
                  Text(helper, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight)),
              ],
            ),
          ),
          Text(value,
              style: GoogleFonts.inter(
                fontSize: isBold ? 14 : 13,
                fontWeight: FontWeight.w800,
                color: valueColor ?? AppTheme.textDark,
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }
}

class _QuickTopUpScreen extends StatefulWidget {
  const _QuickTopUpScreen();
  @override
  State<_QuickTopUpScreen> createState() => _QuickTopUpScreenState();
}

class _QuickTopUpScreenState extends State<_QuickTopUpScreen> {
  final _controller = TextEditingController();

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
        title: Text('TOP UP WALLET', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add to wallet', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 4),
            Text('Top up via UPI / Card / NetBanking. Funds are instantly available.',
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),
            Text('AMOUNT', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '1000',
                prefixText: '₹ ',
                prefixStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.textDark, width: 1.5)),
              ),
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textDark),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [500.0, 1000.0, 2000.0, 5000.0].map((amt) {
                return GestureDetector(
                  onTap: () => _controller.text = amt.toStringAsFixed(0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100), border: Border.all(color: AppTheme.textLight.withOpacity(0.3))),
                    child: Text('₹${amt.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final v = double.tryParse(_controller.text);
                  if (v == null || v <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
                    return;
                  }
                  Navigator.pop(context, v);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: Text('USE THIS AMOUNT', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WalletScreen()),
                );
              },
              child: Center(
                child: Text('Open full wallet', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w800, decoration: TextDecoration.underline)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final String date;
  final String time;
  const _DateBox({required this.label, required this.date, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.textLight, letterSpacing: 1.0),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark, height: 1.2),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
