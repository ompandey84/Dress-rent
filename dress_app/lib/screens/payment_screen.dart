import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/product.dart';
import 'package:dress_app/models/cart_item.dart';
import 'package:dress_app/models/booking.dart';
import 'package:dress_app/services/booking_service.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/services/cashfree_service.dart';
import 'package:dress_app/services/wallet_service.dart';
import 'package:dress_app/screens/booking_confirmed_screen.dart';
import 'package:dress_app/screens/main_navigation.dart';
import 'package:dress_app/widgets/error_dialog.dart';
import 'package:provider/provider.dart';

/// Payment screen — opens Cashfree checkout (or mock success in dev mode).
class PaymentScreen extends StatefulWidget {
  final Product product;
  final CartItem cartItem;
  final BookingPricing pricing;
  // Wallet-aware payment
  final double amountToPayNow;
  final double walletTopUp;
  final bool useWalletForDeposit;
  const PaymentScreen({
    Key? key,
    required this.product,
    required this.cartItem,
    required this.pricing,
    this.amountToPayNow = 0,
    this.walletTopUp = 0,
    this.useWalletForDeposit = true,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'upi';
  bool _processing = false;
  static const _currency = '₹';

  final _methods = [
    {'id': 'upi', 'label': 'UPI', 'icon': FluentIcons.payment_24_regular, 'desc': 'GPay, PhonePe, Paytm'},
    {'id': 'card', 'label': 'Card', 'icon': Icons.credit_card, 'desc': 'Credit / Debit card'},
    {'id': 'netbanking', 'label': 'Net Banking', 'icon': Icons.account_balance, 'desc': 'All major banks'},
    {'id': 'wallet', 'label': 'Wallet', 'icon': Icons.account_balance_wallet, 'desc': 'Paytm, Amazon Pay'},
  ];

  Future<void> _processPayment() async {
    setState(() => _processing = true);

    try {
      // 1. Create booking FIRST (so we have a real Supabase UUID), then
      //    lock the deposit and top up the wallet against THAT booking.
      //    This way the deposit can be released against the same id later.
      final booking = await BookingService().createBooking(
        product: widget.product,
        cartItem: widget.cartItem,
        pricing: widget.pricing,
      );

      // 2. Top up wallet if user picked a top-up amount to cover shortfall
      if (widget.walletTopUp > 0) {
        await WalletService().topUp(amount: widget.walletTopUp, source: 'cashfree_topup');
      }

      // 3. Lock the deposit in the wallet (held as escrow for this booking).
      //    Skip if the product has no deposit (deposit == 0) — many items
      //    don't require a security deposit.
      if (widget.useWalletForDeposit && widget.pricing.securityDeposit > 0) {
        final wallet = WalletService();
        final shortfall = await wallet.depositShortfall(widget.pricing.securityDeposit);
        await wallet.lockDeposit(
          amount: widget.pricing.securityDeposit,
          bookingId: booking.id, // REAL id, not a temp id
          amountToChargeExternally: shortfall > 0 ? widget.walletTopUp : 0,
        );
      }

      // 4. Get user info for payment
      final user = context.read<AppState>().currentUser;

      // 5. Charge ONLY the wallet-aware amount via Cashfree.
      //    The deposit covered by wallet stays in the wallet as escrow.
      final result = await BookingService().payForBooking(
        booking: booking,
        customerName: user.name,
        customerEmail: user.email.isNotEmpty ? user.email : 'user@dress.app',
        customerPhone: user.phone.isNotEmpty ? user.phone : '9999999999',
        amount: widget.amountToPayNow, // <-- pass the wallet-aware amount
      );

      if (!mounted) return;

      if (result.isSuccess) {
        // 6. Mark as paid
        await BookingService().markAsPaid(booking.id);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookingConfirmedScreen(booking: booking, product: widget.product),
          ),
        );
      } else if (result.isCancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment cancelled')),
        );
      } else {
        throw result.errorMessage ?? 'Payment failed';
      }
    } catch (e) {
      if (mounted) {
        final desc = ErrorDialog.describe(e);
        await ErrorDialog.show(
          context,
          title: desc.title,
          message: desc.message,
          technical: e.toString(),
          onRetry: _processPayment,
          retryLabel: 'RETRY PAYMENT',
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
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
          onPressed: _processing ? null : () => Navigator.pop(context),
        ),
        title: Text('PAYMENT',
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
                  // Amount card
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
                        Text('AMOUNT TO PAY',
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white70, letterSpacing: 1.5)),
                        const SizedBox(height: 6),
                        Text('${_currency}${widget.amountToPayNow > 0 ? widget.amountToPayNow.toStringAsFixed(0) : widget.pricing.total.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
                        const SizedBox(height: 6),
                        if (widget.useWalletForDeposit) ...[
                          Text(
                            '+ ${_currency}${widget.pricing.securityDeposit.toStringAsFixed(0)} held in your wallet (refundable)',
                            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.primaryLime, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Row(
                          children: [
                            const Icon(FluentIcons.shield_checkmark_24_regular, size: 12, color: AppTheme.primaryLime),
                            const SizedBox(width: 6),
                            Text('Secured by Cashfree',
                                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.primaryLime, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Choose payment method
                  Text('Choose payment method',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  const SizedBox(height: 10),
                  Column(
                    children: _methods.map((m) => _buildMethodTile(m)).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Security badges
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(FluentIcons.shield_keyhole_24_regular, color: AppTheme.textDark, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your payment info is encrypted and never stored on our servers.',
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Powered by Cashfree • PCI DSS Level 1',
                      style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pay button
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
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _processing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryLime,
                    foregroundColor: AppTheme.textDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    elevation: 0,
                  ),
                  child: _processing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.textDark),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(FluentIcons.lock_closed_24_regular, size: 18, color: AppTheme.textDark),
                            const SizedBox(width: 8),
                            Text('PAY ${_currency}${widget.pricing.total.toStringAsFixed(0)} NOW',
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: 0.5)),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTile(Map<String, dynamic> method) {
    final isSelected = _selectedMethod == method['id'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = method['id'] as String),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
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
                  color: AppTheme.primaryLime.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(method['icon'] as IconData, color: AppTheme.textDark, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(method['label'] as String,
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                    Text(method['desc'] as String,
                        style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(FluentIcons.checkmark_circle_24_filled, color: AppTheme.textDark, size: 24)
              else
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
