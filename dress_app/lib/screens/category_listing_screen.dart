import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/product.dart';
import 'package:dress_app/services/database_service.dart';
import 'package:dress_app/screens/filters_bottom_sheet.dart';
import 'package:dress_app/widgets/product_card.dart';

class CategoryListingScreen extends StatefulWidget {
  final String categoryName;
  const CategoryListingScreen({super.key, required this.categoryName});

  @override
  State<CategoryListingScreen> createState() => _CategoryListingScreenState();
}

class _CategoryListingScreenState extends State<CategoryListingScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategoryProducts();
  }

  Future<void> _fetchCategoryProducts() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final db = DatabaseService();
      // Since our getProducts filters by categoryId not name,
      // and we don't have exact category slugs yet, we'll fetch all and filter locally
      final rawProducts = await db.getProducts();
      final allProducts = rawProducts.map((p) => Product.fromJson(p)).toList();
      
      final String categoryLower = widget.categoryName.toLowerCase();
      
      setState(() {
        if (categoryLower == 'view all') {
           _products = allProducts;
        } else {
           _products = allProducts.where((p) => p.category.toLowerCase() == categoryLower).toList();
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching category products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FiltersBottomSheet(),
    );
  }

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
          widget.categoryName.toUpperCase(),
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(FluentIcons.filter_24_regular, color: AppTheme.textDark),
            onPressed: _showFilters,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryLime))
        : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_products.length} Items Found',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textLight),
                ),
                Row(
                  children: [
                    Text(
                      'Sort by: Popular',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                    ),
                    const SizedBox(width: 4),
                    const Icon(FluentIcons.chevron_down_24_regular, size: 16, color: AppTheme.textDark),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _products.isEmpty 
              ? Center(
                  child: Text(
                    'No dresses found in ${widget.categoryName}.',
                    style: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 16),
                  ),
                )
              : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                childAspectRatio: 0.5,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                return ProductCard(product: _products[index], imageHeight: 200);
              },
            ),
          ),
        ],
      ),
    );
  }
}
