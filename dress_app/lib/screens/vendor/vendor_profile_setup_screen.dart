import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/vendor/vendor_verification_screen.dart';

class VendorProfileSetupScreen extends StatelessWidget {
  const VendorProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'VENDOR PROFILE',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Indicator
                Row(
                  children: [
                    _buildStepIndicator('1', 'Basic Info', true, isDone: true),
                    Expanded(child: Container(height: 2, color: AppTheme.primaryLime)),
                    _buildStepIndicator('2', 'Business', true),
                    Expanded(child: Container(height: 2, color: AppTheme.textLight.withOpacity(0.2))),
                    _buildStepIndicator('3', 'Verify', false),
                  ],
                ),
                const SizedBox(height: 32),

                // Business Information Section
                _buildSectionHeader('Business Information', FluentIcons.building_24_regular),
                const SizedBox(height: 20),
                _buildTextField('Vendor Name', 'Enter your vendor name', FluentIcons.person_24_regular),
                const SizedBox(height: 16),
                _buildTextField('Business Name', 'Enter business name', FluentIcons.building_24_regular),
                const SizedBox(height: 16),
                _buildTextField('Phone Number', 'Enter phone number', FluentIcons.call_24_regular, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildTextField('Email', 'Enter business email', FluentIcons.mail_24_regular, keyboardType: TextInputType.emailAddress),

                const SizedBox(height: 32),

                // Business Address Section
                _buildSectionHeader('Business Address', FluentIcons.location_24_regular),
                const SizedBox(height: 20),
                _buildTextField('Shop / Warehouse', 'Enter shop or warehouse address', FluentIcons.home_24_regular),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField('City', 'City', FluentIcons.city_24_regular)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField('State', 'State', FluentIcons.map_24_regular)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField('Pincode', 'Enter pincode', FluentIcons.number_symbol_24_regular, keyboardType: TextInputType.number),

                const SizedBox(height: 32),

                // Bank / Payout Details Section
                _buildSectionHeader('Bank / Payout Details', FluentIcons.wallet_24_regular),
                const SizedBox(height: 20),
                _buildTextField('Account Holder Name', 'Enter account holder name', FluentIcons.person_24_regular),
                const SizedBox(height: 16),
                _buildTextField('Bank Account Number', 'Enter account number', FluentIcons.lock_closed_24_regular, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField('IFSC Code', 'Enter IFSC code', FluentIcons.document_24_regular),
                const SizedBox(height: 16),
                _buildTextField('UPI ID', 'Enter UPI ID (optional)', FluentIcons.payment_24_regular),

                const SizedBox(height: 24),

                // Security Note
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(FluentIcons.shield_checkmark_24_regular, color: Color(0xFF2E8A99), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your data is encrypted and secured. We only use it for verification & payouts.',
                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, height: 1.4),
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
            left: 24,
            right: 24,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryLime,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryLime.withOpacity(0.3), offset: const Offset(0, 8), blurRadius: 15),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorVerificationScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: Center(
                  child: Text(
                    'SUBMIT VERIFICATION',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8FA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.textDark, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(String number, String label, bool isActive, {bool isDone = false}) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.textDark : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppTheme.textDark : AppTheme.textLight.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    number,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isActive ? Colors.white : AppTheme.textLight,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppTheme.textDark : AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8FA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(icon, color: AppTheme.textLight, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
