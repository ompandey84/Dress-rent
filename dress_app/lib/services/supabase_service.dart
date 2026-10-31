import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase client. If credentials are not configured, falls back to no-op
/// (the app will use mock data from `MockDataService`).
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  /// Whether the env vars are set to real values (not placeholders).
  static bool get isConfigured {
    try {
      final url = dotenv.env['SUPABASE_URL'] ?? '';
      final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
      if (url.isEmpty || key.isEmpty) return false;
      final lowerUrl = url.toLowerCase();
      final lowerKey = key.toLowerCase();
      if (lowerUrl.contains('your-') ||
          lowerUrl.contains('your_') ||
          lowerUrl.contains('example.com') ||
          lowerKey.contains('your-') ||
          lowerKey.contains('your_') ||
          lowerKey.contains('anon-key')) {
        return false;
      }
      return true;
    } catch (_) {
      // dotenv not loaded yet — assume not configured
      return false;
    }
  }

  static Future<void> initialize() async {
    // Try to load .env if it hasn't been loaded yet
    try {
      if (!isConfigured) {
        // dotenv not loaded or empty values — skip Supabase init
        // (the app will fall back to mock data)
        return;
      }
    } catch (_) {
      return;
    }

    try {
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      );
    } catch (e) {
      // If Supabase init fails, just continue in mock mode
      return;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
