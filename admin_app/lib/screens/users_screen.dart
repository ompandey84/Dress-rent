import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../theme.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _filter = 'all';
  final _search = TextEditingController();

  final _mockUsers = [
    {'name': 'Ananya Sharma', 'role': 'lender', 'verified': true, 'bookings': 23, 'rating': 4.8, 'avatar': 'https://i.pravatar.cc/150?img=1'},
    {'name': 'Priya Kapoor', 'role': 'lender', 'verified': true, 'bookings': 41, 'rating': 4.9, 'avatar': 'https://i.pravatar.cc/150?img=5'},
    {'name': 'Sneha Reddy', 'role': 'renter', 'verified': true, 'bookings': 12, 'rating': 4.7, 'avatar': 'https://i.pravatar.cc/150?img=10'},
    {'name': 'Tara Mehta', 'role': 'renter', 'verified': false, 'bookings': 3, 'rating': 4.2, 'avatar': 'https://i.pravatar.cc/150?img=20'},
    {'name': 'Aarav Patel', 'role': 'both', 'verified': true, 'bookings': 18, 'rating': 4.6, 'avatar': 'https://i.pravatar.cc/150?img=12'},
    {'name': 'Kavya Iyer', 'role': 'lender', 'verified': false, 'bookings': 0, 'rating': 0.0, 'avatar': 'https://i.pravatar.cc/150?img=25'},
  ];

  @override
  Widget build(BuildContext context) {
    final list = _mockUsers.where((u) => _filter == 'all' || u['role'] == _filter).toList();
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('USERS', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, or ID',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight),
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.textLight),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ...['all', 'renter', 'lender', 'both'].map((f) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _filter == f ? AppTheme.textDark : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppTheme.textLight.withOpacity(0.3)),
                    ),
                    child: Text(f.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: _filter == f ? Colors.white : AppTheme.textDark, letterSpacing: 0.5)),
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final u = list[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primaryLime,
                        backgroundImage: CachedNetworkImageProvider(u['avatar'] as String),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(u['name'] as String, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                                if (u['verified'] == true) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, size: 14, color: AppTheme.success),
                                ],
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(4)),
                                  child: Text((u['role'] as String).toUpperCase(), style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textDark, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text('${u['bookings']} bookings  •  ⭐ ${(u['rating'] as double).toStringAsFixed(1)}', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: AppTheme.textLight),
                        onPressed: () {},
                      ),
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
