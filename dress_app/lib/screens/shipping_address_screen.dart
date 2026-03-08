import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/widgets/custom_text_field.dart';

class ShippingAddressScreen extends StatelessWidget {
  const ShippingAddressScreen({Key? key}) : super(key: key);

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
          'SHIPPING ADDRESS',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.textLight.withOpacity(0.2)),
            ),
            child: const Icon(FluentIcons.delete_24_regular, size: 20, color: AppTheme.textDark),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Summary snippet seen in the design
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=200&auto=format&fit=crop',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fashion', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight)),
                              const SizedBox(height: 4),
                              Text('Classic Streetwear', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 14, color: AppTheme.textDark),
                                  const SizedBox(width: 4),
                                  Text('4.9', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                                  Text(' | 50 reviews', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text('AED 295.00', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primaryLime)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'AED 350.00', 
                                    style: GoogleFonts.inter(
                                      fontSize: 12, 
                                      color: AppTheme.textLight, 
                                      decoration: TextDecoration.lineThrough
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    Text('Delivery Address', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                    const SizedBox(height: 16),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLime.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryLime.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(FluentIcons.my_location_24_regular, color: AppTheme.primaryLime, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Detect current location',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryLime),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    const CustomTextField(label: 'Full Name', hintText: 'Enter your full name'),
                    const SizedBox(height: 16),
                    const CustomTextField(label: 'Phone Number', hintText: 'Enter phone number'),
                    const SizedBox(height: 16),
                    const CustomTextField(label: 'Address', hintText: 'Enter exact location or street'),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Expanded(child: CustomTextField(label: 'City', hintText: 'Enter city')),
                        SizedBox(width: 16),
                        Expanded(child: CustomTextField(label: 'ZIP-Code', hintText: 'Enter ZIP-Code')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Action
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 15),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryLime,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    elevation: 0,
                  ),
                  child: Text(
                    'SAVE ADDRESS',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
