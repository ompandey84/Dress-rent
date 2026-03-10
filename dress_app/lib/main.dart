import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/onboarding_screen.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase and environment variables
  await SupabaseService.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const DressApp(),
    ),
  );
}

class DressApp extends StatelessWidget {
  const DressApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fashion App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const OnboardingScreen(),
    );
  }
}
