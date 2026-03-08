import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';

class VendorNotificationsScreen extends StatefulWidget {
  const VendorNotificationsScreen({super.key});

  @override
  State<VendorNotificationsScreen> createState() => _VendorNotificationsScreenState();
}

class _VendorNotificationsScreenState extends State<VendorNotificationsScreen> {
  bool allRead = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NOTIFICATIONS',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => allRead = true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All notifications marked as read.', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  backgroundColor: AppTheme.textDark,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Mark All', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF2E8A99))),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Today
          Text('Today', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textLight)),
          const SizedBox(height: 12),
          _buildNotificationCard(
            'New Booking',
            'Arafat Khan booked Premium Hoodie for Mar 20-23. Accept or decline this booking.',
            '2 minutes ago',
            FluentIcons.cart_24_regular,
            Colors.green,
            isNew: !allRead,
          ),
          _buildNotificationCard(
            'Return Reminder',
            'Denim Jacket (BK-2840) return is due tomorrow. Please prepare for inspection.',
            '1 hour ago',
            FluentIcons.arrow_undo_24_regular,
            Colors.orange,
            isNew: !allRead,
          ),
          _buildNotificationCard(
            'Payment Processed',
            '₹2,450 has been credited to your bank account for booking BK-2838.',
            '3 hours ago',
            FluentIcons.money_24_regular,
            const Color(0xFF2E8A99),
            isNew: !allRead,
          ),

          const SizedBox(height: 24),
          Text('Yesterday', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textLight)),
          const SizedBox(height: 12),
          _buildNotificationCard(
            'Damage Claim Alert',
            'A damage claim has been filed for Casual T-Shirt (BK-2837). Review and respond.',
            'Yesterday, 4:30 PM',
            FluentIcons.warning_24_regular,
            const Color(0xFFE53935),
          ),
          _buildNotificationCard(
            'New Review',
            'David Lee left a 5-star review for Casual T-Shirt. Tap to respond.',
            'Yesterday, 2:15 PM',
            FluentIcons.star_24_regular,
            Colors.amber,
          ),
          _buildNotificationCard(
            'Payment Processed',
            '₹1,800 has been credited to your bank account for booking BK-2836.',
            'Yesterday, 10:00 AM',
            FluentIcons.money_24_regular,
            const Color(0xFF2E8A99),
          ),

          const SizedBox(height: 24),
          Text('Earlier', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textLight)),
          const SizedBox(height: 12),
          _buildNotificationCard(
            'New Booking',
            'Sara Ahmed booked Denim Jacket for Mar 18-20.',
            '2 days ago',
            FluentIcons.cart_24_regular,
            Colors.green,
          ),
          _buildNotificationCard(
            'Listing Approved',
            'Your new listing "Leather Jacket" has been approved and is now live.',
            '3 days ago',
            FluentIcons.checkmark_circle_24_regular,
            Colors.green,
          ),
          _buildNotificationCard(
            'Return Completed',
            'Summer Dress (BK-2835) has been inspected and returned successfully.',
            '4 days ago',
            FluentIcons.arrow_undo_24_regular,
            const Color(0xFF2E8A99),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(String title, String description, String time, IconData icon, Color color, {bool isNew = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNew ? Colors.white : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNew ? color.withOpacity(0.2) : AppTheme.textLight.withOpacity(0.1),
        ),
        boxShadow: isNew
            ? [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
            : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                    ),
                    if (isNew)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(time, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight.withOpacity(0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
