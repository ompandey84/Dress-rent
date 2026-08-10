import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/message_list_screen.dart';
import 'package:dress_app/screens/support/support_ticket_screen.dart';
import 'package:dress_app/screens/support/blocked_users_screen.dart';

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

            // Quick actions
            Text(
              'Support options',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
            ),
            const SizedBox(height: 12),
            _buildSupportOption(
              icon: FluentIcons.chat_24_regular,
              title: 'Raise a ticket',
              subtitle: 'Get a response within 4 hours',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SupportTicketScreen()),
                );
              },
            ),
            _buildSupportOption(
              icon: FluentIcons.people_24_regular,
              title: 'Blocked users',
              subtitle: 'Manage who can contact you',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BlockedUsersScreen()),
                );
              },
            ),
            _buildSupportOption(
              icon: FluentIcons.shield_24_regular,
              title: 'Safety center',
              subtitle: 'Verification, scam alerts, meetup tips',
              onTap: () => _showSafetyCenter(context),
            ),
            const SizedBox(height: 24),

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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MessageListScreen()));
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _openEmail(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.textDark, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: Text(
                  'EMAIL US',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark),
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

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppTheme.primaryLime, shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: AppTheme.textDark),
        ),
        title: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight)),
        trailing: const Icon(FluentIcons.chevron_right_24_regular, size: 18, color: AppTheme.textLight),
      ),
    );
  }
}

Future<void> _openEmail(BuildContext context) async {
  final uri = Uri(
    scheme: 'mailto',
    path: 'support@dressapp.in',
    query: 'subject=Dress Support Request',
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open email app. Mail us at support@dressapp.in')),
    );
  }
}

Future<void> _showSafetyCenter(BuildContext context) async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stay safe on Dress',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
            const SizedBox(height: 8),
            Text(
              '• Always check lender ratings and reviews\n'
              '• Never share OTPs or banking info in chat\n'
              '• All payments go through Cashfree — never to a personal account\n'
              '• Report suspicious behavior — our team reviews every report within 24h',
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppTheme.textDark),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}
