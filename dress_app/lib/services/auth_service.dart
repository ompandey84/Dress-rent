import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
// Note: sign_in_with_apple and flutter_facebook_auth need to be added to pubspec.yaml
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseService.client;

  // Stream for auth state changes (used to determine if user is logged in)
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  User? get currentUser => _supabase.auth.currentUser;

  // Email/Password Sign Up
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      return response;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Email/Password Sign In
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // General OAuth Sign In
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      return await _supabase.auth.signInWithOAuth(provider);
    } catch (e) {
      throw Exception('Failed to sign in with ${provider.name}: $e');
    }
  }

  // Google Sign In (Native approach using google_sign_in package)
  Future<AuthResponse> signInWithGoogle() async {
    try {
      const webClientId = 'YOUR_WEB_CLIENT_ID'; // Replace with actual Web Client ID
      const iosClientId = 'YOUR_IOS_CLIENT_ID'; // Replace with actual iOS Client ID

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw 'No Access Token or ID Token found.';
      }

      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Failed to send reset password email: $e');
    }
  }

  // Update Password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Technically, regular users cannot delete themselves via standard client API
        // without an edge function. We will use Edge Function or RPC for deletion.
        await _supabase.rpc('delete_user_account');
        await signOut();
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}
