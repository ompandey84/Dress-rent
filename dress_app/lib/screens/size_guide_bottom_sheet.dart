import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';

class SizeGuideBottomSheet extends StatelessWidget {
  const SizeGuideBottomSheet({super.key});

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
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Size Guide',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textDark),
              ),
              IconButton(
                icon: const Icon(FluentIcons.dismiss_24_regular, color: AppTheme.textDark),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Use this guide to determine your best fit. All measurements are in inches.',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
          ),
          const SizedBox(height: 24),
          _buildSizeTableRow('Size', 'Bust', 'Waist', 'Hip', isHeader: true),
          _buildSizeTableRow('XS (0-2)', '32 - 33', '24 - 25', '34 - 35'),
          _buildSizeTableRow('S (4-6)', '34 - 35', '26 - 27', '36 - 37'),
          _buildSizeTableRow('M (8-10)', '36 - 37', '28 - 29', '38 - 39'),
          _buildSizeTableRow('L (12-14)', '38 - 40', '30 - 32', '40 - 42'),
          _buildSizeTableRow('XL (16)', '41 - 43', '33 - 35', '43 - 45'),
          const SizedBox(height: 24),
          Text(
            'How to Measure',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          _buildMeasureInstruction('Bust', 'Measure around the fullest part of your bust.'),
          _buildMeasureInstruction('Waist', 'Measure around the narrowest part of your torso.'),
          _buildMeasureInstruction('Hip', 'Measure around the fullest part of your hips/glutes.'),
        ],
      ),
    );
  }

  Widget _buildSizeTableRow(String col1, String col2, String col3, String col4, {bool isHeader = false}) {
    final style = GoogleFonts.inter(
      fontSize: 13,
      fontWeight: isHeader ? FontWeight.w800 : FontWeight.w500,
      color: isHeader ? AppTheme.textDark : AppTheme.textLight,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.textLight.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(col1, style: style)),
          Expanded(flex: 1, child: Text(col2, style: style, textAlign: TextAlign.center)),
          Expanded(flex: 1, child: Text(col3, style: style, textAlign: TextAlign.center)),
          Expanded(flex: 1, child: Text(col4, style: style, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildMeasureInstruction(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
                children: [
                  TextSpan(text: '$title: ', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
