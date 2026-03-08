import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';

class FiltersBottomSheet extends StatefulWidget {
  const FiltersBottomSheet({super.key});

  @override
  State<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<FiltersBottomSheet> {
  // Mock filter state
  RangeValues _priceRange = const RangeValues(100, 1500);
  String _selectedCategory = 'Dresses';
  final List<String> _categories = ['All', 'Dresses', 'Suits', 'Accessories', 'Traditional'];
  
  final List<String> _selectedSizes = ['S', 'M'];
  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  final List<String> _selectedBrands = ['ZARA', 'H&M'];
  final List<String> _brands = ['ZARA', 'H&M', 'Gucci', 'Prada', 'Mango', 'Givenchy'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Takes only needed height up to max
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textDark),
              ),
              IconButton(
                icon: const Icon(FluentIcons.dismiss_24_regular, color: AppTheme.textDark),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  _buildSectionTitle('Category'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        bool isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              cat,
                              style: GoogleFonts.inter(
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : AppTheme.textDark,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppTheme.textDark,
                            backgroundColor: const Color(0xFFF6F8FA),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            onSelected: (val) {
                              if (val) setState(() => _selectedCategory = cat);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Price Range
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Price Range'),
                      Text(
                        'AED ${_priceRange.start.toInt()} - AED ${_priceRange.end.toInt()}',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryLime),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 5000,
                    divisions: 100,
                    activeColor: AppTheme.primaryLime,
                    inactiveColor: const Color(0xFFEAF1F5),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Size
                  _buildSectionTitle('Size'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sizes.map((size) {
                      bool isSelected = _selectedSizes.contains(size);
                      return FilterChip(
                        label: Text(
                          size,
                          style: GoogleFonts.inter(
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : AppTheme.textDark,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryLime,
                        backgroundColor: const Color(0xFFF6F8FA),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _selectedSizes.add(size);
                            } else {
                              _selectedSizes.remove(size);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Brands
                  _buildSectionTitle('Brand'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _brands.map((brand) {
                      bool isSelected = _selectedBrands.contains(brand);
                      return FilterChip(
                        label: Text(
                          brand,
                          style: GoogleFonts.inter(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppTheme.textDark,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppTheme.textDark,
                        backgroundColor: const Color(0xFFF6F8FA),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        showCheckmark: false,
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _selectedBrands.add(brand);
                            } else {
                              _selectedBrands.remove(brand);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Reset filters
                    setState(() {
                      _priceRange = const RangeValues(0, 5000);
                      _selectedCategory = 'All';
                      _selectedSizes.clear();
                      _selectedBrands.clear();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    side: BorderSide(color: AppTheme.textLight.withOpacity(0.3)),
                  ),
                  child: Text(
                    'RESET',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'category': _selectedCategory,
                      'priceRange': _priceRange,
                      'sizes': _selectedSizes,
                      'brands': _selectedBrands,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryLime,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Text(
                    'APPLY FILTERS',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
      ),
    );
  }
}
