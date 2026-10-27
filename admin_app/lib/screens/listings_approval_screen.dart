import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme.dart';

/// Review and approve/reject pending listings.
class ListingsApprovalScreen extends StatefulWidget {
  const ListingsApprovalScreen({super.key});
  @override
  State<ListingsApprovalScreen> createState() => _ListingsApprovalScreenState();
}

class _ListingsApprovalScreenState extends State<ListingsApprovalScreen> {
  String _filter = 'pending';

  final _mockListings = [
    {
      'id': 'L-1001',
      'title': 'Sabyasachi Heritage Crimson Zardozi Lehenga',
      'lender': 'The Luxe Vault (Bandra, Mumbai)',
      'price': 4800,
      'category': 'Bridal',
      'photos': [
        'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?q=80&w=400',
        'https://images.unsplash.com/photo-1610030469983-98e550d6193c?q=80&w=400',
      ],
      'status': 'pending',
      'submitted': '45m ago',
      'reason': null,
    },
    {
      'id': 'L-1002',
      'title': 'Manish Malhotra Emerald Velvet Evening Ballgown',
      'lender': 'Khaab Haute Couture (South Delhi)',
      'price': 2400,
      'category': 'Party',
      'photos': [
        'https://images.unsplash.com/photo-1566174053879-31528523f8ae?q=80&w=400',
        'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=400',
      ],
      'status': 'pending',
      'submitted': '2h ago',
      'reason': null,
    },
    {
      'id': 'L-1003',
      'title': 'Tarun Tahiliani Blush Draped Concept Saree',
      'lender': 'Aza Fashions Partner (Bengaluru)',
      'price': 1850,
      'category': 'Ethnic',
      'photos': [
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?q=80&w=400',
      ],
      'status': 'pending',
      'submitted': '4h ago',
      'reason': null,
    },
    {
      'id': 'L-1004',
      'title': 'Papa Don\'t Preach Lilac Embellished Jumpsuit',
      'lender': 'Chic Runway (New Delhi)',
      'price': 1400,
      'category': 'Party',
      'photos': [
        'https://images.unsplash.com/photo-1509631179647-0177331693ae?q=80&w=400',
      ],
      'status': 'pending',
      'submitted': '6h ago',
      'reason': null,
    },
    {
      'id': 'L-0998',
      'title': 'Raw Mango Rani Pink Chanderi Silk Anarkali',
      'lender': 'Virasat Weaves (Jaipur)',
      'price': 1150,
      'category': 'Ethnic',
      'photos': [
        'https://images.unsplash.com/photo-1610030469983-98e550d6193c?q=80&w=400',
      ],
      'status': 'approved',
      'submitted': '1d ago',
      'reason': null,
    },
    {
      'id': 'L-0997',
      'title': 'Midnight Obsidian Crystal Mermaid Gown',
      'lender': 'The Wardrobe Co. (Bengaluru)',
      'price': 1250,
      'category': 'Formal',
      'photos': [
        'https://images.unsplash.com/photo-1566174053879-31528523f8ae?q=80&w=400',
      ],
      'status': 'approved',
      'submitted': '1d ago',
      'reason': null,
    },
    {
      'id': 'L-0995',
      'title': 'Vintage Silk Kurta Set',
      'lender': 'Pooja Verma (Indore)',
      'price': 900,
      'category': 'Ethnic',
      'photos': [
        'https://images.unsplash.com/photo-1610030469983-98e550d6193c?q=80&w=400',
      ],
      'status': 'rejected',
      'submitted': '2d ago',
      'reason': 'Low photo resolution. Please upload high-resolution daylight photos showing hem and embroidery details.',
    },
  ];

  List<Map<String, dynamic>> get _filtered =>
      _mockListings.where((l) => l['status'] == _filter).toList();

  void _approve(Map<String, dynamic> l) {
    setState(() {
      l['status'] = 'approved';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${l['title']} approved & live')),
    );
  }

  void _reject(Map<String, dynamic> l) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Reject listing', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reason will be sent to the lender.', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
              const SizedBox(height: 12),
              TextField(controller: controller, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Photos blurry, item condition unclear...')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('CANCEL', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.textLight))),
            TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim().isEmpty ? 'Did not meet guidelines' : controller.text.trim()),
                child: Text('REJECT', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppTheme.danger))),
          ],
        );
      },
    );
    if (reason != null) {
      setState(() {
        l['status'] = 'rejected';
        l['reason'] = reason;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rejected. Lender notified.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('LISTINGS', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5)),
              _filterChips(),
            ],
          ),
          const SizedBox(height: 4),
          Text('${list.length} ${_filter} listings', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
          const SizedBox(height: 24),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text('No $_filter listings', style: GoogleFonts.inter(color: AppTheme.textLight)),
                  )
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _buildCard(list[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChips() {
    return Row(
      children: ['pending', 'approved', 'rejected'].map((f) {
        final isSelected = _filter == f;
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.textDark : Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppTheme.textLight.withOpacity(0.3)),
              ),
              child: Text(
                f.toUpperCase(),
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : AppTheme.textDark, letterSpacing: 0.5),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCard(Map<String, dynamic> l) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photos
          Row(
            children: ((l['photos'] as List).cast<String>()).take(2).map<Widget>((url) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(imageUrl: url, width: 80, height: 100, fit: BoxFit.cover),
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l['title'] as String, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                const SizedBox(height: 2),
                Text('by ${l['lender']} • ${l['category']} • ₹${l['price']}/day', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 12, color: AppTheme.textLight),
                    const SizedBox(width: 4),
                    Text(l['submitted'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight)),
                    const SizedBox(width: 12),
                    Text('ID: ${l['id']}', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w700)),
                  ],
                ),
                if (l['reason'] != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 12, color: AppTheme.danger),
                        const SizedBox(width: 4),
                        Expanded(child: Text('Rejected: ${l['reason']}', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.danger))),
                      ],
                    ),
                  ),
                ],
                if (l['status'] == 'pending') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _reject(l),
                        icon: const Icon(Icons.close, size: 14, color: AppTheme.danger),
                        label: Text('REJECT', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.danger, letterSpacing: 0.5)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.danger, width: 1.5),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _approve(l),
                        icon: const Icon(Icons.check, size: 14, color: Colors.white),
                        label: Text('APPROVE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.textDark,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
