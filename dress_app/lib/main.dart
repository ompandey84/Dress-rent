import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/age_gate_screen.dart';
import 'package:dress_app/screens/main_navigation.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env first so all services can use it
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // .env file not present — services will use defaults
  }

  // Initialize Supabase (no-op if not configured)
  await SupabaseService.initialize();
  // Cashfree will be initialized lazily on first payment

  final appState = AppState();
  // Hydrate session BEFORE first frame so the user stays signed in across
  // app launches (fixes the "I get logged out when I close the app" bug).
  await appState.hydrateSession();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const DressApp(),
    ),
  );
}

class DressApp extends StatefulWidget {
  const DressApp({Key? key}) : super(key: key);

  @override
  State<DressApp> createState() => _DressAppState();
}

class _DressAppState extends State<DressApp> {
  bool? _ageVerified;

  @override
  void initState() {
    super.initState();
    _checkAge();
    // Listen for auth state changes (sign in / sign out from anywhere in the
    // app) and refresh the AppState so the UI stays in sync without a
    // restart.
    if (SupabaseService.isConfigured) {
      SupabaseService.client.auth.onAuthStateChange.listen((event) {
        if (event.event == AuthChangeEvent.signedOut) {
          context.read<AppState>().signOut();
        } else if (event.event == AuthChangeEvent.signedIn) {
          context.read<AppState>().refreshProfile();
        }
      });
    }
  }

  Future<void> _checkAge() async {
    final verified = await isAgeVerified();
    if (mounted) setState(() => _ageVerified = verified);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dress',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _ageVerified == null
          ? const _SplashScreen()
          : (_ageVerified! ? const MainNavigation() : const AgeGateScreen()),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF5CA8B5),
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
