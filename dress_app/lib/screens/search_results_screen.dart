import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/product.dart';
import 'package:dress_app/services/database_service.dart';
import 'package:dress_app/widgets/product_card.dart';
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

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
    _filterProducts(widget.query);
  }

  Future<void> _filterProducts(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final db = DatabaseService();
      List<Map<String, dynamic>> rawProducts;
      
      if (query.isNotEmpty) {
        rawProducts = await db.searchProducts(query);
      } else {
        rawProducts = await db.getProducts();
      }

      var filtered = rawProducts.map((p) => Product.fromJson(p)).toList();

      if (_appliedFilters != null) {
        final category = _appliedFilters!['category'] as String?;
        final priceRange = _appliedFilters!['priceRange'] as RangeValues?;
        final sizes = _appliedFilters!['sizes'] as List<String>?;
        
        if (category != null && category != 'All') {
          filtered = filtered.where((p) => p.category == category).toList();
        }
        
        if (priceRange != null) {
          filtered = filtered.where((p) => p.price >= priceRange.start && p.price <= priceRange.end).toList();
        }
        
        if (sizes != null && sizes.isNotEmpty) {
          filtered = filtered.where((p) => p.sizes.any((s) => sizes.contains(s))).toList();
        }
      }

      setState(() {
        _products = filtered;
        _applySort();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error searching products: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryLime))
                  : _products.isEmpty
                      ? Center(
                          child: Text(
                            'No dresses found.',
                            style: GoogleFonts.inter(
                              color: AppTheme.textLight,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(24),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 24,
                            childAspectRatio: 0.5,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            return ProductCard(product: _products[index], imageHeight: 180);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

}
