import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildInfluencersSection(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildCategoryChips(),
              const SizedBox(height: 24),
              _buildSectionTitle('Collection', 'Top Seller v'),
              const SizedBox(height: 16),
              _buildStoreList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HEY ARAFAT! 👋',
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            Text('Explore the best items here..', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight)),
          ],
        ),
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.textLight.withOpacity(0.2))),
              child: const Icon(FluentIcons.alert_24_regular, color: AppTheme.textDark),
            ),
            Positioned(right: 12, top: 12, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
          ],
        ),
      ],
    );
  }

  Widget _buildInfluencersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore Our\nInfluencer',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark, height: 1.2),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildInfluencerAvatar(isYou: true, label: 'You', imgUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop'),
              const SizedBox(width: 16),
              _buildInfluencerAvatar(label: 'Alex H.', imgUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=200&auto=format&fit=crop', isVerified: true),
              const SizedBox(width: 16),
              _buildInfluencerAvatar(label: 'David W.', imgUrl: 'https://images.unsplash.com/photo-1531891437562-4301cf35b7e4?q=80&w=200&auto=format&fit=crop', isVerified: true),
              const SizedBox(width: 16),
              _buildInfluencerAvatar(label: 'Laura J.', imgUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=200&auto=format&fit=crop'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfluencerAvatar({bool isYou = false, required String label, required String imgUrl, bool isVerified = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.primaryLime, width: 2), image: DecorationImage(image: CachedNetworkImageProvider(imgUrl), fit: BoxFit.cover)),
            ),
            if (isYou) Positioned(bottom: -4, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppTheme.textDark, shape: BoxShape.circle), child: const Icon(Icons.add, size: 12, color: Colors.white))),
            if (isVerified) Positioned(bottom: 0, right: -4, child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.verified, size: 16, color: Colors.green))),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: isYou ? FontWeight.w600 : FontWeight.w500, color: AppTheme.textDark)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100), border: Border.all(color: AppTheme.textLight.withOpacity(0.2))),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search items, sellers, or brands',
          hintStyle: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 14),
          border: InputBorder.none,
          icon: const Icon(FluentIcons.search_24_regular, color: AppTheme.textLight),
          suffixIcon: const Icon(FluentIcons.filter_24_regular, color: AppTheme.textDark), // Changed to filter icon based on design
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    // In explorer design: "All", "Top Rated", "Fast Shipping", "Trending Shops"
    final List<String> categories = ['All', 'Top Rated', 'Fast Shipping', 'Trending Shops'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = cat == 'All';
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.darkBackground : Colors.white,
              borderRadius: BorderRadius.circular(100),
              border: isSelected ? null : Border.all(color: AppTheme.textLight.withOpacity(0.2)),
            ),
            child: Text(
              cat,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? Colors.white : AppTheme.textDark),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String actionInfo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
        Text(actionInfo, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
      ],
    );
  }

  Widget _buildStoreList() {
    return Column(
      children: [
        _buildStoreCard('Perfume Shop', '@perfumeshop • Dubai Marina', '4.8 (84 Reviews)', 'https://plus.unsplash.com/premium_photo-1675806655519-75653badeaca?q=80&w=200&auto=format&fit=crop', true, bgType: 'green'),
        const SizedBox(height: 12),
        _buildStoreCard('Tigernu', '@tigernu • Dubai Marina', '4.8 (84 Reviews)', 'https://images.unsplash.com/photo-1547949007-56b9c968f921?q=80&w=200&auto=format&fit=crop', true, bgType: 'red'),
        const SizedBox(height: 12),
        _buildStoreCard('Authentic Shoppe', '@ashoppe • Dubai Marina', '4.8 (84 Reviews)', 'https://images.unsplash.com/photo-1491553895911-0055eca6402d?q=80&w=200&auto=format&fit=crop', true, bgType: 'dark'),
        const SizedBox(height: 12),
        _buildStoreCard('Made with Love', '@madewLove • Dubai Marina', '4.8 (84 Reviews)', 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=200&auto=format&fit=crop', true, bgType: 'gray'),
      ],
    );
  }

  Widget _buildStoreCard(String name, String location, String rating, String imgUrl, bool isVerified, {required String bgType}) {
    Color avatarBgColor;
    switch (bgType) {
      case 'green': avatarBgColor = Colors.teal.shade50; break;
      case 'red': avatarBgColor = Colors.red.shade50; break;
      case 'dark': avatarBgColor = Colors.grey.shade200; break;
      default: avatarBgColor = Colors.grey.shade100;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textLight.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: avatarBgColor, borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: CachedNetworkImage(
                imageUrl: imgUrl,
                width: 48,
                height: 48,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                    if (isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, size: 14, color: Colors.green),
                    ]
                  ],
                ),
                const SizedBox(height: 4),
                Text(location, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(rating, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                  ],
                )
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryLime,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: Text(
              'Visit Store',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
