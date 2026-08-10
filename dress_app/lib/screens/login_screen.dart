import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/widgets/custom_text_field.dart';
import 'package:dress_app/screens/main_navigation.dart';
import 'package:dress_app/screens/signup_screen.dart';
import 'package:dress_app/screens/forgot_password_screen.dart';
import 'package:dress_app/services/auth_service.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/models/user_profile.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (mounted) {
          final appState = context.read<AppState>();
          await appState.refreshProfile();
          // If we couldn't hydrate a real profile (mock / no DB),
          // synthesize a local user from the email so the rest of the
          // app knows we're authenticated.
          if (appState.isGuest) {
            await appState.setAuthenticated(UserProfile(
              id: 'local-${_emailController.text.trim()}',
              name: _emailController.text.trim().split('@').first,
              email: _emailController.text.trim(),
              phone: '',
              avatarUrl: '',
              isVendor: false,
              isOnboarded: true,
            ));
          }
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            )
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            )
         );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleContinueAsGuest() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AppState>().continueAsGuest();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Header
                Text(
                  'WELCOME BACK',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in, or browse as guest',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textLight,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Inputs
                CustomTextField(
                  label: 'Enter e-mail',
                  hintText: 'Enter text here',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!val.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Enter Password',
                  hintText: '••••••••',
                  isPassword: _obscurePassword,
                  controller: _passwordController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? FluentIcons.eye_off_24_regular : FluentIcons.eye_24_regular,
                      color: AppTheme.textLight,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Remember me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (val) {
                              setState(() {
                                _rememberMe = val ?? true;
                              });
                            },
                            activeColor: AppTheme.primaryLime,
                            checkColor: AppTheme.textDark,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            side: BorderSide(color: AppTheme.textLight.withOpacity(0.3)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Remember me',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                        );
                      },
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryLime,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppTheme.textDark,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'CONTINUE',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 12),

                // Continue as guest
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleContinueAsGuest,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textDark,
                      side: BorderSide(
                        color: AppTheme.textLight.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Text(
                      'CONTINUE AS GUEST',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Or Separator
                Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.textLight.withOpacity(0.2))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'or',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppTheme.textLight.withOpacity(0.2))),
                  ],
                ),
                const SizedBox(height: 32),

                // Social Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton('G', Colors.red, true, _isLoading ? () {} : _handleGoogleLogin),
                    const SizedBox(width: 16),
                    _buildSocialButton(null, Colors.black, false, null, icon: Icons.apple, disabled: true),
                    const SizedBox(width: 16),
                    _buildSocialButton('f', Colors.blue.shade800, false, null, disabled: true),
                  ],
                ),
                
                const SizedBox(height: 48),

                // Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textLight,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignupScreen()),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String? label, Color iconColor, bool isGoogle, VoidCallback? onTap, {IconData? icon, bool disabled = false}) {
    return Opacity(
      opacity: disabled ? 0.35 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.textLight.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, color: iconColor, size: 30)
              : Text(
                  label ?? '',
                  style: TextStyle(
                    fontSize: isGoogle ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                    fontFamily: isGoogle ? 'GoogleSans' : null,
                  ),
                ),
        ),
      ),
    );
  }
}
