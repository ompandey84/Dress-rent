import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/rating_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: const SizedBox.shrink(), // No back button on main tab
        actions: [
          IconButton(
            icon: const Icon(FluentIcons.settings_24_regular, color: AppTheme.textDark),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Header
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryLime, width: 3),
                  image: const DecorationImage(
                    image: CachedNetworkImageProvider('https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=200&auto=format&fit=crop'), // Standard male face
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'MR JANSON CLARK',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Verified', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, size: 14, color: Colors.green),
                  const SizedBox(width: 16),
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('4.8', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                  Text(' (84 Reviews)', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
                ],
              ),
              const SizedBox(height: 32),
              
              // Stats Cards
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Order', '100+', FluentIcons.cart_24_regular, Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('On progress', '8', FluentIcons.clipboard_24_regular, Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Reviews', '4.5', FluentIcons.star_24_regular, Colors.red)),
                ],
              ),
              const SizedBox(height: 32),
              
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Settings', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              ),
              const SizedBox(height: 16),
              
              // Settings List
              _buildSettingsItem(FluentIcons.person_24_regular, 'Personal Information'),
              const SizedBox(height: 16),
              _buildSettingsItem(FluentIcons.wallet_24_regular, 'Earning'),
              const SizedBox(height: 16),
              _buildSettingsItem(FluentIcons.document_24_regular, 'Taxes Document'),
              const SizedBox(height: 16),
              _buildSettingsItem(FluentIcons.list_24_regular, 'Terms and Conditions'),
              const SizedBox(height: 16),
              _buildSettingsItem(FluentIcons.chat_help_24_regular, 'Complain Center'),
              const SizedBox(height: 32),
              
              // Demo Navigation to Rating Screen since it's the last one
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RatingScreen()));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryLime),
                child: const Text('Simulate Delivery (Go to Rating)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textLight.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textLight.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textLight, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
            ),
          ),
          const Icon(FluentIcons.chevron_right_24_regular, color: AppTheme.textLight, size: 20),
        ],
      ),
    );
  }
}
