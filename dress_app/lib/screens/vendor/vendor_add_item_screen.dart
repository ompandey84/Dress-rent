import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';

class VendorAddItemScreen extends StatefulWidget {
  const VendorAddItemScreen({super.key});

  @override
  State<VendorAddItemScreen> createState() => _VendorAddItemScreenState();
}

class _VendorAddItemScreenState extends State<VendorAddItemScreen> {
  String selectedCategory = 'Casual';
  String selectedGender = 'Unisex';
  Set<String> selectedSizes = {'M', 'L'};
  final List<String> uploadedImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ADD NEW ITEM',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Media Upload Section
                _buildSectionLabel('Media Upload'),
                const SizedBox(height: 12),
                _buildMediaUpload(),
                const SizedBox(height: 28),

                // Dress Details
                _buildSectionLabel('Dress Details'),
                const SizedBox(height: 16),
                _buildTextField('Dress Name', 'Enter dress name', FluentIcons.tag_24_regular),
                const SizedBox(height: 16),

                // Category
                Text('Category', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Casual', 'Formal', 'Party', 'Wedding', 'Traditional', 'Streetwear'].map((cat) {
                      final isSelected = selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => selectedCategory = cat),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.textDark : const Color(0xFFF6F8FA),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            cat,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppTheme.textLight,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Gender
                Text('Gender', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                const SizedBox(height: 8),
                Row(
                  children: ['Male', 'Female', 'Unisex'].map((g) {
                    final isSelected = selectedGender == g;
                    return GestureDetector(
                      onTap: () => setState(() => selectedGender = g),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.textDark : const Color(0xFFF6F8FA),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          g,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppTheme.textLight,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // Pricing
                _buildSectionLabel('Pricing'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Rental Price/Day', '₹0', FluentIcons.money_24_regular, keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField('Security Deposit', '₹0', FluentIcons.shield_24_regular, keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 28),

                // Size Options
                _buildSectionLabel('Size Options'),
                const SizedBox(height: 12),
                Row(
                  children: ['S', 'M', 'L', 'XL'].map((size) {
                    final isSelected = selectedSizes.contains(size);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedSizes.remove(size);
                          } else {
                            selectedSizes.add(size);
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.textDark : const Color(0xFFF6F8FA),
                          borderRadius: BorderRadius.circular(14),
                          border: isSelected ? null : Border.all(color: AppTheme.textLight.withOpacity(0.2)),
                        ),
                        child: Center(
                          child: Text(
                            size,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : AppTheme.textDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Quantity per selected size
                if (selectedSizes.isNotEmpty) ...[
                  Text('Quantity per Size', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                  const SizedBox(height: 12),
                  ...selectedSizes.map((size) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.textDark,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(size, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F8FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Enter quantity',
                                hintStyle: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                const SizedBox(height: 28),

                // Availability Settings
                _buildSectionLabel('Availability Settings'),
                const SizedBox(height: 16),
                _buildDatePicker('Available From', 'Select start date'),
                const SizedBox(height: 12),
                _buildDatePicker('Available Until', 'Select end date'),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: Row(
                    children: [
                      const Icon(FluentIcons.info_24_regular, color: Colors.amber, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Blackout dates can be managed from the Availability Calendar after publishing.',
                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark.withOpacity(0.7), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating bottom button
          Positioned(
            bottom: 15,
            left: 24,
            right: 24,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryLime,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryLime.withOpacity(0.3), offset: const Offset(0, 8), blurRadius: 15),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Listing published successfully!', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: Center(
                  child: Text(
                    'PUBLISH LISTING',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
    );
  }

  Widget _buildMediaUpload() {
    return Column(
      children: [
        // Image upload area
        if (uploadedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: uploadedImages.length + 1,
              itemBuilder: (context, index) {
                if (index == uploadedImages.length) {
                  return GestureDetector(
                    onTap: () => setState(() => uploadedImages.add('https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=300&auto=format&fit=crop')),
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.textLight.withOpacity(0.2)),
                      ),
                      child: const Center(child: Icon(FluentIcons.image_add_24_regular, color: AppTheme.textLight)),
                    ),
                  );
                }
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(uploadedImages[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => uploadedImages.removeAt(index)),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          GestureDetector(
            onTap: () => setState(() => uploadedImages.add('https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=300&auto=format&fit=crop')),
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.textLight.withOpacity(0.2), style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E8A99).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(FluentIcons.image_add_24_regular, color: Color(0xFF2E8A99), size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text('Upload Images', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                  const SizedBox(height: 4),
                  Text('PNG, JPG up to 5MB', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        // Video upload row
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8FA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(FluentIcons.video_24_regular, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upload Product Video', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                    Text('Optional • MP4 up to 30MB', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppTheme.textLight.withOpacity(0.2)),
                ),
                child: Text('Browse', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8FA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(icon, color: AppTheme.textLight, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, String hint) {
    return GestureDetector(
      onTap: () async {
        await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8FA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(FluentIcons.calendar_24_regular, color: AppTheme.textLight, size: 20),
                const SizedBox(width: 12),
                Text(hint, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
