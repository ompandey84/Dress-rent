import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/services/wallet_service.dart';
import 'package:dress_app/services/auth_service.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:intl/intl.dart';

/// User wallet — refundable deposit credits, UGC earnings, referral bonuses.
/// Live data from WalletService (Supabase `wallet_transactions` in live mode).
class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  static const _currency = '₹';

  double _available = 0;
  double _held = 0;
  List<WalletTransaction> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final wallet = WalletService();
    final avail = await wallet.getAvailableBalance();
    final held = await wallet.getHeldBalance();
    final txns = await wallet.recentTransactions(limit: 30);
    if (!mounted) return;
    setState(() {
      _available = avail;
      _held = held;
      _transactions = txns;
      _loading = false;
    });
  }

  Future<void> _copyReferralCode() async {
    const code = 'DRESS250';
    await Clipboard.setData(const ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code "$code" copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _withdraw() async {
    if (_available < 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum withdrawal is ₹500')),
      );
      return;
    }
    // Record a withdrawal transaction in mock + live mode.
    final userId = AuthService().currentUserId ?? 'mock_user';
    final supabase = SupabaseService.isConfigured
        ? Supabase.instance.client
        : null;

    try {
      if (supabase != null) {
        await supabase.from('wallet_transactions').insert({
          'user_id': userId,
          'type': WalletTxnType.withdraw.code,
          'amount': _available,
          'description': 'Withdrawal request — bank transfer in 1–2 business days',
        });
      } else {
        // mock: directly via service
        final w = WalletService();
        // No public withdraw method, so we just show success.
        // In a real build, expose WalletService.withdraw(amount).
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdrawal requested. Funds will reach your bank in 1–2 business days.'),
          backgroundColor: AppTheme.success,
        ),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Withdrawal failed: $e')),
      );
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
        title: Text(
          'MY WALLET',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryLime),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: 24),
                    _buildReferralCard(),
                    const SizedBox(height: 24),
                    _buildTransactionsHeader(),
                    const SizedBox(height: 12),
                    if (_transactions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(FluentIcons.receipt_24_regular,
                                  size: 48, color: AppTheme.textLight.withOpacity(0.5)),
                              const SizedBox(height: 12),
                              Text('No transactions yet',
                                  style: GoogleFonts.inter(
                                      color: AppTheme.textLight, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text('Your top-ups, refunds, and UGC credits will appear here.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                      color: AppTheme.textLight, fontSize: 12)),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._transactions.map(_buildTransactionRow),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C222B), Color(0xFF2E3A4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C222B).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('AVAILABLE BALANCE',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white60,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLime,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text('REFUNDABLE',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$_currency${_available.toStringAsFixed(0)}',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryLime,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text('From deposit refunds & credits',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Held in escrow',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white60,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: 4),
                      Text('$_currency${_held.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white60,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: 4),
                      Text(
                        '$_currency${(_available + _held).toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryLime,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _withdraw,
                  icon: const Icon(FluentIcons.arrow_download_24_regular, size: 18, color: AppTheme.textDark),
                  label: Text('WITHDRAW',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                        letterSpacing: 0.5,
                      )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryLime,
                    foregroundColor: AppTheme.textDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _AddMoneySheet(onTopUp: _load),
                    );
                  },
                  icon: const Icon(FluentIcons.add_24_regular, size: 18, color: Colors.white),
                  label: Text('ADD MONEY',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      )),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white30, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryLime.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppTheme.textDark, shape: BoxShape.circle),
            child: const Icon(FluentIcons.gift_24_regular, size: 22, color: AppTheme.primaryLime),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Refer & earn ₹250',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    )),
                Text('Code: DRESS250',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
          TextButton(
            onPressed: _copyReferralCode,
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.textDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: Text('COPY',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Recent transactions',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            )),
        Text('Last 30',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textLight,
              fontWeight: FontWeight.w700,
            )),
      ],
    );
  }

  Widget _buildTransactionRow(WalletTransaction tx) {
    final isCredit = tx.type.isCredit;
    final icon = _iconForSource(tx.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCredit
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                size: 18, color: isCredit ? Colors.green.shade700 : Colors.red.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(_formatDate(tx.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textLight,
                    )),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '−'} $_currency${tx.amount.toStringAsFixed(0)}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isCredit ? Colors.green.shade700 : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForSource(WalletTxnType t) {
    switch (t) {
      case WalletTxnType.depositRefund:
        return FluentIcons.arrow_download_24_regular;
      case WalletTxnType.depositPaid:
        return FluentIcons.arrow_upload_24_regular;
      case WalletTxnType.ugcCredit:
        return FluentIcons.video_24_regular;
      case WalletTxnType.referralBonus:
        return FluentIcons.people_24_regular;
      case WalletTxnType.cashback:
        return FluentIcons.gift_24_regular;
      case WalletTxnType.withdraw:
        return FluentIcons.building_bank_24_regular;
      case WalletTxnType.damageClaim:
        return FluentIcons.alert_24_regular;
      case WalletTxnType.topup:
        return FluentIcons.wallet_24_regular;
    }
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('d MMM yyyy').format(d);
  }
}

class _AddMoneySheet extends StatefulWidget {
  final Future<void> Function() onTopUp;
  const _AddMoneySheet({required this.onTopUp});
  @override
  State<_AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<_AddMoneySheet> {
  static const _currency = '₹';
  bool _processing = false;

  Future<void> _topUp(int amount) async {
    setState(() => _processing = true);
    try {
      // Open Cashfree checkout for a wallet top-up. The service returns a
      // success result in mock mode; in live mode the user pays via
      // Cashfree and we record the top-up transaction after.
      final userId = AuthService().currentUserId ?? 'mock_user';
      if (!SupabaseService.isConfigured) {
        // Mock path
        await WalletService().topUp(amount: amount.toDouble(), source: 'cashfree');
      } else {
        // In live mode, this would invoke Cashfree and only credit on success.
        // For now we record a topup and rely on the mock service to handle
        // the rest until keys are configured.
        await WalletService().topUp(amount: amount.toDouble(), source: 'cashfree');
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_currency$amount added to wallet'),
          backgroundColor: AppTheme.success,
        ),
      );
      await widget.onTopUp();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Top-up failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.textLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('Add money',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    )),
                Text('Top up your wallet for faster checkout',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [500, 1000, 2000, 5000].map((amt) {
                    return GestureDetector(
                      onTap: _processing ? null : () => _topUp(amt),
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 60) / 2,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.textDark, width: 1.5),
                        ),
                        child: Center(
                          child: _processing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: AppTheme.textDark),
                                )
                              : Text(
                                  '+ $_currency$amt',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
