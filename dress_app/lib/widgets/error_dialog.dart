import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';

/// Friendly error dialog that hides the raw Supabase/Postgrest exception
/// text and shows a human-readable message instead.
class ErrorDialog {
  /// Show a generic error. `technical` is the raw error from the service
  /// (e.g. "PostgrestException(message: ...)") — it's only logged, never shown.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? technical,
    VoidCallback? onRetry,
    String? retryLabel,
  }) async {
    // Log raw error to the console for developers.
    // ignore: avoid_print
    print('[ErrorDialog] $title: $message${technical != null ? '\n  raw: $technical' : ''}');

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      FluentIcons.error_circle_24_regular,
                      color: Colors.red,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textDark,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      'OK',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onRetry();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryLime,
                        foregroundColor: AppTheme.textDark,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        retryLabel ?? 'RETRY',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Translates a raw exception from the service layer into a friendly
  /// (title, message) pair.
  static ({String title, String message}) describe(Object? error) {
    final raw = error.toString();
    if (raw.contains('SocketException') ||
        raw.contains('Failed host lookup') ||
        raw.contains('Network is unreachable')) {
      return (
        title: 'No internet connection',
        message:
            'We couldn\'t reach the server. Check your connection and try again.',
      );
    }
    if (raw.contains('TimeoutException') || raw.contains('timeout')) {
      return (
        title: 'Request timed out',
        message: 'The server is taking too long to respond. Please try again.',
      );
    }
    if (raw.contains('invalid input syntax for type uuid')) {
      return (
        title: 'Session error',
        message:
            'Your session looks invalid. Please sign out and sign in again.',
      );
    }
    if (raw.contains('duplicate key value')) {
      return (
        title: 'Already added',
        message: 'This item is already in the list.',
      );
    }
    if (raw.contains('permission denied') || raw.contains('row-level security')) {
      return (
        title: 'Permission denied',
        message:
            'You don\'t have permission to do that. Please sign in and try again.',
      );
    }
    if (raw.contains('Email not confirmed')) {
      return (
        title: 'Email not verified',
        message: 'Please check your email and click the confirmation link before signing in.',
      );
    }
    if (raw.contains('Invalid login') || raw.contains('Invalid credentials')) {
      return (
        title: 'Sign-in failed',
        message: 'Email or password is incorrect.',
      );
    }
    if (raw.contains('User already registered')) {
      return (
        title: 'Account exists',
        message:
            'An account with this email already exists. Try signing in instead.',
      );
    }
    if (raw.contains('Bucket not found') ||
        raw.contains('storage') && raw.contains('not found')) {
      return (
        title: 'Upload failed',
        message:
            'File storage isn\'t set up yet. Please try again later.',
      );
    }
    // Fallback
    return (
      title: 'Something went wrong',
      message:
          'We hit an unexpected problem. Please try again — if it keeps happening, contact support.',
    );
  }
}

/// Reusable network call helper. Wraps any async block, shows an error
/// dialog on failure, and returns the value (or null on error).
Future<T?> runWithErrorHandling<T>(
  BuildContext context,
  Future<T> Function() block, {
  String? operationName,
  VoidCallback? onRetry,
}) async {
  try {
    return await block();
  } catch (e) {
    if (!context.mounted) return null;
    final desc = ErrorDialog.describe(e);
    await ErrorDialog.show(
      context,
      title: desc.title,
      message: desc.message,
      technical: e.toString(),
      onRetry: onRetry,
    );
    return null;
  }
}
