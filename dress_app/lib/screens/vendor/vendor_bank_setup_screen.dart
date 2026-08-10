import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/vendor/vendor_verification_screen.dart';

/// Page 3 of 3 — Bank / Payout Details.
/// Steps: 1. Basic Info → 2. Business Info → 3. Bank / Payout
class VendorBankSetupScreen extends StatelessWidget {
  const VendorBankSetupScreen({super.key});

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
          'BANK / PAYOUT',
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
                // Step Indicator
                _buildStepIndicator(),
                const SizedBox(height: 20),

                _buildSectionHeader(
                  'Bank Account',
                  FluentIcons.wallet_24_regular,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'Account Holder Name',
                  'As on bank records',
                  FluentIcons.person_24_regular,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  'Bank Account Number',
                  'Enter account number',
                  FluentIcons.lock_closed_24_regular,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  'IFSC Code',
                  'Enter IFSC code',
                  FluentIcons.document_24_regular,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  'Bank Name',
                  'Enter bank name',
                  FluentIcons.building_bank_24_regular,
                ),

                const SizedBox(height: 20),

                _buildSectionHeader(
                  'UPI (Optional)',
                  FluentIcons.payment_24_regular,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'UPI ID',
                  'e.g. name@bank',
                  FluentIcons.payment_24_regular,
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        FluentIcons.shield_checkmark_24_regular,
                        color: Color(0xFF2E8A99),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your data is encrypted. We only use it for verification and payouts.',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.textLight,
                            height: 1.4,
                          ),
                        ),
                      ),
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
                      builder: (_) => const VendorVerificationScreen(),
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
                    'SUBMIT FOR VERIFICATION',
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

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _stepCircle(Icons.check, true),
        _stepLine(true),
        _stepCircle(Icons.check, true),
        _stepLine(true),
        _stepCircle('3', true),
        const SizedBox(width: 8),
        Text(
          'Step 3 of 3 — Payout',
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

  Widget _stepCircle(dynamic content, bool isActive) {
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
      child: content is IconData
          ? Icon(content, color: Colors.white, size: 14)
          : Text(
              content.toString(),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.textDark, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
      ],
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
}
