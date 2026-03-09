import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/widgets/custom_text_field.dart';
import 'package:dress_app/models/product.dart';

class ShippingAddressScreen extends StatefulWidget {
  final Product product;
  const ShippingAddressScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();

  bool _isDetectingLocation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _detectLocation() async {
    setState(() => _isDetectingLocation = true);
    
    // Mock network/GPS delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _addressController.text = '123 Sheikh Zayed Road, Downtown';
        _cityController.text = 'Dubai';
        _zipController.text = '00000';
        _isDetectingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location detected: Dubai, UAE')),
      );
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Discard Address?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppTheme.textDark),
        ),
        content: Text(
          'Are you sure you want to clear all address fields?',
          style: GoogleFonts.inter(color: AppTheme.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.textLight)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _nameController.clear();
                _phoneController.clear();
                _addressController.clear();
                _cityController.clear();
                _zipController.clear();
              });
              Navigator.pop(context);
            },
            child: Text('DISCARD', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.red)),
          ),
        ],
      ),
    );
  }

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
          GestureDetector(
            onTap: _confirmDelete,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.textLight.withOpacity(0.2)),
              ),
              child: const Icon(FluentIcons.delete_24_regular, size: 20, color: AppTheme.textDark),
            ),
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
                          child: widget.product.images.isNotEmpty ? CachedNetworkImage(
                            imageUrl: widget.product.images.first,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ) : Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade200,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.product.category, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight)),
                              const SizedBox(height: 4),
                              Text(widget.product.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 14, color: AppTheme.textDark),
                                  const SizedBox(width: 4),
                                  Text(widget.product.rating.toString(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                                  Text(' | ${widget.product.reviewsCount} reviews', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text('AED ${widget.product.price.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primaryLime)),
                                  const SizedBox(width: 8),
                                  if (widget.product.originalPrice > 0.0) 
                                    Text(
                                      'AED ${widget.product.originalPrice.toStringAsFixed(2)}', 
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
                    
                    GestureDetector(
                      onTap: _isDetectingLocation ? null : _detectLocation,
                      child: Container(
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
                            _isDetectingLocation 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryLime))
                              : const Icon(FluentIcons.my_location_24_regular, color: AppTheme.primaryLime, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _isDetectingLocation ? 'Detecting Location...' : 'Detect current location',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryLime),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    CustomTextField(controller: _nameController, label: 'Full Name', hintText: 'Enter your full name'),
                    const SizedBox(height: 16),
                    CustomTextField(controller: _phoneController, label: 'Phone Number', hintText: 'Enter phone number'),
                    const SizedBox(height: 16),
                    CustomTextField(controller: _addressController, label: 'Address', hintText: 'Enter exact location or street'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: CustomTextField(controller: _cityController, label: 'City', hintText: 'Enter city')),
                        const SizedBox(width: 16),
                        Expanded(child: CustomTextField(controller: _zipController, label: 'ZIP-Code', hintText: 'Enter ZIP-Code')),
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
                    if (_nameController.text.isNotEmpty && _addressController.text.isNotEmpty) {
                      Navigator.pop(context, {
                        'name': _nameController.text,
                        'phone': _phoneController.text,
                        'title': 'New Address',
                        'address': '${_addressController.text}, ${_cityController.text}',
                        'icon': FluentIcons.location_24_regular,
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter name and address')));
                    }
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
