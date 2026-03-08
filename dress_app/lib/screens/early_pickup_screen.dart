import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';

class EarlyPickupScreen extends StatefulWidget {
  const EarlyPickupScreen({super.key});

  @override
  State<EarlyPickupScreen> createState() => _EarlyPickupScreenState();
}

class _EarlyPickupScreenState extends State<EarlyPickupScreen> {
  String? selectedReason;

  final List<String> reasons = [
    'I am done using the item early',
    'The item does not fit well',
    'Item is defective or damaged',
    'I ordered the wrong item by mistake',
    'Other reason'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular,
              color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'EARLY PICKUP',
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
              letterSpacing: 1.0),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
                left: 24, right: 24, top: 16, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request Early Pickup',
                  style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Need to return your items earlier than expected? Please let us know the reason.',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppTheme.textLight, height: 1.5),
                ),
                const SizedBox(height: 32),
                Text(
                  'Reason for early pickup',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark),
                ),
                const SizedBox(height: 16),
                ...reasons.map((reason) => _buildReasonOption(reason)).toList(),
                const SizedBox(height: 32),
                Text(
                  'Add Photos (Optional)',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'If the item is damaged, please attach a photo.',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppTheme.textLight),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildAddPhotoButton(),
                    const SizedBox(width: 12),
                    _buildImagePlaceholder(),
                  ],
                ),
              ],
            ),
          ),

          // Floating Bottom Button
          Positioned(
            bottom: 15, // 15px padding as specified in inspiration
            left: 24,
            right: 24,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: selectedReason != null
                    ? AppTheme.primaryLime
                    : const Color(0xFFF1F4F5),
                borderRadius: BorderRadius.circular(100),
                boxShadow: selectedReason != null
                    ? [
                        BoxShadow(
                            color: AppTheme.primaryLime.withOpacity(0.4),
                            offset: const Offset(0, 8),
                            blurRadius: 15),
                      ]
                    : [],
              ),
              child: ElevatedButton(
                onPressed: selectedReason != null
                    ? () {
                        Navigator.pop(
                            context); // Pop back for flow implementation
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Early pickup requested successfully!',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600)),
                            backgroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(20),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledForegroundColor: AppTheme.textLight,
                  disabledBackgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
                child: Center(
                  child: Text(
                    'SUBMIT REQUEST',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: selectedReason != null
                            ? AppTheme.textDark
                            : AppTheme.textLight.withOpacity(0.5)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonOption(String reason) {
    bool isSelected = selectedReason == reason;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedReason = reason;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? AppTheme.primaryLime.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryLime : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? AppTheme.primaryLime : Colors.grey.shade400,
                  width: isSelected ? 6 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                reason,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: AppTheme.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F5),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FluentIcons.camera_add_24_regular,
              color: AppTheme.textDark),
          const SizedBox(height: 4),
          Text(
            'Add',
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            'https://images.unsplash.com/photo-1542272604-787c3835535d?q=80&w=200&auto=format&fit=crop',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(FluentIcons.dismiss_12_regular,
                color: Colors.white, size: 12),
          ),
        ),
      ],
    );
  }
}
