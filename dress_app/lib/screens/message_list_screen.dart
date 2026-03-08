import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/ai_chat_screen.dart';

class MessageListScreen extends StatelessWidget {
  const MessageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'MESSAGES',
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(FluentIcons.search_24_regular, color: AppTheme.textDark),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16, bottom: 100),
        child: Column(
          children: [
            // AI Stylist special chat
            _buildChatTile(
              context,
              name: 'AI Stylist Assistant',
              lastMessage: 'How can I help you find the perfect dress today?',
              time: 'Just now',
              imageUrl: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?q=80&w=200&auto=format&fit=crop', // Robot/AI themed image
              unreadCount: 1,
              isAI: true,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Divider(),
            ),
            // Vendor / other user chats
            _buildChatTile(
              context,
              name: 'Sarah\'s Boutique',
              lastMessage: 'Yes, the red evening gown is available this weekend.',
              time: '2h ago',
              imageUrl: 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?q=80&w=200&auto=format&fit=crop',
              unreadCount: 0,
            ),
            _buildChatTile(
              context,
              name: 'Emily Davis',
              lastMessage: 'Thanks for returning the dress in perfect condition!',
              time: 'Yesterday',
              imageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=200&auto=format&fit=crop',
              unreadCount: 0,
            ),
            _buildChatTile(
              context,
              name: 'Luxury Threads Dubai',
              lastMessage: 'Your deposit has been refunded. It should reflect in 2-3 days.',
              time: 'Mon',
              imageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050?q=80&w=200&auto=format&fit=crop',
              unreadCount: 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(
    BuildContext context, {
    required String name,
    required String lastMessage,
    required String time,
    required String imageUrl,
    required int unreadCount,
    bool isAI = false,
  }) {
    return InkWell(
      onTap: () {
        if (isAI) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatScreen()));
        } else {
          // Open normal chat - to be implemented if needed
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User chat coming soon')));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(imageUrl),
                      fit: BoxFit.cover,
                    ),
                    border: isAI ? Border.all(color: AppTheme.primaryLime, width: 2) : null,
                  ),
                ),
                if (isAI)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryLime,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(FluentIcons.bot_24_filled, size: 12, color: AppTheme.textDark),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: unreadCount > 0 ? FontWeight.w800 : FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        time,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: unreadCount > 0 ? AppTheme.primaryLime : AppTheme.textLight,
                          fontWeight: unreadCount > 0 ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: unreadCount > 0 ? AppTheme.textDark : AppTheme.textLight,
                            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryLime,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
