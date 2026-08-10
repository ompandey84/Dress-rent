import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/product.dart';
import 'package:dress_app/models/booking.dart';
import 'package:dress_app/screens/my_orders_screen.dart';
import 'package:dress_app/screens/main_navigation.dart';
import 'package:dress_app/screens/rating_screen.dart';
import 'package:dress_app/screens/ugc_share_screen.dart';

class BookingConfirmedScreen extends StatelessWidget {
  final Booking booking;
  final Product product;
  const BookingConfirmedScreen({Key? key, required this.booking, required this.product}) : super(key: key);

  static const _currency = '₹';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Success animation
              Container(
                width: 100,
                height: 100,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryLime,
                  shape: BoxShape.circle,
                ),
                child: const Icon(FluentIcons.checkmark_24_regular, size: 60, color: AppTheme.textDark),
              ),
              const SizedBox(height: 24),
              Text(
                'Booking Confirmed!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Your order ${booking.orderNumber} has been placed.\nThe lender will confirm within 4 hours.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight, height: 1.4),
              ),
              const SizedBox(height: 32),
              // Order card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('ORDER #',
                            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                        Text(booking.orderNumber,
                            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textDark, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLime,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text('PAID',
                              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: 1.0)),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: product.images.isNotEmpty ? product.images.first : 'https://placehold.co/200x250',
                            width: 70,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.storeName,
                                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textLight, letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                product.name,
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, height: 1.2),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    _Row('Rental Period', '${booking.rentalDays} days'),
                    _Row('Total Paid', '$_currency${booking.total.toStringAsFixed(0)}'),
                    _Row('Deposit (Refundable)', '$_currency${booking.securityDeposit.toStringAsFixed(0)}'),
                    if (booking.hasInsurance)
                      _Row('Damage Protection', '$_currency${booking.insuranceFee.toStringAsFixed(0)}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // What's next
              Text("What's next?", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              const SizedBox(height: 12),
              _NextStep(
                step: '1',
                title: 'Lender confirmation',
                subtitle: 'You\'ll get a notification within 4 hours. After that, item will be prepared for delivery.',
              ),
              _NextStep(
                step: '2',
                title: 'Item delivery',
                subtitle: 'On your pickup date, our rider will deliver the item. You can track in real-time.',
              ),
              _NextStep(
                step: '3',
                title: 'Enjoy your rental',
                subtitle: 'Wear it, love it. Return on the return date to get your deposit refunded.',
              ),
              const SizedBox(height: 24),
              // Rental agreement link
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(FluentIcons.document_24_regular, color: Color(0xFF1976D2), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Rental agreement generated',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF1976D2)),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Rental agreement PDF downloaded')),
                        );
                      },
                      child: Text('Download',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF1976D2))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // CTAs
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainNavigation()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.textDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    elevation: 0,
                  ),
                  child: Text('CONTINUE SHOPPING',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                      side: BorderSide(color: AppTheme.textDark.withOpacity(0.3), width: 1.5),
                    ),
                  ),
                  child: Text('TRACK MY ORDER',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
              ),
              const SizedBox(height: 20),
              // Quick actions row: rate + share UGC
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RatingScreen(booking: booking),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: AppTheme.textLight.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(FluentIcons.star_24_regular, size: 16, color: AppTheme.textDark),
                            const SizedBox(width: 6),
                            Text('RATE LENDER', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UgcShareScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLime,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(FluentIcons.video_24_regular, size: 16, color: AppTheme.textDark),
                            const SizedBox(width: 6),
                            Text('SHARE & EARN ₹100', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 0.3)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
          Text(value, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _NextStep extends StatelessWidget {
  final String step;
  final String title;
  final String subtitle;
  const _NextStep({required this.step, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppTheme.textDark,
              shape: BoxShape.circle,
            ),
            child: Text(step,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
