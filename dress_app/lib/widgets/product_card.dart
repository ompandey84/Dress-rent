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
    String title = product.name;
    String location = product.location;
    String price = '₹${product.price.toStringAsFixed(0)}';
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
                  height: imageHeight,
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
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
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
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  location,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
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
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                    height: 1.25,
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
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.star, size: 12, color: Colors.amber),
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
