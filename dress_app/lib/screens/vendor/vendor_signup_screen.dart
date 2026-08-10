import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/vendor/vendor_business_setup_screen.dart';

/// Page 1 of 3 — Basic Info (the user themselves).
/// Steps: 1. Basic Info → 2. Business Info → 3. Bank / Payout
class VendorSignupScreen extends StatelessWidget {
  const VendorSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            FluentIcons.chevron_left_24_regular,
            color: AppTheme.textDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'BECOME A VENDOR',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: 120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Intro Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E8A99).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          FluentIcons.person_24_regular,
                          color: Color(0xFF2E8A99),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tell us about you',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Step 1 of 3 — your basic contact details.',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppTheme.textLight,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Steps Indicator
                _buildStepIndicator('1', 'Basic', true),
                const SizedBox(height: 20),

                Text(
                  'Personal Details',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),

                _buildTextField(
                  'Full Name',
                  'Enter your full name',
                  FluentIcons.person_24_regular,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  'Email Address',
                  'Enter your email',
                  FluentIcons.mail_24_regular,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  'Phone Number',
                  'Enter your phone number',
                  FluentIcons.call_24_regular,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFFE082),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            'Why become a vendor?',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildBenefitRow('Earn from your idle wardrobe'),
                      const SizedBox(height: 5),
                      _buildBenefitRow('Set your own rental prices'),
                      const SizedBox(height: 5),
                      _buildBenefitRow('Full control over availability'),
                      const SizedBox(height: 5),
                      _buildBenefitRow('Secure payment & easy payouts'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Bottom Button
          Positioned(
            bottom: 15,
            left: 20,
            right: 20,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryLime,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryLime.withOpacity(0.3),
                    offset: const Offset(0, 8),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VendorBusinessSetupScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Center(
                  child: Text(
                    'NEXT: BUSINESS DETAILS',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(String number, String label, bool isActive) {
    return Row(
      children: [
        _stepCircle(number, true),
        _stepLine(false),
        _stepCircle('2', false),
        _stepLine(false),
        _stepCircle('3', false),
        const SizedBox(width: 8),
        Text(
          'Step 1 of 3 — $label',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _stepCircle(String n, bool isActive) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.textDark : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppTheme.textDark : AppTheme.textLight.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        n,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: isActive ? Colors.white : AppTheme.textLight,
        ),
      ),
    );
  }

  Widget _stepLine(bool done) {
    return Expanded(
      child: Container(
        height: 1.5,
        color: done ? AppTheme.textDark : AppTheme.textLight.withOpacity(0.3),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            keyboardType: keyboardType,
            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textLight,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: AppTheme.textLight,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitRow(String text) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle,
          color: Color(0xFF2E8A99),
          size: 14,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
