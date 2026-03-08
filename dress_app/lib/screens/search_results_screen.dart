import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/product.dart';
import 'package:dress_app/screens/product_details_screen.dart';
import 'package:dress_app/services/mock_data_service.dart';
import 'package:dress_app/widgets/favorite_button.dart';
import 'package:dress_app/screens/filters_bottom_sheet.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;
  const SearchResultsScreen({super.key, this.query = ''});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late TextEditingController _searchController;
  List<Product> _products = [];
  String _currentSort = 'Popular';
  Map<String, dynamic>? _appliedFilters;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
    _filterProducts(widget.query);
  }

  void _filterProducts(String query) {
    setState(() {
      var filtered = List.from(MockDataService.mockProducts);

      if (query.isNotEmpty) {
        final lowercaseQuery = query.toLowerCase();
        filtered = filtered.where((p) {
          return p.name.toLowerCase().contains(lowercaseQuery) || 
                 p.category.toLowerCase().contains(lowercaseQuery);
        }).toList();
      }

      if (_appliedFilters != null) {
        final category = _appliedFilters!['category'] as String;
        final priceRange = _appliedFilters!['priceRange'] as RangeValues;
        final sizes = _appliedFilters!['sizes'] as List<String>;
        
        if (category != 'All') {
          filtered = filtered.where((p) => p.category == category).toList();
        }
        
        filtered = filtered.where((p) => p.price >= priceRange.start && p.price <= priceRange.end).toList();
        
        if (sizes.isNotEmpty) {
          filtered = filtered.where((p) => p.sizes.any((s) => sizes.contains(s))).toList();
        }
      }

      _products = filtered.cast<Product>();
      _applySort();
    });
  }

  void _applySort() {
    setState(() {
      if (_currentSort == 'Popular') {
        _products.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (_currentSort == 'Price: Low to High') {
        _products.sort((a, b) => a.price.compareTo(b.price));
      } else if (_currentSort == 'Price: High to Low') {
        _products.sort((a, b) => b.price.compareTo(a.price));
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilters() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FiltersBottomSheet(),
    );

    if (result != null && result is Map<String, dynamic>) {
      _appliedFilters = result;
      _filterProducts(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Search AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppTheme.textLight.withOpacity(0.2)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search dresses, stores...',
                          hintStyle: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 14),
                          border: InputBorder.none,
                          icon: const Icon(FluentIcons.search_24_regular, color: AppTheme.textLight),
                        ),
                        onSubmitted: (value) {
                          _filterProducts(value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _showFilters,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLime.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(FluentIcons.filter_24_regular, color: AppTheme.primaryLime),
                    ),
                  ),
                ],
              ),
            ),
            
            // Search Results Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_products.length} Results Found',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                  ),
                  PopupMenuButton<String>(
                    initialValue: _currentSort,
                    onSelected: (String value) {
                      setState(() {
                        _currentSort = value;
                        _applySort();
                      });
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'Popular', child: Text('Popular')),
                      const PopupMenuItem(value: 'Price: Low to High', child: Text('Price: Low to High')),
                      const PopupMenuItem(value: 'Price: High to Low', child: Text('Price: High to Low')),
                    ],
                    child: Row(
                      children: [
                        Text(
                          _currentSort,
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                        ),
                        const SizedBox(width: 4),
                        const Icon(FluentIcons.chevron_down_24_regular, size: 16, color: AppTheme.textDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.55,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(context, _products[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product) {
    String title = product.name;
    String location = product.location;
    String price = 'AED ${product.price.toStringAsFixed(2)}/day';
    String imgUrl = product.images.isNotEmpty ? product.images.first : '';
    bool isVerified = product.isVerifiedStore;
    String rating = product.rating.toString();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: imgUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(color: Colors.grey[200]),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: FavoriteButton(
                    productId: product.id,
                    backgroundColor: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  location,
                  style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, size: 12, color: Colors.green),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryLime),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 12, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(
                    rating,
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
