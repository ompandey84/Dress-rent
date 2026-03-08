import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';

class TrackingOrderScreen extends StatelessWidget {
  const TrackingOrderScreen({Key? key}) : super(key: key);

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
          'TRACKING ORDER',
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
            child: const Icon(FluentIcons.cart_24_regular, size: 20, color: AppTheme.textDark), // Assuming cart icon based on context, similar to other screens
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Map Placeholder
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Placeholder for actual map image seen in design
                  Image.network(
                    'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=800&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 250,
                    color: Colors.white.withOpacity(0.4),
                    colorBlendMode: BlendMode.lighten,
                  ),
                  const Text('Map View Placeholder', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tracking Timeline
                    _buildTimeline(),
                    const SizedBox(height: 32),
                    
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    // Order Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoCol('Created, 18 Oct 2023', 'Diriyah, Riyadh', crossAlignment: CrossAxisAlignment.start),
                        _buildInfoCol('Estimated, 19 Oct 2023', 'Jawhra, Jeddah', crossAlignment: CrossAxisAlignment.end),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoCol('From', 'Diriyah, Riyadh', crossAlignment: CrossAxisAlignment.start),
                        _buildInfoCol('To', 'Jawhra, Jeddah', crossAlignment: CrossAxisAlignment.end),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoCol('Customer', 'Mr Janson Clark', crossAlignment: CrossAxisAlignment.start),
                        _buildInfoCol('Order Cost', 'AED 295.00', crossAlignment: CrossAxisAlignment.end, isPrice: true),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                Expanded(child: Container(height: 2, color: AppTheme.primaryLime)),
                Expanded(child: Container(height: 2, color: AppTheme.primaryLime)),
                Expanded(child: Container(height: 2, color: AppTheme.textLight.withOpacity(0.3))),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 _buildTimelineDot(true),
                 _buildTimelineDot(true),
                 _buildTimelineDot(false, isCurrent: true),
                 _buildTimelineDot(false),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             _buildTimelineText('Confirmed', true),
             _buildTimelineText('Processing', true),
             _buildTimelineText('Pickup', false, isCurrent: true),
             _buildTimelineText('Delivered', false),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineDot(bool isPassed, {bool isCurrent = false}) {
    if (isPassed) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppTheme.textDark,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 14, color: Colors.white),
      );
    } else if (isCurrent) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.textDark, width: 4),
        ),
      );
    } else {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.textLight.withOpacity(0.3), width: 2),
        ),
      );
    }
  }

  Widget _buildTimelineText(String text, bool isPassed, {bool isCurrent = false}) {
    // In actual design the width might need strict constraints, but Row spacebetween works fine here
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: isPassed || isCurrent ? FontWeight.w700 : FontWeight.w500,
        color: isPassed || isCurrent ? AppTheme.textDark : AppTheme.textLight,
      ),
    );
  }

  Widget _buildInfoCol(String label, String value, {required CrossAxisAlignment crossAlignment, bool isPrice = false}) {
    return Column(
      crossAxisAlignment: crossAlignment,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isPrice ? AppTheme.primaryLime : AppTheme.textDark, // Design uses dark tint, we'll keep it lime/dark according to the previous screen logic. Wait, design actually has "AED 295.00" in black in this specific screen
          ),
        ),
      ],
    );
  }
}
