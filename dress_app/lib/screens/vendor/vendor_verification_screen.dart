import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/services/app_state.dart';

class VendorVerificationScreen extends StatefulWidget {
  const VendorVerificationScreen({super.key});

  @override
  State<VendorVerificationScreen> createState() => _VendorVerificationScreenState();
}

class _VendorVerificationScreenState extends State<VendorVerificationScreen> with TickerProviderStateMixin {
  bool isVerified = false;
  late AnimationController _pulseController;
  late AnimationController _checkController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    // Simulate verification: 3 seconds loading → success → auto-navigate
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      _pulseController.stop();
      setState(() => isVerified = true);
      _checkController.forward();
      // Set vendor mode in global state
      Provider.of<AppState>(context, listen: false).setVendorMode(true);

      // Auto-navigate after 1 second of showing success
      Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: isVerified ? _buildSuccessIcon() : _buildLoadingIcon(),
              ),
              const SizedBox(height: 40),

              // Title
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  isVerified ? 'VERIFICATION SUCCESSFUL!' : 'VERIFYING YOUR DETAILS',
                  key: ValueKey(isVerified),
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  isVerified
                      ? 'Welcome to the vendor community!\nRedirecting to your dashboard...'
                      : 'Please wait while we verify your\nbusiness information...',
                  key: ValueKey('sub_$isVerified'),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textLight,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),

              // Progress Steps
              _buildVerificationSteps(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FA),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E8A99).withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E8A99)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessIcon() {
    return AnimatedBuilder(
      animation: _checkAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _checkAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.check_circle, color: Colors.green, size: 60),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerificationSteps() {
    return Column(
      children: [
        _buildStepRow('Business details received', true),
        const SizedBox(height: 12),
        _buildStepRow('Identity verification', isVerified),
        const SizedBox(height: 12),
        _buildStepRow('Bank account validation', isVerified),
        const SizedBox(height: 12),
        _buildStepRow('Account activation', isVerified),
      ],
    );
  }

  Widget _buildStepRow(String text, bool isDone) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDone ? Colors.green.withOpacity(0.1) : const Color(0xFFF6F8FA),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 14, color: Colors.green)
                : SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textLight.withOpacity(0.5)),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 200,
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isDone ? FontWeight.w600 : FontWeight.w500,
              color: isDone ? AppTheme.textDark : AppTheme.textLight,
            ),
          ),
        ),
      ],
    );
  }
}
