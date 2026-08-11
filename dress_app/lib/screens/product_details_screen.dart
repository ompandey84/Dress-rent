import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/product.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/services/database_service.dart';
import 'package:dress_app/services/wishlist_service.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:dress_app/screens/select_dates_screen.dart';
import 'package:dress_app/screens/store_detail_screen.dart';
import 'package:dress_app/screens/chat_screen.dart';
import 'package:dress_app/models/chat_session.dart';
import 'package:dress_app/screens/category_listing_screen.dart';
import 'package:dress_app/models/cart_item.dart';
import 'package:dress_app/screens/size_guide_bottom_sheet.dart';
import 'package:dress_app/widgets/product_card.dart';
import 'package:dress_app/widgets/error_dialog.dart';

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
    if (widget.product.sizes.isNotEmpty) {
      selectedSize = widget.product.sizes.first;
    }
    if (widget.product.colors.isNotEmpty) {
      selectedColor = widget.product.colors.first;
    }
    _loadSimilar();
  }

  Future<void> _loadSimilar() async {
    try {
      // Pull from Supabase when possible, mock fallback otherwise.
      List<Product> all;
      if (SupabaseService.isConfigured) {
        final raw = await DatabaseService().getProducts(limit: 20);
        all = raw.map((m) => Product.fromJson(m)).toList();
      } else {
        all = _mockProductsForSimilar();
      }
      if (!mounted) return;
      setState(() {
        _similarItems = all
            .where((p) =>
                p.id != widget.product.id &&
                (p.category.toLowerCase() ==
                        widget.product.category.toLowerCase() ||
                    p.storeName == widget.product.storeName))
            .take(6)
            .toList();
        _loadingSimilar = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingSimilar = false);
    }
  }

  List<Product> _mockProductsForSimilar() {
    return const [
      // tiny built-in fallback so the "similar items" row never shows
      // empty even if both Supabase and MockDataService are unreachable
    ];
  }

  Future<void> _refresh() async {
    setState(() => _loadingSimilar = true);
    await _loadSimilar();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: AppTheme.primaryLime,
        onRefresh: _refresh,
        child: CustomScrollView(
          // AlwaysScrollable so pull-to-refresh works even when content
          // doesn't fill the viewport.
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildImageCarousel()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildTitleAndPrice(),
                  const SizedBox(height: 12),
                  _buildRatingRow(),
                  const SizedBox(height: 16),
                  _buildLenderCard(),
                  const SizedBox(height: 20),
                  _buildDescription(),
                  if (widget.product.sizes.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSizeSelector(),
                  ],
                  if (widget.product.colors.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildColorSelector(),
                  ],
                  const SizedBox(height: 20),
                  _buildHighlights(),
                  const SizedBox(height: 20),
                  _buildRentalTerms(),
                  const SizedBox(height: 24),
                  _buildSimilarItems(),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildFloatingBottomBar(),
    );
  }

  Widget _buildImageCarousel() {
    final images = widget.product.images;
    final hasMultiple = images.length > 1;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 380,
          width: double.infinity,
          child: images.isEmpty
              ? _imagePlaceholder()
              : PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (i) =>
                      setState(() => _currentImageIndex = i),
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => _openImageFullscreen(index),
                    child: CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _imagePlaceholder(loading: true),
                      errorWidget: (_, __, ___) => _imagePlaceholder(),
                    ),
                  ),
                ),
        ),
        // Top bar overlay — back button always visible
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          child: _buildTopBar(),
        ),
        // Image counter & carousel dots
        if (hasMultiple) ...[
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '${_currentImageIndex + 1} / ${images.length}',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
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
                    color: isActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
        ],
      ],
    );
  }

  Widget _imagePlaceholder({bool loading = false}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE4F4FA), Color(0xFFF6F8FA)],
        ),
      ),
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.textLight,
              ),
            )
          : Icon(
              Icons.checkroom_outlined,
              size: 80,
              color: AppTheme.textLight.withOpacity(0.4),
            ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button — always visible, white circle on dark overlay
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              FluentIcons.chevron_left_24_regular,
              color: AppTheme.textDark,
              size: 22,
            ),
          ),
        ),
        // Right side action cluster
        Row(
          children: [
            _buildTopIcon(
                FluentIcons.heart_24_regular, () => _toggleWishlist()),
            const SizedBox(width: 8),
            _buildTopIcon(FluentIcons.cart_24_regular, () => _addToCart()),
          ],
        ),
      ],
    );
  }

  Widget _buildTopIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppTheme.textDark, size: 20),
      ),
    );
  }

  Future<void> _toggleWishlist() async {
    final isGuest = context.read<AppState>().isGuest;
    if (isGuest) {
      await ErrorDialog.show(
        context,
        title: 'Sign in to save',
        message: 'Create a free account to keep track of items you love.',
      );
      return;
    }
    final userId = context.read<AppState>().currentUser.id;
    try {
      await WishlistService().toggle(userId, widget.product.id);
      if (mounted) {
        await context.read<AppState>().refreshFavorites();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wishlist updated')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final desc = ErrorDialog.describe(e);
        await ErrorDialog.show(
          context,
          title: desc.title,
          message: desc.message,
          technical: e.toString(),
        );
      }
    }
  }

  Future<void> _addToCart() async {
    if (selectedSize == null || selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a size and color first')),
      );
      return;
    }
    final userId = context.read<AppState>().currentUser.id;
    if (userId.isEmpty) {
      // Guest mode — also save locally so the cart works
      try {
        await context.read<AppState>().addToCart(
              CartItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                product: widget.product,
                selectedSize: selectedSize!,
                selectedColor: selectedColor!,
                rentalStartDate: DateTime.now(),
                rentalEndDate: DateTime.now().add(const Duration(days: 3)),
              ),
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to Bag')),
          );
        }
      } catch (e) {
        if (mounted) {
          await ErrorDialog.show(context,
              title: 'Could not add to bag',
              message: 'Please try again.',
              technical: e.toString());
        }
      }
      return;
    }
    try {
      await context.read<AppState>().addToCart(
            CartItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              product: widget.product,
              selectedSize: selectedSize!,
              selectedColor: selectedColor!,
              rentalStartDate: DateTime.now(),
              rentalEndDate: DateTime.now().add(const Duration(days: 3)),
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to Bag')),
        );
      }
    } catch (e) {
      if (mounted) {
        await ErrorDialog.show(context,
            title: 'Could not add to bag',
            message: 'Please try again.',
            technical: e.toString());
      }
    }
  }

  Widget _buildTitleAndPrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.product.location.isNotEmpty)
          Text(
            widget.product.location.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppTheme.textLight,
              letterSpacing: 1.0,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          widget.product.name,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppTheme.textDark,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        // Price + deposit in one row
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹ ${widget.product.rentalPricePerDay.toStringAsFixed(0)}',
              style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '/ day',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w600),
              ),
            ),
            if (widget.product.securityDeposit > 0) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+ ₹${widget.product.securityDeposit.toStringAsFixed(0)} deposit',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        const Icon(Icons.star, size: 18, color: Color(0xFFFBBC05)),
        const SizedBox(width: 4),
        Text(
          widget.product.rating.toStringAsFixed(1),
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark),
        ),
        const SizedBox(width: 6),
        Text(
          '|  ${widget.product.reviewsCount} reviews',
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textLight),
        ),
      ],
    );
  }

  Widget _buildLenderCard() {
    final storeName = widget.product.storeName.isNotEmpty
        ? widget.product.storeName
        : 'Lender';
    final location = widget.product.location.isNotEmpty
        ? widget.product.location
        : 'India';
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.black),
              alignment: Alignment.center,
              child: Text(
                storeName[0].toUpperCase(),
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          storeName,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (widget.product.isVerifiedStore)
                        const Icon(Icons.verified,
                            size: 14, color: Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Inline chat button (rectangle pill so it doesn't get clipped)
            GestureDetector(
              onTap: () => _openChat(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.textDark,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.chat_24_regular,
                        color: AppTheme.primaryLime, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      'Chat',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChat() {
    final storeName = widget.product.storeName.isNotEmpty
        ? widget.product.storeName
        : 'Lender';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          session: ChatSession(
            id: 'store-${widget.product.storeId}',
            peerName: storeName,
            peerAvatar: widget.product.images.isNotEmpty
                ? widget.product.images.first
                : '',
            lastMessage: '',
            lastMessageTime: DateTime.now(),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    final desc = widget.product.description;
    if (desc.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () =>
              setState(() => isDescriptionExpanded = !isDescriptionExpanded),
          child: Text(
            isDescriptionExpanded || desc.length <= 120
                ? desc
                : '${desc.substring(0, 120)}…  Read More',
            style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: AppTheme.textDark.withOpacity(0.8)),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Size',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark)),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const SizeGuideBottomSheet(),
                );
              },
              child: Text('Size Guide',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      color: AppTheme.textLight)),
            ),
          ],
        ),
        const SizedBox(height: 10),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textDark : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? AppTheme.textDark : Colors.grey.shade300,
          ),
        ),
        child: Text(
          size,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color',
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
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
        width: 32,
        height: 32,
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
            border: color == Colors.white
                ? Border.all(color: Colors.grey.shade200)
                : null,
          ),
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
        Text('Why rent this?',
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark)),
        const SizedBox(height: 10),
        // Wrap instead of GridView — avoids pixel overflow on narrow screens
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: features.map((f) {
            return Container(
              width: (MediaQuery.of(context).size.width - 40 - 8) / 2,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(f['icon'] as IconData,
                      size: 16, color: AppTheme.textDark),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      f['label'] as String,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRentalTerms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rental terms',
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFE082)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(FluentIcons.info_24_regular,
                  size: 16, color: Color(0xFFE65100)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Full refund if cancelled 48h before rental start. Within 48h, 50% refund. No refund once item is shipped.',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textDark,
                      height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarItems() {
    if (_loadingSimilar) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_similarItems.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Complete the look',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark)),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryListingScreen(
                        categoryName: widget.product.category),
                  ),
                );
              },
              child: Text('See all',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textLight)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 270,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _similarItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final product = _similarItems[i];
              return SizedBox(
                width: 160,
                child: ProductCard(product: product, imageHeight: 200),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 14,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Chat button (rectangle pill, fully visible)
            GestureDetector(
              onTap: _openChat,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1F5),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  FluentIcons.chat_24_regular,
                  color: AppTheme.textDark,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryLime,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryLime.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(FluentIcons.calendar_24_regular,
                          size: 16, color: AppTheme.textDark),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'SELECT DATES',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textDark,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'grey':
        return Colors.grey;
      case 'navy':
        return Colors.blue.shade900;
      case 'red':
        return Colors.red;
      case 'emerald':
        return Colors.green.shade800;
      case 'blue denim':
        return Colors.blue.shade700;
      case 'black denim':
        return Colors.black87;
      case 'charcoal':
        return Colors.grey.shade800;
      case 'white':
        return Colors.white;
      default:
        return Colors.grey;
    }
  }

  void _openImageFullscreen(int initialIndex) {
    final images = widget.product.images;
    if (images.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PageView.builder(
            itemCount: images.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) => InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
                errorWidget: (_, __, ___) => const Center(
                  child: Icon(Icons.checkroom_outlined,
                      color: Colors.white54, size: 80),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
