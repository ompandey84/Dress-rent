import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'PRODUCT DETAILS',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(FluentIcons.cart_24_regular, color: AppTheme.textDark),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Image
                    CachedNetworkImage(
                      imageUrl: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?q=80&w=800&auto=format&fit=crop', // Hoodie placeholder
                      height: 350,
                      width: double.infinity,
                      fit: BoxFit.cover,
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dubai Marina',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textLight),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'PREMIUM HOODIE',
                                    style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                                  ),
                                ],
                              ),
                              Text(
                                'AED 295.00',
                                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primaryLime), // In design it's lime/blue depending on mode. Looks blueish here. Let's use primary lime or primary color. Actually design uses a blueish tint for price `AED 295.00` `Color(0xFF5CA8B5)`
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 16, color: AppTheme.textDark), // Black star in design
                                  const SizedBox(width: 4),
                                  Text(
                                    '4.9',
                                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '| 50 reviews',
                                    style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.textLight.withOpacity(0.2)),
                                ),
                                child: const Icon(FluentIcons.chat_24_regular, size: 20, color: AppTheme.textDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 24),
                          
                          // Store details
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                                child: Center(
                                  child: Text('ZARA', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
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
                                          'ZARA Brand Store',
                                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.verified, size: 14, color: Colors.blue),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(FluentIcons.location_24_regular, size: 12, color: AppTheme.textLight),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Dubai Marina',
                                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryLime,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          const SizedBox(height: 24),
                          
                          // Product Description
                          Text(
                            'Product Description',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(fontSize: 14, height: 1.5, color: AppTheme.textLight),
                              children: [
                                const TextSpan(text: 'Upgrade your wardrobe with our Premium Hoodie, crafted for comfort, style, and durability... '),
                                TextSpan(
                                  text: 'Read More',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.textDark),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Size
                          Text(
                            'Size',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildSizePill('16.5"', false),
                              const SizedBox(width: 12),
                              _buildSizePill('22.4"', false),
                              const SizedBox(width: 12),
                              _buildSizePill('24.2"', false),
                              const SizedBox(width: 12),
                              _buildSizePill('28.4"', true),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Color Selector
                          Row(
                            children: [
                              _buildColorDot(Colors.black, true),
                              const SizedBox(width: 12),
                              _buildColorDot(Colors.brown.shade800, false),
                              const SizedBox(width: 12),
                              _buildColorDot(Colors.grey, false),
                              const SizedBox(width: 12),
                              _buildColorDot(Colors.white, false, hasBorder: true),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Actions
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -5), blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        side: const BorderSide(color: AppTheme.textDark, width: 1.5),
                      ),
                      child: Text(
                        'MAKE AN OFFER',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryLime,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        elevation: 0,
                      ),
                      child: Text(
                        'BUY IT NOW',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizePill(String size, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.darkBackground : Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: isSelected ? null : Border.all(color: AppTheme.textLight.withOpacity(0.2)),
      ),
      child: Text(
        size,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          color: isSelected ? Colors.white : AppTheme.textDark,
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color, bool isSelected, {bool hasBorder = false}) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: hasBorder ? Border.all(color: AppTheme.textLight.withOpacity(0.2)) : null,
      ),
      child: isSelected
          ? Icon(Icons.check, size: 14, color: color == Colors.white ? Colors.black : Colors.white)
          : null,
    );
  }
}
