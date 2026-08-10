import 'package:flutter/material.dart';
import 'package:dress_app/screens/lend/lend_flow_screen.dart';

/// Entry point kept for backward compatibility with existing navigation.
/// The full multi-step listing flow now lives in [LendFlowScreen].
class VendorAddItemScreen extends StatelessWidget {
  const VendorAddItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LendFlowScreen();
  }
}
