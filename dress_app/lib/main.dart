import 'package:flutter/material.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/onboarding_screen.dart';

void main() {
  runApp(const DressApp());
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
