import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/onboarding_screen.dart';

/// Age gate: 18+ confirmation as required by the platform.
class AgeGateScreen extends StatefulWidget {
  const AgeGateScreen({Key? key}) : super(key: key);

  @override
  State<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends State<AgeGateScreen> {
  bool _isVerifying = false;
  DateTime? _selectedDob;

  Future<void> _confirmAge(bool isAdult) async {
    if (!isAdult) {
      _showUnderageDialog();
      return;
    }
    setState(() => _isVerifying = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('age_verified', true);
    await prefs.setInt('age_verified_at', DateTime.now().millisecondsSinceEpoch);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  void _showUnderageDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sorry 😔',
            style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppTheme.textDark)),
        content: Text(
          'You must be 18 or older to use Dress. We comply with local regulations around rental services.',
          style: GoogleFonts.inter(color: AppTheme.textLight, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppTheme.primaryLime)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5CA8B5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10)),
                  ],
                ),
                child: const Icon(Icons.cake_outlined, size: 50, color: Color(0xFF5CA8B5)),
              ),
              const SizedBox(height: 40),
              Text(
                'Quick Question',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Are you 18 years or older?',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 56),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : () => _confirmAge(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryLime,
                    foregroundColor: AppTheme.textDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    elevation: 0,
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.textDark),
                        )
                      : Text(
                          "Yes, I'm 18+",
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: _isVerifying ? null : () => _confirmAge(false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                      side: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
                    ),
                  ),
                  child: Text(
                    "No, I'm under 18",
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'You must be of legal age to enter into a rental agreement.',
                style: GoogleFonts.inter(color: Colors.white.withOpacity(0.7), fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Check if the user has already verified their age.
Future<bool> isAgeVerified() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('age_verified') ?? false;
}
