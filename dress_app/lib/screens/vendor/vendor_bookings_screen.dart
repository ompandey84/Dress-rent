import 'package:flutter/material.dart';
import 'package:dress_app/screens/lender_bookings_screen.dart';

/// Wrapper screen — delegates to the comprehensive LenderBookingsScreen.
class VendorBookingsScreen extends StatelessWidget {
  const VendorBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LenderBookingsScreen();
  }
}
