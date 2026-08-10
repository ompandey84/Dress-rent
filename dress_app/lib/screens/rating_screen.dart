import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/booking.dart';
import 'package:dress_app/services/rating_service.dart';
import 'package:dress_app/screens/main_navigation.dart';
import 'package:dress_app/screens/ugc_share_screen.dart';

/// Post-rental rating screen — both renter & lender rate each other.
class RatingScreen extends StatefulWidget {
  final Booking? booking;
  final bool isLenderRating; // true if lender is rating the renter
  const RatingScreen({Key? key, this.booking, this.isLenderRating = false}) : super(key: key);

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _overall = 0;
  int _communication = 0;
  int _accuracy = 0;
  int _delivery = 0;
  final _review = TextEditingController();
  bool _submitting = false;
  bool _submitted = false;
  late List<String> _tags;

  final List<String> _lenderTags = [
    'Accurate description', 'Quick response', 'Item as described',
    'Beautiful outfit', 'Easy pickup', 'Great quality',
  ];
  final List<String> _renterTags = [
    'Returned on time', 'Careful with item', 'Communicative',
    'Easy to coordinate', 'Respected lender', 'Lovely renter',
  ];

  @override
  void initState() {
    super.initState();
    _tags = widget.isLenderRating ? _renterTags : _lenderTags;
  }

  Future<void> _submit() async {
    if (_overall == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tap a star to rate')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      // Determine ratee (mock fallback when booking is null)
      final booking = widget.booking;
      final rateeId = booking == null
          ? (widget.isLenderRating ? 'mock_renter' : 'mock_lender')
          : (widget.isLenderRating ? booking.renterId : booking.lenderId);

      if (booking != null) {
        await RatingService().submitRating(
          booking: booking,
          rateeId: rateeId,
          type: widget.isLenderRating ? 'lender_to_renter' : 'renter_to_lender',
          score: _overall,
          review: _review.text.isEmpty ? null : _review.text,
          communicationScore: widget.isLenderRating ? _communication : null,
          accuracyScore: widget.isLenderRating ? null : _accuracy,
          deliveryScore: widget.isLenderRating ? _delivery : null,
        );
      } else {
        // Mock path: just simulate a small delay
        await Future.delayed(const Duration(milliseconds: 600));
      }

      if (mounted) setState(() => _submitted = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _buildThankYou();
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FluentIcons.dismiss_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('RATE YOUR ${widget.isLenderRating ? 'RENTER' : 'LENDER'}',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Person card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: CachedNetworkImageProvider('https://i.pravatar.cc/150?img=33'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isLenderRating ? 'Aisha M.' : 'Arafat @ Street Style DXB',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.isLenderRating ? 'Renter' : 'Lender • ⭐ 4.8 (124 reviews)',
                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text('How was your experience?',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
            ),
            const SizedBox(height: 16),
            Center(child: _buildStarRow(_overall, (v) => setState(() => _overall = v))),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _getScoreLabel(_overall),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _overall == 0 ? AppTheme.textLight : AppTheme.textDark,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sub-ratings
            if (!widget.isLenderRating) ...[
              _buildSubRating('Item accuracy', 'Did the item match the listing?',
                  _accuracy, (v) => setState(() => _accuracy = v)),
              const SizedBox(height: 12),
            ] else ...[
              _buildSubRating('Communication', 'Were they easy to coordinate with?',
                  _communication, (v) => setState(() => _communication = v)),
              const SizedBox(height: 12),
              _buildSubRating('Care for item', 'Did they return it in good condition?',
                  _delivery, (v) => setState(() => _delivery = v)),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),

            // Quick tags
            Text('Quick tags (tap to add)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textLight, letterSpacing: 1.0)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((t) {
                final isSelected = _selectedTags.contains(t);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (isSelected) {
                      _selectedTags.remove(t);
                    } else {
                      _selectedTags.add(t);
                    }
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.textDark : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: isSelected ? AppTheme.textDark : Colors.grey.shade200),
                    ),
                    child: Text(
                      t,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Write a review (optional)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            TextField(
              controller: _review,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: widget.isLenderRating
                    ? 'How was the renter? Any highlights?'
                    : 'How was the outfit? Would you recommend?',
                hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.textDark, width: 2)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _overall > 0 ? AppTheme.textDark : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('SUBMIT REVIEW',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<String> _selectedTags = [];

  Widget _buildStarRow(int value, ValueChanged<int> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < value;
        return GestureDetector(
          onTap: () => onChanged(i + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              filled ? Icons.star : Icons.star_border,
              color: const Color(0xFFFBBC05),
              size: 44,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSubRating(String title, String subtitle, int value, ValueChanged<int> onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              final filled = i < value;
              return GestureDetector(
                onTap: () => onChanged(i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Icon(
                    filled ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFBBC05),
                    size: 22,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getScoreLabel(int score) {
    switch (score) {
      case 5: return 'Excellent! 🌟';
      case 4: return 'Great';
      case 3: return 'Good';
      case 2: return 'Could be better';
      case 1: return 'Not great';
      default: return 'Tap to rate';
    }
  }

  Widget _buildThankYou() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 80, color: Color(0xFFFBBC05)),
              const SizedBox(height: 24),
              Text('Thanks for your review!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text('Your feedback helps build a trusted community.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight, height: 1.4)),
              const SizedBox(height: 32),
              // UGC Prompt
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(FluentIcons.heart_circle_24_regular, color: AppTheme.primaryLime, size: 32),
                    const SizedBox(height: 8),
                    Text('Share your look & earn ₹100 credit',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Post a Reel wearing the outfit. We\'ll credit your account for the next rental.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.4)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const UgcShareScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryLime,
                          foregroundColor: AppTheme.textDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          elevation: 0,
                        ),
                        child: Text('Post a Reel', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Referral
              _ReferralRow(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainNavigation()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.textDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    elevation: 0,
                  ),
                  child: Text('DONE', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReferralRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(FluentIcons.gift_24_regular, color: Color(0xFFE65100), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Refer a friend, both get ₹200 credit',
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark, fontWeight: FontWeight.w800, height: 1.3),
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share your referral code: DRESS-200')),
              );
            },
            child: Text('Share', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFE65100), fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
