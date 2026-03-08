import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
          'NOTIFICATIONS',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildDateHeader('TODAY'),
          const SizedBox(height: 16),
          _buildNotificationItem(
            icon: FluentIcons.box_24_regular,
            title: 'Order Delivered!',
            message: 'Your dress "Red Evening Gown" has been delivered successfully. Enjoy your event!',
            time: '2h ago',
            isUnread: true,
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            icon: FluentIcons.money_24_regular,
            title: 'Deposit Refund Initiated',
            message: 'Your safety deposit of AED 100 has been processed for refund.',
            time: '5h ago',
            isUnread: true,
          ),
          const SizedBox(height: 32),
          _buildDateHeader('THIS WEEK'),
          const SizedBox(height: 16),
          _buildNotificationItem(
            icon: FluentIcons.star_24_regular,
            title: 'Rate your rental',
            message: 'How was your experience with "Blue Wrap Dress"? Leave a review.',
            time: '2 days ago',
            isUnread: false,
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            icon: FluentIcons.savings_24_regular,
            title: 'Weekend Offer!',
            message: 'Get 20% off on your next rental. Use code WKND20.',
            time: '4 days ago',
            isUnread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppTheme.textLight,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? AppTheme.primaryLime.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUnread ? AppTheme.primaryLime : Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnread ? Colors.white : const Color(0xFFF6F8FA),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.textDark, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight, height: 1.5),
                ),
              ],
            ),
          ),
          if (isUnread) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
