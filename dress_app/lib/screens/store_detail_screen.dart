import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/product.dart';
import 'package:dress_app/services/database_service.dart';
import 'package:dress_app/widgets/product_card.dart';

class StoreDetailScreen extends StatefulWidget {
  final String storeName;
  const StoreDetailScreen({super.key, required this.storeName});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  List<Product> _storeProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStoreProducts();
  }

  Future<void> _fetchStoreProducts() async {
    try {
      final db = DatabaseService();
      // Fetch all products and filter by store name for now
      final rawProducts = await db.getProducts();
      final allProducts = rawProducts.map((p) => Product.fromJson(p)).toList();
      
      setState(() {
        _storeProducts = allProducts.where((p) => p.storeName.toLowerCase() == widget.storeName.toLowerCase()).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching store products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryLime))
        : CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.backgroundLight,
            elevation: 0,
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: _storeProducts.isNotEmpty && _storeProducts.first.images.isNotEmpty
                        ? _storeProducts.first.images.first
                        : 'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?q=80&w=800&auto=format&fit=crop',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 24,
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              widget.storeName.isNotEmpty ? widget.storeName.substring(0, 1).toUpperCase() : 'S',
                              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.storeName,
                                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, size: 16, color: Colors.blue),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.storeName} ${_storeProducts.length} items',
                                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Store Location', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
                          const SizedBox(height: 4),
                          Text(
                            _storeProducts.isNotEmpty && _storeProducts.first.location.isNotEmpty
                                ? _storeProducts.first.location
                                : 'India',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLime.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(FluentIcons.location_24_regular, color: AppTheme.primaryLime),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'All Items',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          if (_storeProducts.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.5, // matches home screen ratio roughly
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return ProductCard(product: _storeProducts[index], imageHeight: 180);
                  },
                  childCount: _storeProducts.length,
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Text(
                    'No items available.',
                    style: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 16),
                  ),
                ),
              ),
            ),
          
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}
