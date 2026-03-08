import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/vendor/vendor_add_item_screen.dart';

class VendorInventoryScreen extends StatefulWidget {
  const VendorInventoryScreen({super.key});

  @override
  State<VendorInventoryScreen> createState() => _VendorInventoryScreenState();
}

class _VendorInventoryScreenState extends State<VendorInventoryScreen> {
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> items = [
    {
      'name': 'Premium Hoodie',
      'price': '₹295/day',
      'quantity': 8,
      'rating': 4.9,
      'image': 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?q=80&w=300&auto=format&fit=crop',
      'status': 'Active',
    },
    {
      'name': 'Denim Jacket',
      'price': '₹350/day',
      'quantity': 5,
      'rating': 4.7,
      'image': 'https://images.unsplash.com/photo-1516257984-b1b4d707412e?q=80&w=300&auto=format&fit=crop',
      'status': 'Active',
    },
    {
      'name': 'Casual T-Shirt',
      'price': '₹150/day',
      'quantity': 12,
      'rating': 4.5,
      'image': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=300&auto=format&fit=crop',
      'status': 'Active',
    },
    {
      'name': 'Summer Dress',
      'price': '₹400/day',
      'quantity': 3,
      'rating': 4.8,
      'image': 'https://images.unsplash.com/photo-1618932260643-eee4a2f652a6?q=80&w=300&auto=format&fit=crop',
      'status': 'Disabled',
    },
    {
      'name': 'Leather Jacket',
      'price': '₹500/day',
      'quantity': 2,
      'rating': 4.6,
      'image': 'https://images.unsplash.com/photo-1551028719-00167b16eac5?q=80&w=300&auto=format&fit=crop',
      'status': 'Active',
    },
  ];

  List<Map<String, dynamic>> get filteredItems {
    if (selectedFilter == 'All') return items;
    if (selectedFilter == 'Active') return items.where((i) => i['status'] == 'Active').toList();
    if (selectedFilter == 'Disabled') return items.where((i) => i['status'] == 'Disabled').toList();
    if (selectedFilter == 'Low Stock') return items.where((i) => (i['quantity'] as int) < 5).toList();
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'INVENTORY',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(FluentIcons.search_24_regular, color: AppTheme.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Active', 'Disabled', 'Low Stock'].map((filter) {
                  final isSelected = selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => selectedFilter = filter),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.textDark : const Color(0xFFF6F8FA),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        filter,
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
          ),

          // Items count
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredItems.length} Items',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.textLight.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.arrow_sort_24_regular, size: 14, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Text('Sort', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Items list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) => _buildItemCard(filteredItems[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: AppTheme.primaryLime.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorAddItemScreen()));
          },
          backgroundColor: AppTheme.primaryLime,
          elevation: 0,
          label: Text('Add Item', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          icon: const Icon(FluentIcons.add_24_regular, color: AppTheme.textDark),
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final isDisabled = item['status'] == 'Disabled';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textLight.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item['image'],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['name'],
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: isDisabled ? AppTheme.textLight : AppTheme.textDark),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDisabled ? Colors.grey.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        item['status'],
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDisabled ? Colors.grey : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(item['price'], style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF2E8A99))),
                    const SizedBox(width: 12),
                    Text('Qty: ${item['quantity']}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
                    const SizedBox(width: 12),
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text('${item['rating']}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildMiniAction('Edit', FluentIcons.edit_24_regular),
                    const SizedBox(width: 8),
                    _buildMiniAction(isDisabled ? 'Enable' : 'Disable', FluentIcons.eye_off_24_regular),
                    const SizedBox(width: 8),
                    _buildMiniAction('Delete', FluentIcons.delete_24_regular, isDestructive: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAction(String label, IconData icon, {bool isDestructive = false}) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withOpacity(0.05) : const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: isDestructive ? Colors.red : AppTheme.textLight),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: isDestructive ? Colors.red : AppTheme.textLight),
            ),
          ],
        ),
      ),
    );
  }
}
