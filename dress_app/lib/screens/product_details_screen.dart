import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/product.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/screens/select_dates_screen.dart';
import 'package:dress_app/screens/store_detail_screen.dart';
import 'package:dress_app/models/cart_item.dart';
import 'package:dress_app/screens/size_guide_bottom_sheet.dart';
import 'package:dress_app/screens/help_support_screen.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.product.sizes.isNotEmpty) selectedSize = widget.product.sizes.first;
    if (widget.product.colors.isNotEmpty) selectedColor = widget.product.colors.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Scrollable Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120), // Bottom padding for floating bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                        // Hero Image with curved bottom and Stack overlay
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                              child: widget.product.images.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: widget.product.images.first,
                                      height: 480,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) => Container(color: Colors.grey[200], height: 480),
                                    )
                                  : Container(color: Colors.grey[200], height: 480),
                            ),
                            // Floating Top Bar Overlay
                            Positioned(
                              top: MediaQuery.of(context).padding.top + 8,
                              left: 24,
                              right: 24,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        FluentIcons.chevron_left_24_regular,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'PRODUCT DETAILS',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      // Heart Button
                                      GestureDetector(
                                        onTap: () {
                                          context.read<AppState>().toggleFavorite(widget.product.id);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          margin: const EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.3),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            context.watch<AppState>().wishlistProductIds.contains(widget.product.id) ? FluentIcons.heart_24_filled : FluentIcons.heart_24_regular,
                                            color: context.watch<AppState>().wishlistProductIds.contains(widget.product.id) ? Colors.red : Colors.white,
                                          ),
                                        ),
                                      ),
                                      // Share Button
                                      GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) => Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                              ),
                                              padding: const EdgeInsets.all(24),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Share Product',
                                                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                                                  ),
                                                  const SizedBox(height: 24),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      _buildShareOption(Icons.message, 'Message', Colors.green),
                                                      _buildShareOption(Icons.copy, 'Copy Link', Colors.blue),
                                                      _buildShareOption(Icons.more_horiz, 'More', Colors.grey),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 24),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          margin: const EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.3),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            FluentIcons.share_24_regular,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      // Cart Button
                                      GestureDetector(
                                        onTap: () {
                                          context.read<AppState>().addToCart(
                                            CartItem(
                                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                                              product: widget.product,
                                              selectedSize: selectedSize ?? 'M',
                                              selectedColor: selectedColor ?? 'Default',
                                              rentalDates: '3 Days',
                                            ),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Bag')));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.3),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            FluentIcons.cart_24_regular,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // AR View Button Overlay
                            Positioned(
                              bottom: 24, // adjust to hover right above the curve
                              right: 24,
                              child: GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AR View coming soon!')));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                                  ),
                                  child: const Icon(
                                    FluentIcons.cube_24_regular,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.product.location,
                                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                                    ),
                                    const SizedBox(height: 4),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        widget.product.name.toUpperCase(),
                                        style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark, height: 1.1),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'AED ${widget.product.price.toStringAsFixed(2)}',
                                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF0C6B86)), // Exact teal color targeting from design
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 20, color: Color(0xFFFBBC05)), // Gold star
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.product.rating.toString(),
                                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '|  ${widget.product.reviewsCount} reviews',
                                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEAF1F5), // Light blue-grey background
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(FluentIcons.chat_24_regular, size: 20, color: AppTheme.textDark),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Store details
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F8FA),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 42,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.product.storeName.isNotEmpty ? widget.product.storeName[0].toUpperCase() : 'S',
                                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
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
                                          Text(
                                            widget.product.storeName,
                                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(Icons.verified, size: 16, color: Colors.blue),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(FluentIcons.location_24_regular, size: 14, color: AppTheme.textDark),
                                          const SizedBox(width: 4),
                                          Text(
                                            widget.product.location,
                                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => StoreDetailScreen(storeName: widget.product.storeName)));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryLime,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                          ),
                          const SizedBox(height: 24),
                          
                          // Product Description
                          Text(
                            'Product Description',
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isDescriptionExpanded = !isDescriptionExpanded;
                              });
                            },
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.inter(fontSize: 15, height: 1.5, color: AppTheme.textDark.withValues(alpha: 0.8)),
                                children: [
                                  TextSpan(
                                    text: isDescriptionExpanded
                                        ? widget.product.description + ' '
                                        : (widget.product.description.length > 100 ? widget.product.description.substring(0, 100) + '... ' : widget.product.description + ' '),
                                  ),
                                  TextSpan(
                                    text: isDescriptionExpanded ? 'Read Less' : 'Read More',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppTheme.textDark),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (widget.product.sizes.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Size',
                                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => const SizeGuideBottomSheet(),
                                    );
                                  },
                                  child: Text(
                                    'Size Guide',
                                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, decoration: TextDecoration.underline, color: AppTheme.textLight),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.product.sizes.map((s) => _buildSizePill(s)).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],
                          
                          // Color Selector
                          if (widget.product.colors.isNotEmpty) ...[
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: widget.product.colors.map((c) => _buildColorDot(c)).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
              ],
            ),
          ),
            
            // Floating Bottom Actions
            Positioned(
              bottom: 15, // 15px padding
              left: 24,
              right: 24,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLime,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryLime.withValues(alpha: 0.3), offset: const Offset(0, 8), blurRadius: 15),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SelectDatesScreen(
                        product: widget.product,
                        selectedSize: selectedSize,
                        selectedColor: selectedColor,
                      )),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Center(
                    child: Text(
                      'BUY IT NOW',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ), // Stack
    ); // Scaffold
  } // build

  Widget _buildSizePill(String size) {
    bool isSelected = selectedSize == size;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSize = size;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          size,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
            color: isSelected ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildColorDot(String colorName) {
    bool isSelected = selectedColor == colorName;
    Color color = _getColorFromName(colorName);
    bool hasBorder = color == Colors.white;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = colorName;
        });
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: hasBorder ? Border.all(color: AppTheme.textLight.withValues(alpha: 0.2)) : null,
        ),
        child: isSelected
            ? Icon(Icons.check, size: 14, color: color == Colors.white ? Colors.black : Colors.white)
            : null,
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

  Widget _buildShareOption(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark),
        ),
      ],
    );
  }
}
