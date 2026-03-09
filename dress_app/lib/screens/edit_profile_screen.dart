import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/models/user_profile.dart';
import 'package:dress_app/screens/change_password_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().currentUser;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
    _locationController = TextEditingController(text: user.location);
  }
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'EDIT PROFILE',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture Editor
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryLime, width: 3),
                        image: const DecorationImage(
                          image: CachedNetworkImageProvider(
                            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=200&auto=format&fit=crop',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Change Profile Picture',
                                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                                ),
                                const SizedBox(height: 24),
                                _buildPickerOption(FluentIcons.image_24_regular, 'Choose from Gallery', () => Navigator.pop(context)),
                                const SizedBox(height: 16),
                                _buildPickerOption(FluentIcons.camera_24_regular, 'Take a Photo', () => Navigator.pop(context)),
                                const SizedBox(height: 16),
                                _buildPickerOption(FluentIcons.delete_24_regular, 'Remove Photo', () => Navigator.pop(context), isDelete: true),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.textDark,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(FluentIcons.camera_24_regular, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Form Fields
                CustomTextField(
                  label: 'Full Name',
                  hintText: 'Enter your name',
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Email Address',
                  hintText: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Phone Number',
                  hintText: 'Enter phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Location',
                  hintText: 'Enter your city/area',
                  controller: _locationController,
                ),
                const SizedBox(height: 32),
                
                // Change Password Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'SECURITY',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textLight, letterSpacing: 1.0),
                  ),
                ),
                const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(FluentIcons.lock_closed_24_regular, color: AppTheme.textDark, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Text('Change Password', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                            ],
                          ),
                          const Icon(FluentIcons.chevron_right_24_regular, color: AppTheme.textLight, size: 20),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Floating Bottom Save Button
          Positioned(
            bottom: 15,
            left: 24,
            right: 24,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryLime,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryLime.withOpacity(0.3), offset: const Offset(0, 8), blurRadius: 15),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  final currentUser = context.read<AppState>().currentUser;
                  final updatedUser = UserProfile(
                    id: currentUser.id,
                    name: _nameController.text,
                    email: _emailController.text,
                    avatarUrl: currentUser.avatarUrl,
                    phone: _phoneController.text,
                    location: _locationController.text,
                    isVendor: currentUser.isVendor,
                  );
                  context.read<AppState>().updateUserProfile(updatedUser);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profile updated successfully!', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: Center(
                  child: Text(
                    'SAVE CHANGES',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerOption(IconData icon, String title, VoidCallback onTap, {bool isDelete = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: isDelete ? Colors.red : AppTheme.textDark, size: 20),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDelete ? Colors.red : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
