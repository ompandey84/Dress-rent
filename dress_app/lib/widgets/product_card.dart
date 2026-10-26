import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/product_details_screen.dart';
import 'package:dress_app/widgets/favorite_button.dart';

class ProductCard extends StatelessWidget {
  final dynamic product;
  final double imageHeight;

  const ProductCard({
    Key? key,
    required this.product,
    required this.imageHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = product.name ?? '';
    final String location = product.location ?? '';
    final double price = (product.price ?? 0).toDouble();
    final String rating =
        (product.rating ?? 0).toStringAsFixed(1);
    final String imgUrl =
        product.images.isNotEmpty ? product.images.first : '';
    final bool isVerified = product.isVerifiedStore ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with overlaid heart + price pill — no gap below image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                _ProductImage(
                  imageUrl: imgUrl,
                  height: imageHeight,
                ),
                // Heart top-right
                Positioned(
                  top: 8,
                  right: 8,
                  child: FavoriteButton(productId: product.id ?? ''),
                ),
                // Price pill — overlaid on bottom-right inside the image
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLime,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '₹${price.toStringAsFixed(0)}',
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
          ),
          // Tiny gap only — 90% smaller than before
          const SizedBox(height: 6),
          // Location + verified badge
          Row(
            children: [
              Expanded(
                child: Text(
                  location,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, size: 11, color: Colors.green),
              ],
            ],
          ),
          const SizedBox(height: 1),
          // Title + rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Row(
                children: [
                  Text(
                    rating,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(width: 1),
                  const Icon(Icons.star, size: 10, color: Colors.amber),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Image with proper placeholder + retry. Falls back to a friendly
/// gradient + dress icon when no URL is provided or the load fails.
class _ProductImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  const _ProductImage({required this.imageUrl, required this.height});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _placeholder(context);
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => _placeholder(context, loading: true),
      errorWidget: (_, __, ___) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context, {bool loading = false}) {
    return Container(
      height: height,
      width: double.infinity,
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
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.textLight,
              ),
            )
          : Icon(
              Icons.checkroom_outlined,
              size: height * 0.18,
              color: AppTheme.textLight.withOpacity(0.4),
            ),
    );
  }
}

// ImageCutoutClipper removed — price is now overlaid inside the image itself.
