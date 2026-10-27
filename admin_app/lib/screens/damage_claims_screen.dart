import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme.dart';

/// Review damage claims — approve, partially approve, or reject.
class DamageClaimsScreen extends StatelessWidget {
  const DamageClaimsScreen({super.key});

  final _claims = const [
    {
      'id': 'C-501',
      'order': 'ORD-9821',
      'item': 'Raw Mango Rani Pink Chanderi Anarkali',
      'renter': 'Sneha Reddy (Hyderabad)',
      'lender': 'Virasat Weaves (Jaipur)',
      'type': 'Stain',
      'amount_claimed': 1200.0,
      'deposit': 2000.0,
      'evidence': [
        'https://images.unsplash.com/photo-1610030469983-98e550d6193c?q=80&w=400',
        'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?q=80&w=400',
      ],
      'status': 'open',
      'notes': 'Light haldi mark along the inner border of organza dupatta. Requires organic dry-cleaning treatment.',
    },
    {
      'id': 'C-499',
      'order': 'ORD-9788',
      'item': 'Midnight Obsidian Crystal Mermaid Gown',
      'renter': 'Tara Mehta (Mumbai)',
      'lender': 'The Wardrobe Co. (Bengaluru)',
      'type': 'Zip Seam',
      'amount_claimed': 650.0,
      'deposit': 2000.0,
      'evidence': ['https://images.unsplash.com/photo-1566174053879-31528523f8ae?q=80&w=400'],
      'status': 'in_review',
      'notes': 'Concealed zipper slider stuck near waist seam; needs slider replacement by master tailor.',
    },
    {
      'id': 'C-495',
      'order': 'ORD-9750',
      'item': 'Tarun Tahiliani Concept Saree',
      'renter': 'Ananya Iyer (Chennai)',
      'lender': 'Aza Fashions Partner (Bengaluru)',
      'type': 'Bead Loss',
      'amount_claimed': 800.0,
      'deposit': 2500.0,
      'evidence': ['https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?q=80&w=400'],
      'status': 'resolved',
      'notes': 'Minor Swarovski bead loosening on pallu fringe. Fixed in-house; ₹800 reimbursed to lender.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DAMAGE CLAIMS', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text('${_claims.length} open claims', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _claims.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _claimCard(_claims[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _claimCard(Map<String, dynamic> c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(c['type'] as String, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.danger, letterSpacing: 0.5)),
              ),
              const SizedBox(width: 8),
              Text('${c['id']} • ${c['order']}', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(c['item'] as String, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          const SizedBox(height: 4),
          Text('Lender: ${c['lender']}  •  Renter: ${c['renter']}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
          const SizedBox(height: 12),
          // Evidence thumbnails
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ((c['evidence'] as List).cast<String>()).map<Widget>((url) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(imageUrl: url, width: 80, height: 80, fit: BoxFit.cover),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Text(c['notes'] as String, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark, height: 1.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Claimed', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight, fontWeight: FontWeight.w700)),
                      Text('₹${(c['amount_claimed'] as double).toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.danger)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Deposit', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight, fontWeight: FontWeight.w700)),
                      Text('₹${(c['deposit'] as double).toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.danger, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Text('REJECT', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.danger, letterSpacing: 0.5)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.warning, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Text('PARTIAL', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.warning, letterSpacing: 0.5)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Text('APPROVE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
