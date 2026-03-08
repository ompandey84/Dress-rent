import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';

class VendorRatingsScreen extends StatelessWidget {
  const VendorRatingsScreen({super.key});

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
          'RATINGS & REVIEWS',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Average Rating Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text('4.8', style: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < 4 ? Icons.star : Icons.star_half,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text('84 reviews', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight)),
                    ],
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: Column(
                      children: [
                        _buildRatingBar('5', 0.7, 58),
                        const SizedBox(height: 6),
                        _buildRatingBar('4', 0.2, 17),
                        const SizedBox(height: 6),
                        _buildRatingBar('3', 0.06, 5),
                        const SizedBox(height: 6),
                        _buildRatingBar('2', 0.02, 2),
                        const SizedBox(height: 6),
                        _buildRatingBar('1', 0.02, 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Review Analytics
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Review Analytics', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildAnalyticChip('Quality', '4.9', Colors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildAnalyticChip('Fit', '4.7', const Color(0xFF2E8A99))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildAnalyticChip('Value', '4.6', Colors.orange)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildAnalyticChip('Service', '4.9', Colors.purple)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Customer Reviews
            Text('Customer Reviews', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 16),
            _buildReviewCard(
              'Arafat Khan',
              5,
              '2 days ago',
              'Amazing quality hoodie! Fit perfectly and came well-packaged. Will definitely rent again.',
              response: 'Thank you so much, Arafat! Glad you loved it. 🙏',
            ),
            _buildReviewCard(
              'Sara Ahmed',
              4,
              '1 week ago',
              'Good denim jacket, slightly bigger than expected but overall great condition.',
              response: 'Thanks Sara! We have updated our size guide for better accuracy.',
            ),
            _buildReviewCard(
              'David Lee',
              5,
              '2 weeks ago',
              'Perfect for my event! Great quality and fast delivery. Highly recommend this vendor.',
            ),
            _buildReviewCard(
              'Priya Sharma',
              4,
              '3 weeks ago',
              'Nice dress, clean and well-maintained. Communication was quick and helpful.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(String star, double value, int count) {
    return Row(
      children: [
        Text(star, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textLight)),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: const Color(0xFFF6F8FA),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 20,
          child: Text('$count', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600), textAlign: TextAlign.right),
        ),
      ],
    );
  }

  Widget _buildAnalyticChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String name, int stars, String time, String review, {String? response}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.textLight.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FA),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.substring(0, 1),
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(i < stars ? Icons.star : Icons.star_border, color: Colors.amber, size: 14)),
                        const SizedBox(width: 8),
                        Text(time, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDark.withOpacity(0.8), height: 1.5)),
          if (response != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(FluentIcons.chat_24_regular, size: 16, color: Color(0xFF2E8A99)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vendor Response', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF2E8A99))),
                        const SizedBox(height: 4),
                        Text(response, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark.withOpacity(0.7), height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
