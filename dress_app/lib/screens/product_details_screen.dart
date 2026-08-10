import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/product.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/services/wishlist_service.dart';
import 'package:dress_app/services/mock_data_service.dart';
import 'package:dress_app/screens/select_dates_screen.dart';
import 'package:dress_app/screens/store_detail_screen.dart';
import 'package:dress_app/screens/chat_screen.dart';
import 'package:dress_app/models/chat_session.dart';
import 'package:dress_app/screens/category_listing_screen.dart';
import 'package:dress_app/models/cart_item.dart';
import 'package:dress_app/screens/size_guide_bottom_sheet.dart';
import 'package:dress_app/widgets/product_card.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? selectedSize;
  String? selectedColor;
  bool isDescriptionExpanded = false;
  int _currentImageIndex = 0;
  final _pageController = PageController();
  List<Product> _similarItems = [];
  bool _loadingSimilar = true;

  @override
  void initState() {
    super.initState();
    if (widget.product.sizes.isNotEmpty) selectedSize = widget.product.sizes.first;
    if (widget.product.colors.isNotEmpty) selectedColor = widget.product.colors.first;
    _loadSimilar();
  }

  Future<void> _loadSimilar() async {
    try {
      final all = MockDataService.mockProducts;
      setState(() {
        _similarItems = all
            .where((p) =>
                p.id != widget.product.id &&
                (p.category.toLowerCase() == widget.product.category.toLowerCase() ||
                    p.storeName == widget.product.storeName))
            .take(6)
            .toList();
        _loadingSimilar = false;
      });
    } catch (e) {
      setState(() => _loadingSimilar = false);
    }
  }

  void _openImageFullscreen(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PhotoViewGallery.builder(
            itemCount: widget.product.images.length,
            pageController: PageController(initialPage: initialIndex),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(widget.product.images[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
              );
            },
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleAndPrice(),
                      const SizedBox(height: 12),
                      _buildRatingRow(),
                      const SizedBox(height: 24),
                      _buildLenderCard(),
                      const SizedBox(height: 24),
                      _buildDescription(),
                      const SizedBox(height: 24),
                      _buildSizeSelector(),
                      const SizedBox(height: 24),
                      _buildColorSelector(),
                      const SizedBox(height: 24),
                      _buildHighlights(),
                      const SizedBox(height: 24),
                      _buildRentalTerms(),
                      const SizedBox(height: 32),
                      _buildSimilarItems(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildFloatingBottomBar(),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    final images = widget.product.images;
    final hasMultiple = images.length > 1;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 480,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => _openImageFullscreen(index),
              child: CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: Colors.grey[200]),
              ),
            ),
          ),
        ),
        // Top bar overlay
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 24,
          right: 24,
          child: _buildTopBar(),
        ),
        // Image counter & carousel dots
        if (hasMultiple) ...[
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '${_currentImageIndex + 1} / ${images.length}',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final isActive = i == _currentImageIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 24 : 8,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
        ],
        // AR button (disabled — feature not yet built)
        Positioned(
          bottom: 16,
          right: 16,
          child: Tooltip(
            message: 'AR Try-On coming soon',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(FluentIcons.cube_24_regular, color: Colors.white54, size: 22),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(FluentIcons.chevron_left_24_regular, color: Colors.white),
          ),
        ),
        Text(
          'PRODUCT DETAILS',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        Row(
          children: [
            _buildTopIcon(FluentIcons.heart_24_regular, () async {
              final userId = context.read<AppState>().currentUser.id;
              await WishlistService().toggle(userId, widget.product.id);
              if (mounted) {
                context.read<AppState>().refreshFavorites();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Wishlist updated')),
                );
              }
            }),
            const SizedBox(width: 8),
            _buildTopIcon(FluentIcons.share_24_regular, () {
              Share.share(
                'Check out "${widget.product.name}" on Dress — rent premium fashion at a fraction of the cost. ₹${widget.product.rentalPricePerDay.toStringAsFixed(0)}/day',
                subject: widget.product.name,
              );
            }),
            const SizedBox(width: 8),
            _buildTopIcon(FluentIcons.cart_24_regular, () {
              if (selectedSize == null || selectedColor == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pick a size and color first')),
                );
                return;
              }
              context.read<AppState>().addToCart(
                CartItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  product: widget.product,
                  selectedSize: selectedSize!,
                  selectedColor: selectedColor!,
                  rentalStartDate: DateTime.now(),
                  rentalEndDate: DateTime.now().add(const Duration(days: 3)),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to Bag')),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildTopIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildTitleAndPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.product.location.isNotEmpty)
                Text(
                  widget.product.location.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textLight,
                    letterSpacing: 1.0,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                widget.product.name,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹ ${widget.product.rentalPricePerDay.toStringAsFixed(0)}',
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark),
            ),
            Text(
              'per day',
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600),
            ),
            if (widget.product.securityDeposit > 0) ...[
              const SizedBox(height: 4),
              Text(
                '+ ₹ ${widget.product.securityDeposit.toStringAsFixed(0)} deposit',
                style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight, fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildRatingRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.star, size: 20, color: Color(0xFFFBBC05)),
            const SizedBox(width: 4),
            Text(
              widget.product.rating.toStringAsFixed(1),
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark),
            ),
            const SizedBox(width: 8),
            Text(
              '|  ${widget.product.reviewsCount} reviews',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textLight),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  session: ChatSession(
                    id: 'store-${widget.product.storeId}',
                    peerName: widget.product.storeName.isNotEmpty
                        ? widget.product.storeName
                        : 'Lender',
                    peerAvatar: widget.product.images.isNotEmpty
                        ? widget.product.images.first
                        : '',
                    lastMessage: '',
                    lastMessageTime: DateTime.now(),
                  ),
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFEAF1F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(FluentIcons.chat_24_regular, size: 20, color: AppTheme.textDark),
          ),
        ),
      ],
    );
  }

  Widget _buildLenderCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoreDetailScreen(storeName: widget.product.storeName),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
              child: Center(
                child: Text(
                  widget.product.storeName.isNotEmpty ? widget.product.storeName[0].toUpperCase() : 'S',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
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
                      Flexible(
                        child: Text(
                          widget.product.storeName,
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (widget.product.isVerifiedStore)
                        const Icon(Icons.verified, size: 16, color: Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(FluentIcons.location_24_regular, size: 12, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.product.location,
                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('•', style: TextStyle(color: AppTheme.textLight, fontSize: 10)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Verified lender',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryLime,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Visit',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => isDescriptionExpanded = !isDescriptionExpanded),
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(fontSize: 14, height: 1.5, color: AppTheme.textDark.withOpacity(0.8)),
              children: [
                TextSpan(
                  text: isDescriptionExpanded
                      ? '${widget.product.description} '
                      : (widget.product.description.length > 120
                          ? '${widget.product.description.substring(0, 120)}... '
                          : '${widget.product.description} '),
                ),
                TextSpan(
                  text: isDescriptionExpanded ? 'Read Less' : 'Read More',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppTheme.textDark),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    if (widget.product.sizes.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Size', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const SizeGuideBottomSheet(),
                );
              },
              child: Row(
                children: [
                  const Icon(FluentIcons.ruler_24_regular, size: 14, color: AppTheme.textLight),
                  const SizedBox(width: 4),
                  Text('Size Guide',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, decoration: TextDecoration.underline, color: AppTheme.textLight)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.product.sizes.map(_buildSizePill).toList(),
        ),
      ],
    );
  }

  Widget _buildSizePill(String size) {
    final isSelected = selectedSize == size;
    return GestureDetector(
      onTap: () => setState(() => selectedSize = size),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textDark : const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          size,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
            color: isSelected ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    if (widget.product.colors.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.product.colors.map(_buildColorDot).toList(),
        ),
      ],
    );
  }

  Widget _buildColorDot(String colorName) {
    final isSelected = selectedColor == colorName;
    final color = _getColorFromName(colorName);
    return GestureDetector(
      onTap: () => setState(() => selectedColor = colorName),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppTheme.textDark : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: color == Colors.white ? Border.all(color: Colors.grey.shade200) : null,
          ),
          child: isSelected && color == Colors.white
              ? const Icon(Icons.check, size: 16, color: Colors.black)
              : isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
        ),
      ),
    );
  }

  Widget _buildHighlights() {
    final features = [
      {'icon': FluentIcons.shield_checkmark_24_regular, 'label': 'Quality checked'},
      {'icon': FluentIcons.box_24_regular, 'label': 'Free pickup & return'},
      {'icon': FluentIcons.calendar_24_regular, 'label': 'Flexible dates'},
      {'icon': FluentIcons.arrow_reset_24_regular, 'label': 'Easy refund'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Why rent this?', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 4,
          children: features.map((f) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(f['icon'] as IconData, size: 18, color: AppTheme.textDark),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    f['label'] as String,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildRentalTerms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rental terms', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFE082)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(FluentIcons.info_24_regular, size: 16, color: Color(0xFFE65100)),
                  const SizedBox(width: 8),
                  Text('Cancellation policy',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFFE65100))),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Full refund if cancelled 48h before rental start. Within 48h, 50% refund. No refund once item is shipped.',
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarItems() {
    if (_loadingSimilar) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_similarItems.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Complete the look', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryListingScreen(categoryName: widget.product.category),
                  ),
                );
              },
              child: Text('See all',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _similarItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final product = _similarItems[i];
              return SizedBox(
                width: 170,
                child: ProductCard(product: product, imageHeight: 200),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingBottomBar() {
    return Positioned(
      bottom: 16,
      left: 24,
      right: 24,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryLime,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(color: AppTheme.primaryLime.withOpacity(0.3), offset: const Offset(0, 8), blurRadius: 15),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SelectDatesScreen(
                  product: widget.product,
                  selectedSize: selectedSize,
                  selectedColor: selectedColor,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(FluentIcons.calendar_24_regular, size: 18, color: AppTheme.textDark),
              const SizedBox(width: 8),
              Text('SELECT DATES',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'black': return Colors.black;
      case 'grey': return Colors.grey;
      case 'navy': return Colors.blue.shade900;
      case 'red': return Colors.red;
      case 'emerald': return Colors.green.shade800;
      case 'blue denim': return Colors.blue.shade700;
      case 'black denim': return Colors.black87;
      case 'charcoal': return Colors.grey.shade800;
      case 'white': return Colors.white;
      default: return Colors.grey;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
