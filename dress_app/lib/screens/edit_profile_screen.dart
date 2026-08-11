import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/widgets/custom_text_field.dart';
import 'package:dress_app/widgets/error_dialog.dart';
import 'package:dress_app/utils/validators.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/services/auth_service.dart';
import 'package:dress_app/services/storage_service.dart';
import 'package:dress_app/models/user_profile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  bool _saving = false;
  bool _uploadingPhoto = false;

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final currentUser = context.read<AppState>().currentUser;
    final updatedUser = UserProfile(
      id: currentUser.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      avatarUrl: currentUser.avatarUrl,
      phone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
      isVendor: currentUser.isVendor,
      isOnboarded: currentUser.isOnboarded,
      isVerified: currentUser.isVerified,
    );
    try {
      final ok = await context
          .read<AppState>()
          .updateUserProfile(updatedUser);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      } else {
        await ErrorDialog.show(
          context,
          title: 'Couldn\'t save profile',
          message:
              'We couldn\'t save your changes. Check your connection and try again.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      final desc = ErrorDialog.describe(e);
      await ErrorDialog.show(
        context,
        title: desc.title,
        message: desc.message,
        technical: e.toString(),
        onRetry: _save,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AppState>().currentUser;
    final isGuest = currentUser.id.isEmpty;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular,
              color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'EDIT PROFILE',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isGuest) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(FluentIcons.info_24_regular,
                              color: AppTheme.warning, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Sign in to save your profile changes.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Profile Picture Editor
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppTheme.primaryLime, width: 3),
                          image: currentUser.avatarUrl.isNotEmpty
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      currentUser.avatarUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: AppTheme.primaryLime.withOpacity(0.2),
                        ),
                        child: currentUser.avatarUrl.isEmpty
                            ? Center(
                                child: Text(
                                  currentUser.name.isNotEmpty
                                      ? currentUser.name[0].toUpperCase()
                                      : '?',
                                  style: GoogleFonts.inter(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      GestureDetector(
                        onTap: _showAvatarPicker,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppTheme.textDark,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 3),
                          ),
                          child: _uploadingPhoto
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  FluentIcons.camera_24_regular,
                                  color: Colors.white,
                                  size: 16,
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Form Fields with proper validation
                  CustomTextField(
                    label: 'Full Name',
                    hintText: 'Enter your name',
                    controller: _nameController,
                    validator: (v) => Validators.name(v, label: 'Full name'),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Email Address',
                    hintText: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Phone Number',
                    hintText: 'Enter 10-digit mobile number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      // Hard cap of 10 digits to fix the "I can enter
                      // unlimited numbers" issue
                      _DigitLimitFormatter(10),
                    ],
                    validator: Validators.phone,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Location',
                    hintText: 'Enter your city/area',
                    controller: _locationController,
                    validator: (v) =>
                        Validators.required(v, label: 'Location'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Floating Bottom Save Button
          Positioned(
            bottom: 15,
            left: 20,
            right: 20,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryLime,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryLime.withOpacity(0.3),
                    offset: const Offset(0, 8),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: (_saving || isGuest) ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.textDark),
                      )
                    : Text(
                        'SAVE CHANGES',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Change Profile Picture',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark)),
              const SizedBox(height: 16),
              _buildPicker(sheetCtx, FluentIcons.image_24_regular,
                  'Choose from Gallery', () async {
                Navigator.pop(sheetCtx);
                final f = await ImagePicker()
                    .pickImage(source: ImageSource.gallery, imageQuality: 90);
                if (f != null && mounted) {
                  await _updateAvatar(File(f.path));
                }
              }),
              const SizedBox(height: 10),
              _buildPicker(sheetCtx, FluentIcons.camera_24_regular,
                  'Take a Photo', () async {
                Navigator.pop(sheetCtx);
                final f = await ImagePicker()
                    .pickImage(source: ImageSource.camera, imageQuality: 90);
                if (f != null && mounted) {
                  await _updateAvatar(File(f.path));
                }
              }),
              const SizedBox(height: 10),
              _buildPicker(
                  sheetCtx, FluentIcons.delete_24_regular, 'Remove Photo',
                  () async {
                Navigator.pop(sheetCtx);
                await _removeAvatar();
              },
                  isDelete: true),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPicker(BuildContext context, IconData icon, String title,
      VoidCallback onTap,
      {bool isDelete = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isDelete ? Colors.red : AppTheme.textDark, size: 18),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDelete ? Colors.red : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateAvatar(File file) async {
    if (mounted) setState(() => _uploadingPhoto = true);
    try {
      final userId = context.read<AppState>().currentUser.id;
      if (userId.isEmpty) {
        if (mounted) {
          await ErrorDialog.show(
            context,
            title: 'Sign in to upload',
            message: 'You need an account to change your profile photo.',
          );
        }
        return;
      }
      final url = await StorageService().uploadAvatar(file, userId);
      await AuthService().updateProfile({'avatar_url': url});
      if (mounted) {
        await context.read<AppState>().refreshProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final desc = ErrorDialog.describe(e);
        await ErrorDialog.show(
          context,
          title: desc.title,
          message: desc.message,
          technical: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _removeAvatar() async {
    try {
      await AuthService().updateProfile({'avatar_url': ''});
      if (mounted) {
        await context.read<AppState>().refreshProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo removed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final desc = ErrorDialog.describe(e);
        await ErrorDialog.show(
          context,
          title: desc.title,
          message: desc.message,
          technical: e.toString(),
        );
      }
    }
  }
}

/// Hard-cap on digits for phone / pincode / OTP fields so users
/// can't type an unlimited number of characters.
class _DigitLimitFormatter extends TextInputFormatter {
  final int max;
  _DigitLimitFormatter(this.max);
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > max) {
      return TextEditingValue(
        text: digits.substring(0, max),
        selection: TextSelection.collapsed(offset: max),
      );
    }
    return newValue;
  }
}
