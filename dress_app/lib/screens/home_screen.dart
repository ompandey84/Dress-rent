import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/product_details_screen.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/widgets/favorite_button.dart';
import 'package:dress_app/services/mock_data_service.dart';
import 'package:dress_app/screens/notifications_screen.dart';
import 'package:dress_app/screens/search_results_screen.dart';
import 'package:dress_app/screens/category_listing_screen.dart';
import 'package:dress_app/screens/filters_bottom_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    final products = MockDataService.mockProducts;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE4F4FA), // Very light pale blue at top
              Color(0xFFF7F9FB), // Light background
              Color(0xFFF7F9FB),
            ],
            stops: [0.0, 0.2, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, user.name, user.avatarUrl),
                    const SizedBox(height: 24),
                    _buildInfluencersSection(),
                    _buildSearchBar(context),
                    const SizedBox(height: 24),
                    _buildCategoryChips(context),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'New Arrived'),
                    const SizedBox(height: 16),
                    _buildProductGrid(context, products),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName, String? avatarUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'HEY ${userName.toUpperCase()}!',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('👋', style: TextStyle(fontSize: 24)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Explore the best items here..',
              style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textLight),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
              },
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      FluentIcons.alert_24_regular,
                      color: AppTheme.textDark,
                      size: 22,
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    avatarUrl != null && avatarUrl.isNotEmpty ? avatarUrl : 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=200&auto=format&fit=crop',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfluencersSection() {
    return Row(
      children: [
        Text(
          'Explore Our\nInfluencer',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
            height: 1.2,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height:
                110, // Increased height to prevent RenderFlex overflow of text labels
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildInfluencerAvatar(
                  isYou: true,
                  label: 'You',
                  imgUrl:
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop',
                ),
                const SizedBox(width: 16),
                _buildInfluencerAvatar(
                  label: 'Alex H.',
                  imgUrl:
                      'https://images.unsplash.com/photo-1556821840-3a63f95609a7?q=80&w=200&auto=format&fit=crop',
                  isVerified: true,
                ),
                const SizedBox(width: 16),
                _buildInfluencerAvatar(
                  label: 'David W.',
                  imgUrl:
                      'https://images.unsplash.com/photo-1531891437562-4301cf35b7e4?q=80&w=200&auto=format&fit=crop',
                  isVerified: true,
                ),
                const SizedBox(width: 16),
                _buildInfluencerAvatar(
                  label: 'L.',
                  imgUrl:
                      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=200&auto=format&fit=crop',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfluencerAvatar({
    bool isYou = false,
    required String label,
    required String imgUrl,
    bool isVerified = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(2.5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF2E8A99), Color(0xFFECA04F)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(imgUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            if (isYou)
              Positioned(
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.textDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.add, size: 10, color: Colors.white),
                ),
              ),
            if (isVerified)
              Positioned(
                bottom: 0,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    size: 14,
                    color: Colors.green,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isYou ? FontWeight.w700 : FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SearchResultsScreen(query: value)),
            );
          }
        },
        decoration: InputDecoration(
          hintText: 'Search items, sellers, or brands',
          hintStyle: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 14),
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Image.asset(
              'assets/images/search_icon.png',
              width: 20,
              height: 20,
              color: AppTheme.textDark,
            ),
          ),
          suffixIcon: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const FiltersBottomSheet(),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 14.0, left: 14.0),
              child: Image.asset(
                'assets/images/filter.png',
                width: 20,
                height: 20,
                color: AppTheme.textDark,
              ),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryListingScreen(categoryName: 'All')));
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'See All',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                FluentIcons.chevron_down_24_regular,
                size: 16,
                color: AppTheme.textDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    final List<String> categories = [
      'All',
      'New Arrived',
      'Popular',
      'Offer',
      'Verified',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = cat == 'All';
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryListingScreen(categoryName: cat)));
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ), 
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.textDark
                    : Colors.white, 
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                cat,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.textLight,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, List<dynamic> products) {
    if (products.isEmpty) {
      return const Center(child: Text("No products found"));
    }

    final leftColumn = <dynamic>[];
    final rightColumn = <dynamic>[];
    for (int i = 0; i < products.length; i++) {
      if (i % 2 == 0) {
        leftColumn.add(products[i]);
      } else {
        rightColumn.add(products[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftColumn.map((product) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildProductCard(
                context,
                product,
                260,
              ),
            )).toList(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: rightColumn.map((product) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildProductCard(
                context,
                product,
                180,
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    dynamic product, // keeping dynamic or Product. Wait, we know it's a Product from AppState
    double height,
  ) {
    String title = product.name;
    String location = product.location;
    String price = 'AED${product.price.toStringAsFixed(2)}';
    String rating = product.rating.toString();
    String imgUrl = product.images.isNotEmpty ? product.images.first : '';
    bool isVerified = product.isVerifiedStore;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipPath(
                clipper: const ImageCutoutClipper(),
                child: CachedNetworkImage(
                  imageUrl: imgUrl,
                  height: height,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(color: Colors.grey[200]),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: FavoriteButton(productId: product.id),
              ),
              // Price Pill overlapping the clipped image area
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLime,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    price,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  location,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, size: 14, color: Colors.green),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Text(
                    rating,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ImageCutoutClipper extends CustomClipper<Path> {
  const ImageCutoutClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    const double r = 24.0;
    const double cvx = 16.0;
    const double ir = 14.0;
    const double cw = 124.0;
    const double ch = 54.0;

    path.moveTo(r, 0);
    path.lineTo(size.width - r, 0);
    path.arcToPoint(
      Offset(size.width, r),
      radius: const Radius.circular(r),
      clockwise: true,
    );

    path.lineTo(size.width, size.height - ch - cvx);
    path.arcToPoint(
      Offset(size.width - cvx, size.height - ch),
      radius: const Radius.circular(cvx),
      clockwise: true,
    );

    path.lineTo(size.width - cw + ir, size.height - ch);
    path.arcToPoint(
      Offset(size.width - cw, size.height - ch + ir),
      radius: const Radius.circular(ir),
      clockwise: false,
    );

    path.lineTo(size.width - cw, size.height - cvx);
    path.arcToPoint(
      Offset(size.width - cw - cvx, size.height),
      radius: const Radius.circular(cvx),
      clockwise: true,
    );

    path.lineTo(r, size.height);
    path.arcToPoint(
      Offset(0, size.height - r),
      radius: const Radius.circular(r),
      clockwise: true,
    );

    path.lineTo(0, r);
    path.arcToPoint(
      Offset(r, 0),
      radius: const Radius.circular(r),
      clockwise: true,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
