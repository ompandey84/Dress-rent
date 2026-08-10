import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../theme.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  bool get _mockMode {
    try {
      final url = dotenv.env['SUPABASE_URL'];
      return url == null || url.isEmpty || url.contains('your-project');
    } catch (_) {
      return true;
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_mockMode) {
        // Mock admin sign-in: any email/password accepted
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
        return;
      }
      await Supabase.instance.client.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Sign-in failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppTheme.textDark, shape: BoxShape.circle),
                    child: const Icon(Icons.admin_panel_settings, color: AppTheme.primaryLime, size: 32),
                  ),
                  const SizedBox(height: 20),
                  Text('Dress Admin', textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('Internal dashboard', textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
                  const SizedBox(height: 32),
                  if (_mockMode)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLime.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: AppTheme.textDark),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Mock mode — any credentials work. Configure .env for Supabase.',
                                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textDark)),
                          ),
                        ],
                      ),
                    ),
                  _input('EMAIL', _email, hint: 'admin@dress.app'),
                  const SizedBox(height: 12),
                  _input('PASSWORD', _password, hint: '••••••••', obscure: true),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.danger)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.textDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      ),
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('SIGN IN', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController c, {String? hint, bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppTheme.backgroundLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
