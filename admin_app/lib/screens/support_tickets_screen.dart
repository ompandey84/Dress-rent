import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../theme.dart';

class SupportTicketsScreen extends StatelessWidget {
  const SupportTicketsScreen({super.key});

  final _tickets = const [
    {
      'id': 'T-9005',
      'user': 'The Luxe Vault (Lender)',
      'category': 'payout',
      'subject': 'Payout batch credit status for Diwali bookings',
      'priority': 'normal',
      'status': 'open',
      'age': '35m',
    },
    {
      'id': 'T-9004',
      'user': 'Kavya Singhania (Renter)',
      'category': 'booking',
      'subject': 'Can I extend rental by 2 days for destination wedding?',
      'priority': 'high',
      'status': 'in_progress',
      'age': '1h',
    },
    {
      'id': 'T-9003',
      'user': 'Rahul Varma (Renter)',
      'category': 'delivery',
      'subject': 'Delivery address updated to hotel in Udaipur',
      'priority': 'high',
      'status': 'open',
      'age': '2h',
    },
    {
      'id': 'T-9002',
      'user': 'Sneha Reddy (Renter)',
      'category': 'damage',
      'subject': 'Security deposit adjustment for #ORD-9821 haldi stain',
      'priority': 'normal',
      'status': 'in_progress',
      'age': '4h',
    },
    {
      'id': 'T-8998',
      'user': 'Aisha Sharma (Renter)',
      'category': 'deposit',
      'subject': 'Deposit ₹2,500 unreserved to wallet successfully',
      'priority': 'low',
      'status': 'resolved',
      'age': '1d',
    },
    {
      'id': 'T-8995',
      'user': 'Heritage Loom Studio (Lender)',
      'category': 'listing',
      'subject': 'Request to update rental price on Sabyasachi bridal set',
      'priority': 'low',
      'status': 'resolved',
      'age': '2d',
    },
  ];

  Color _priorityColor(String p) {
    switch (p) {
      case 'high': return AppTheme.danger;
      case 'normal': return AppTheme.info;
      case 'low': return AppTheme.textLight;
      default: return AppTheme.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SUPPORT TICKETS', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text('${_tickets.where((t) => t['status'] == 'open').length} open • 1 urgent', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.danger, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _tickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final t = _tickets[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 50,
                        decoration: BoxDecoration(color: _priorityColor(t['priority'] as String), borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('${t['id']} • ${t['user']}', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w700)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(color: _priorityColor(t['priority'] as String).withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                                  child: Text((t['priority'] as String).toUpperCase(), style: GoogleFonts.inter(fontSize: 9, color: _priorityColor(t['priority'] as String), fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(4)),
                                  child: Text((t['category'] as String).toUpperCase(), style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textDark, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(t['subject'] as String, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                          ],
                        ),
                      ),
                      Text(t['age'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (t['status'] == 'open' ? AppTheme.danger : t['status'] == 'in_progress' ? AppTheme.warning : AppTheme.success).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          (t['status'] as String).replaceAll('_', ' ').toUpperCase(),
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: t['status'] == 'open' ? AppTheme.danger : t['status'] == 'in_progress' ? AppTheme.warning : AppTheme.success, letterSpacing: 0.5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(FluentIcons.chevron_right_24_regular, size: 18, color: AppTheme.textLight),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
