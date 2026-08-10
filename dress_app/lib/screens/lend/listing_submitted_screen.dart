import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/listing_draft.dart';
import 'package:dress_app/screens/main_navigation.dart';

/// Shown after the lender submits a listing for review.
class ListingSubmittedScreen extends StatelessWidget {
  final ListingDraft draft;
  const ListingSubmittedScreen({Key? key, required this.draft}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppTheme.primaryLime, shape: BoxShape.circle),
                child: const Icon(FluentIcons.checkmark_24_regular, size: 64, color: AppTheme.textDark),
              ),
              const SizedBox(height: 28),
              Text('Listing submitted!', textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text(
                "We'll review your item within 24 hours. You'll get a notification once it's live.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight, height: 1.4),
              ),
              const SizedBox(height: 32),
              // What happens next
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WHAT HAPPENS NEXT', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textLight, letterSpacing: 1.0)),
                    const SizedBox(height: 14),
                    _step('1', 'Admin review', 'We check photos, details & quality (24h)'),
                    _step('2', 'Get notified', 'SMS + push when approved or rejected'),
                    _step('3', 'Goes live', 'Renters can book — you earn from day one'),
                  ],
                ),
              ),
              const Spacer(),
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
                  child: Text('BACK TO DASHBOARD', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step(String num, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppTheme.textDark, shape: BoxShape.circle),
            child: Text(num, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
