import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';

class LegalContentScreen extends StatelessWidget {
  final String title;
  const LegalContentScreen({super.key, required this.title});

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
          title.toUpperCase(),
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Updated: March 2026',
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            _buildSection('1. Introduction', 'Welcome to our Dress Rental App. These terms and conditions outline the rules and regulations for the use of our services. By accessing this app, we assume you accept these terms and conditions. Do not continue to use the app if you do not agree to all of the terms and conditions stated on this page.'),
            _buildSection('2. Rental Agreement', 'When you rent a dress, you are entering into a binding agreement to return the item in its original condition within the specified rental period. Late returns will incur additional daily fees.'),
            _buildSection('3. Care and Insurance', 'Minor wear and tear is covered by our standard insurance. However, significant damage, loss, or theft of the item will result in a fee up to the full retail replacement value of the dress.'),
            _buildSection('4. Cancellations', 'Cancellations made 48 hours before the rental start date are eligible for a full refund. Cancellations made within 48 hours will incur a 20% processing fee.'),
            _buildSection('5. Privacy Policy', 'We value your privacy and handle your data in accordance with our Privacy Policy. We do not share your personal information with third parties without your explicit consent.'),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Version 1.0.4 (UAE)',
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppTheme.textDark.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}
