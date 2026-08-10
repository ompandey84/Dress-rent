import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/category_listing_screen.dart';
import 'package:dress_app/screens/reels_screen.dart';
import 'package:dress_app/services/mock_data_service.dart';
import 'package:dress_app/models/product.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({Key? key}) : super(key: key);

  static const _collections = [
    {
      'id': 'wedding-guest',
      'title': 'Wedding Guest Edit',
      'subtitle': 'Stand out without outshining the bride',
      'image': 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800',
      'tagline': '12 outfits • 6 stores',
    },
    {
      'id': 'cocktail-hour',
      'title': 'Cocktail Hour',
      'subtitle': 'After-work drinks done right',
      'image': 'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=800',
      'tagline': '8 outfits • 5 stores',
    },
    {
      'id': 'festive-bridal',
      'title': 'Festive & Bridal',
      'subtitle': 'Diwali, Eid, and celebration-ready',
      'image': 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800',
      'tagline': '15 outfits • 9 stores',
    },
    {
      'id': 'boardroom',
      'title': 'Boardroom to Ballroom',
      'subtitle': 'Day-to-night versatility',
      'image': 'https://images.unsplash.com/photo-1485518882345-15568b007407?w=800',
      'tagline': '10 outfits • 4 stores',
    },
    {
      'id': 'beach',
      'title': 'Beach Vacation',
      'subtitle': 'Resort-ready glamour',
      'image': 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=800',
      'tagline': '7 outfits • 3 stores',
    },
    {
      'id': 'saree-edit',
      'title': 'The Saree Edit',
      'subtitle': 'Heritage meets modern silhouettes',
      'image': 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800',
      'tagline': '14 outfits • 8 stores',
    },
  ];

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
          'CURATED COLLECTIONS',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.5),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: _collections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, i) {
          final c = _collections[i];
          return _buildCollectionCard(context, c);
        },
      ),
    );
  }

  Widget _buildCollectionCard(BuildContext context, Map<String, String> c) {
    return GestureDetector(
      onTap: () {
        // For demo, route to a category listing
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryListingScreen(categoryName: c['title']!),
          ),
        );
      },
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: c['image']!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: Colors.grey[200]),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLime,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'CURATED',
                        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: 1.0),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c['title']!,
                      style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c['subtitle']!,
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.9), height: 1.3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c['tagline']!,
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reels tab — vertical feed of outfit videos (lightweight home of discovery)
class ReelsTabPreview extends StatelessWidget {
  const ReelsTabPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use mock products with placeholder reels
    final products = MockDataService.mockProducts;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: products.length,
      itemBuilder: (context, i) {
        final p = products[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReelsScreen(),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 9 / 16,
                      child: CachedNetworkImage(
                        imageUrl: p.images.isNotEmpty ? p.images.first : 'https://placehold.co/600x800',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(FluentIcons.play_24_regular, color: Colors.white, size: 18),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${p.storeName} • ₹ ${p.rentalPricePerDay.toStringAsFixed(0)}/day',
                            style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
