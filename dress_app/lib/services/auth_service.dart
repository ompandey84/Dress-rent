import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:dress_app/services/mock_data_service.dart';
import 'package:dress_app/models/user_profile.dart';

/// Auth service. If Supabase is configured, uses real auth (Phone/Email/OTP).
/// Otherwise, uses a mock user so the app can be browsed without backend.
class AuthService {
  bool get _isRealAuth => SupabaseService.isConfigured;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges {
    if (_isRealAuth) {
      return SupabaseService.client.auth.onAuthStateChange;
    }
    // Mock mode: emit a single "signed in" event so the app loads
    return Stream<AuthState>.empty();
  }

  User? get currentUser {
    if (_isRealAuth) {
      return SupabaseService.client.auth.currentUser;
    }
    return null; // Mock mode: no real User object
  }

  String? get currentUserId {
    if (_isRealAuth) {
      return SupabaseService.client.auth.currentUser?.id;
    }
    return 'mock-user-id';
  }

  /// Send OTP to phone number.
  Future<void> sendPhoneOtp(String phone) async {
    if (!_isRealAuth) {
      // In mock mode, just pretend we sent it
      await Future.delayed(const Duration(seconds: 1));
      return;
    }
    await SupabaseService.client.auth.signInWithOtp(
      phone: phone,
      // For Indian numbers, default channel is SMS
    );
  }

  /// Verify OTP entered by user.
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    if (!_isRealAuth) {
      // Mock mode: succeed immediately
      return AuthResponse(session: null, user: null);
    }
    return await SupabaseService.client.auth.verifyOTP(
      phone: phone,
      token: otp,
      type: OtpType.sms,
    );
  }

  /// Email + password sign in.
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (!_isRealAuth) {
      return AuthResponse(session: null, user: null);
    }
    return await SupabaseService.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Email + password sign up.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic>? data,
  }) async {
    if (!_isRealAuth) {
      return AuthResponse(session: null, user: null);
    }
    return await SupabaseService.client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  /// Sign in with Google (using native Google Sign-In).
  Future<AuthResponse?> signInWithGoogle() async {
    if (!_isRealAuth) {
      return AuthResponse(session: null, user: null);
    }
    // TODO: integrate with google_sign_in package, then call signInWithIdToken
    return null;
  }

  Future<void> signOut() async {
    if (!_isRealAuth) {
      // Mock mode: no Supabase session to clear. Callers should reset
      // local app state if needed.
      return;
    }
    await SupabaseService.client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    if (!_isRealAuth) return;
    await SupabaseService.client.auth.resetPasswordForEmail(email);
  }

  Future<void> updatePassword(String newPassword) async {
    if (!_isRealAuth) return;
    await SupabaseService.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// In mock mode, returns the demo user. Otherwise fetches from `profiles` table.
  Future<UserProfile?> getCurrentProfile() async {
    if (!_isRealAuth) {
      return MockDataService.currentUser;
    }
    final uid = currentUserId;
    if (uid == null) return null;
    final res = await SupabaseService.client
        .from('profiles')
        .select()
        .eq('id', uid)
        .single();
    return UserProfile.fromJson(res);
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (!_isRealAuth) return;
    final uid = currentUserId;
    if (uid == null) return;
    await SupabaseService.client
        .from('profiles')
        .update(data)
        .eq('id', uid);
  }

  Future<void> uploadKycDocument(String idImageUrl, String idType) async {
    if (!_isRealAuth) return;
    final uid = currentUserId;
    if (uid == null) return;
    await SupabaseService.client.from('profiles').update({
      'kyc_id_url': idImageUrl,
      'kyc_id_type': idType,
      'kyc_status': 'submitted',
    }).eq('id', uid);
  }
}
