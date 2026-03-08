import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'HELP & SUPPORT',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryLime.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryLime,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(FluentIcons.chat_help_24_regular, color: AppTheme.textDark, size: 32),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How can we help?',
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chat with our AI assistant or drop us an email.',
                          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
            ),
            const SizedBox(height: 16),
            
            _buildFaqItem(
              'How does renting work?',
              'Select a dress, choose your rental dates (usually 4-8 days), wear it, and return it using the prepaid shipping label provided.',
            ),
            _buildFaqItem(
              'Do I need to clean the dress?',
              'No, we handle all the dry cleaning! Just return it in the provided bag.',
            ),
            _buildFaqItem(
              'What if the dress doesn\'t fit?',
              'We offer a Fit Guarantee. If it doesn\'t fit, contact us within 24 hours of delivery and we\'ll send a replacement style or size if available, or issue a refund (minus shipping).',
            ),
            _buildFaqItem(
              'What if I damage the dress?',
              'Minor wear and tear is covered by our standard insurance (included). Significant damage may incur an additional fee.',
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Connect to support or open chat
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: Text(
                  'CONTACT US',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          question,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textDark),
        ),
        iconColor: AppTheme.primaryLime,
        collapsedIconColor: AppTheme.textLight,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              answer,
              style: GoogleFonts.inter(fontSize: 14, height: 1.5, color: AppTheme.textLight),
            ),
          ),
        ],
      ),
    );
  }
}
