import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/services/support_service.dart';

/// Manage users you've blocked.
class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({Key? key}) : super(key: key);

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  late Future<List<Map<String, dynamic>>> _blockedFuture;

  @override
  void initState() {
    super.initState();
    _blockedFuture = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    // In a real app, fetch the user details for each blocked id.
    // For mock, fabricate a list.
    final ids = await SupportService().blockedUsers();
    return ids.asMap().entries.map((entry) {
      return {
        'id': entry.value,
        'name': 'User ${entry.key + 1}',
        'avatar': 'https://i.pravatar.cc/150?img=${entry.key + 11}',
        'blocked_at': DateTime.now().subtract(Duration(days: entry.key + 1)).toIso8601String(),
      };
    }).toList();
  }

  Future<void> _unblock(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Unblock user?', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Text('They\'ll be able to see your listings and contact you again.', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('CANCEL', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.textLight))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('UNBLOCK', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppTheme.textDark))),
        ],
      ),
    );
    if (confirmed == true) {
      await SupportService().unblockUser(userId);
      setState(() => _blockedFuture = _load());
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
        title: Text('BLOCKED USERS', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _blockedFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryLime));
          }
          final list = snap.data ?? const [];
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLime.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(FluentIcons.people_24_regular, size: 40, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 16),
                    Text('No blocked users', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                    const SizedBox(height: 6),
                    Text(
                      'Users you block won\'t appear here. You can unblock them anytime to restore access.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, height: 1.4),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final u = list[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.primaryLime,
                      backgroundImage: CachedNetworkImageProvider(u['avatar'] as String),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u['name'] as String, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                          const SizedBox(height: 2),
                          Text('Blocked', style: GoogleFonts.inter(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _unblock(u['id'] as String),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textDark,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100), side: BorderSide(color: AppTheme.textDark.withOpacity(0.3))),
                      ),
                      child: Text('UNBLOCK', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
