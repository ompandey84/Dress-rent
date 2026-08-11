import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/product.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/services/database_service.dart';
import 'package:dress_app/screens/notifications_screen.dart';
import 'package:dress_app/screens/search_results_screen.dart';
import 'package:dress_app/screens/category_listing_screen.dart';
import 'package:dress_app/screens/login_screen.dart';
import 'package:dress_app/screens/edit_profile_screen.dart';
import 'package:dress_app/widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';

  // Pagination state
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 8;
  int _offset = 0;
  bool _hasMore = true;
  bool _loadingMore = false;
  bool _initialLoading = true;
  String? _loadError;
  final List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchFirstPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _fetchFirstPage() async {
    setState(() {
      _initialLoading = true;
      _loadError = null;
      _offset = 0;
      _hasMore = true;
      _products.clear();
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final raw = await DatabaseService()
          .getProducts(limit: _pageSize, offset: _offset);
      final newOnes = raw
          .map((m) => Product.fromJson(m))
          .where((p) => p.id.isNotEmpty)
          .toList();
      if (!mounted) return;
      setState(() {
        _products.addAll(newOnes);
        _offset += newOnes.length;
        _hasMore = newOnes.length >= _pageSize;
        _initialLoading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _initialLoading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _fetchFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    final isGuest = appState.isGuest;
    final firstName = _firstNameOf(user.name, isGuest);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE4F4FA),
              Color(0xFFF7F9FB),
              Color(0xFFF7F9FB),
            ],
            stops: [0.0, 0.2, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppTheme.primaryLime,
            onRefresh: _refresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Pinned header — greeting + avatar + notification
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedDelegate(
                    height: 80,
                    child: Container(
                      color: Colors.white.withOpacity(0.96),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      alignment: Alignment.center,
                      child: _buildHeaderContent(
                        firstName,
                        user.avatarUrl,
                        isGuest,
                      ),
                    ),
                  ),
                ),
                // Pinned search bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedDelegate(
                    height: 56,
                    child: Container(
                      color: Colors.white.withOpacity(0.96),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                      alignment: Alignment.center,
                      child: _buildSearchBar(),
                    ),
                  ),
                ),
                // Pinned category chips
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedDelegate(
                    height: 44,
                    child: Container(
                      color: Colors.white.withOpacity(0.96),
                      padding: const EdgeInsets.only(bottom: 8),
                      alignment: Alignment.center,
                      child: _buildCategoryChips(),
                    ),
                  ),
                ),
                // Section title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: _buildSectionTitle('New arrivals'),
                  ),
                ),
                // Products
                _buildProductSliver(),
                // Bottom loader
                SliverToBoxAdapter(child: _buildBottomLoader()),
                // Bottom padding so the last row isn't hidden behind the
                // floating bottom navigation bar.
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductSliver() {
    if (_initialLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryLime,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }
    if (_loadError != null && _products.isEmpty) {
      return SliverToBoxAdapter(child: _buildErrorState());
    }
    final filtered = _selectedCategory == 'All'
        ? _products
        : _products
            .where((p) => p.category.toLowerCase() ==
                _selectedCategory.toLowerCase())
            .toList();
    if (filtered.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Column(
              children: [
                Icon(
                  FluentIcons.clothes_hanger_24_regular,
                  size: 32,
                  color: AppTheme.textLight.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedCategory == 'All'
                      ? 'No products yet'
                      : 'No items in "$_selectedCategory"',
                  style: GoogleFonts.inter(
                    color: AppTheme.textLight,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _refresh,
                  child: Text(
                    'Tap to refresh',
                    style: GoogleFonts.inter(
                      color: AppTheme.textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 14,
          childAspectRatio: 0.62,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return ProductCard(
              product: filtered[index],
              imageHeight: 200.0,
            );
          },
          childCount: filtered.length,
        ),
      ),
    );
  }

  Widget _buildBottomLoader() {
    if (_initialLoading || !_hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: _hasMore
              ? const SizedBox.shrink()
              : Text(
                  '— end of catalogue —',
                  style: GoogleFonts.inter(
                    color: AppTheme.textLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: AppTheme.primaryLime,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              FluentIcons.error_circle_24_regular,
              size: 36,
              color: AppTheme.textLight.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              "Couldn't load products",
              style: GoogleFonts.inter(
                color: AppTheme.textLight,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(FluentIcons.arrow_clockwise_24_regular, size: 14),
              label: Text('RETRY',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.textDark,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _firstNameOf(String name, bool isGuest) {
    if (isGuest) return 'Guest';
    final n = name.trim();
    if (n.isEmpty) return 'Guest';
    final parts = n.split(RegExp(r'\s+'));
    return parts.first;
  }

  Widget _buildHeaderContent(
    String firstName,
    String? avatarUrl,
    bool isGuest,
  ) {
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      'Hey $firstName!',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('👋', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                isGuest
                    ? 'Sign in to access your rentals & wallet'
                    : 'Find your next outfit — rent it.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.textLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F4F7),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  FluentIcons.alert_24_regular,
                  color: AppTheme.textDark,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (isGuest) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                }
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryLime,
                ),
                alignment: Alignment.center,
                child: hasAvatar
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: avatarUrl,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _initialAvatar(firstName),
                          errorWidget: (_, __, ___) =>
                              _initialAvatar(firstName),
                        ),
                      )
                    : _initialAvatar(firstName),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _initialAvatar(String name) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Text(
      letter,
      style: GoogleFonts.inter(
        color: AppTheme.textDark,
        fontWeight: FontWeight.w900,
        fontSize: 14,
      ),
    );
  }

  Widget _buildCategoryChips() {
    final List<String> categories = const [
      'All',
      'Ethnic',
      'Formal',
      'Casual',
      'Party',
      'Bridal',
    ];
    return SizedBox(
      height: 32,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = cat);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.textDark : Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: isSelected
                    ? null
                    : Border.all(color: AppTheme.border),
              ),
              alignment: Alignment.center,
              child: Text(
                cat,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.textDark,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F7),
        borderRadius: BorderRadius.circular(100),
      ),
      child: TextField(
        style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDark),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SearchResultsScreen(query: value),
              ),
            );
          }
        },
        decoration: InputDecoration(
          hintText: 'Search items, sellers or brands',
          hintStyle:
              GoogleFonts.inter(color: AppTheme.textLight, fontSize: 13),
          border: InputBorder.none,
          prefixIcon: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(
              FluentIcons.search_24_regular,
              size: 18,
              color: AppTheme.textLight,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppTheme.textDark,
            letterSpacing: -0.3,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryListingScreen(
                  categoryName: _selectedCategory,
                ),
              ),
            );
          },
          child: Text(
            'See all',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textLight,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

// Single delegate for all three pinned header rows. Each instance has a
// distinct height and a distinct child.
class _PinnedDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _PinnedDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      child;
  @override
  bool shouldRebuild(covariant _PinnedDelegate oldDelegate) =>
      oldDelegate.height != height || oldDelegate.child != child;
}
