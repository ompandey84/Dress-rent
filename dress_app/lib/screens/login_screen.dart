import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/widgets/custom_text_field.dart';
import 'package:dress_app/screens/main_navigation.dart';
import 'package:dress_app/screens/signup_screen.dart';
import 'package:dress_app/screens/forgot_password_screen.dart';
import 'package:dress_app/services/auth_service.dart';

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
        await _authService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: Failed to sign in: ', '')),
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
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter your email address\nfor login',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textLight,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),

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
                  height: 56,
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
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: AppTheme.textDark,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'CONTINUE',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 32),

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
                    _buildSocialButton(null, Colors.black, false, () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Apple Login not fully configured yet')));
                    }, icon: Icons.apple),
                    const SizedBox(width: 16),
                    _buildSocialButton('f', Colors.blue.shade800, false, () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Facebook Login not fully configured yet')));
                    }),
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

  Widget _buildSocialButton(String? label, Color iconColor, bool isGoogle, VoidCallback onTap, {IconData? icon}) {
    return GestureDetector(
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
    );
  }
}
