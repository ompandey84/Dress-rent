import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/screens/login_screen.dart';

/// Shows a bottom sheet asking the user to sign in before proceeding.
/// Returns `true` if the user is already authenticated or if they signed in
/// successfully after the prompt.
///
/// Usage:
/// ```dart
/// if (!await AuthGuard.requireLogin(context)) return;
/// // ... proceed to booking / checkout
/// ```
class AuthGuard {
  AuthGuard._();

  /// Check if user is authenticated. If not, show a login-required bottom
  /// sheet and navigate to LoginScreen if the user taps "SIGN IN".
  /// Returns `true` only when the user is already authenticated.
  static Future<bool> requireLogin(
    BuildContext context, {
    String message = 'You need to sign in to continue',
  }) async {
    final appState = context.read<AppState>();
    if (appState.isAuthenticated) return true;

    // Show login-required bottom sheet
    final shouldLogin = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryLime.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FluentIcons.person_lock_24_regular,
                size: 32,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'SIGN IN REQUIRED',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLime,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'SIGN IN / SIGN UP',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Continue Browsing',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (shouldLogin == true && context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      // After returning from login, check if user is now authenticated
      if (context.mounted) {
        return context.read<AppState>().isAuthenticated;
      }
    }
    return false;
  }
}
