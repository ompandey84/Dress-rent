import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pinput/pinput.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/services/auth_service.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/screens/signup_screen.dart';
import 'package:dress_app/screens/main_navigation.dart';
import 'package:provider/provider.dart';

/// Phone + OTP login flow.
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isSending = false;
  bool _isVerifying = false;
  bool _otpSent = false;
  int _resendIn = 30;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendIn = (_resendIn - 1).clamp(0, 30));
      return _resendIn > 0;
    });
  }

  bool _isValidPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length == 10;
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (!_isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit phone number')),
      );
      return;
    }
    setState(() => _isSending = true);
    try {
      final fullPhone = '+91$phone'; // India default
      await AuthService().sendPhoneOtp(fullPhone);

      // In mock mode, fill in a default OTP for convenience
      if (!SupabaseService.isConfigured) {
        _otpController.text = '123456';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mock mode: use OTP 123456')),
        );
      }

      setState(() {
        _otpSent = true;
        _resendIn = 30;
        _startResendTimer();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the OTP')),
      );
      return;
    }
    setState(() => _isVerifying = true);
    try {
      final phone = '+91${_phoneController.text.trim()}';
      await AuthService().verifyOtp(phone: phone, otp: otp);

      // Update app state
      final appState = context.read<AppState>();
      await appState.refreshProfile();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid OTP: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              if (!_otpSent) _buildPhoneInput() else _buildOtpInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your\nphone number',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppTheme.textDark,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "We'll send you a verification code",
          style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textLight),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            Container(
              width: 80,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🇮🇳', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, color: AppTheme.textLight, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('+91',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                    ),
                    Container(width: 1, height: 24, color: Colors.grey.shade300),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                        decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          hintText: '98765 43210',
                          hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSending ? null : _sendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.textDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              elevation: 0,
            ),
            child: _isSending
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Continue',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('or ', style: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 14)),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
              child: Text('Sign up with Email',
                  style: GoogleFonts.inter(color: AppTheme.textDark, fontWeight: FontWeight.w800, fontSize: 14)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify\nyour number',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppTheme.textDark,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            text: 'Enter the 6-digit code we sent to\n',
            style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textLight),
            children: [
              TextSpan(
                text: '+91 ${_phoneController.text}',
                style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textDark, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Pinput(
          controller: _otpController,
          length: 6,
          autofocus: true,
          defaultPinTheme: PinTheme(
            width: 52,
            height: 60,
            textStyle: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
          ),
          focusedPinTheme: PinTheme(
            width: 52,
            height: 60,
            textStyle: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.textDark, width: 2),
            ),
          ),
          onCompleted: (_) => _verifyOtp(),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Didn\'t get the code? ', style: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 14)),
            _resendIn > 0
                ? Text('Resend in ${_resendIn}s',
                    style: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 14, fontWeight: FontWeight.w700))
                : TextButton(
                    onPressed: _isSending ? null : _sendOtp,
                    child: Text('Resend',
                        style: GoogleFonts.inter(color: AppTheme.textDark, fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isVerifying ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.textDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              elevation: 0,
            ),
            child: _isVerifying
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Verify & Continue',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
