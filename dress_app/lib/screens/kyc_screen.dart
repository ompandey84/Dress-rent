import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/services/auth_service.dart';
import 'package:dress_app/services/storage_service.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/models/user_profile.dart';
import 'package:dress_app/screens/measurements_screen.dart';
import 'package:dress_app/screens/main_navigation.dart';
import 'package:provider/provider.dart';

/// KYC upload screen — required for lenders; recommended for renters.
/// Users upload a government-issued ID (Aadhaar, PAN, Passport, etc.)
class KycScreen extends StatefulWidget {
  final bool isMandatory; // true for lenders
  const KycScreen({Key? key, this.isMandatory = false}) : super(key: key);

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  String? _selectedIdType = 'Aadhaar Card';
  File? _idFront;
  File? _idBack;
  bool _uploading = false;

  final _idTypes = ['Aadhaar Card', 'PAN Card', 'Passport', 'Driving License', 'Voter ID'];

  Future<void> _pickImage(bool isFront) async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(FluentIcons.camera_24_regular),
              title: Text('Take Photo', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              onTap: () async {
                Navigator.pop(context);
                final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                if (file != null) {
                  setState(() => isFront ? _idFront = File(file.path) : _idBack = File(file.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(FluentIcons.image_24_regular),
              title: Text('Choose from Gallery', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              onTap: () async {
                Navigator.pop(context);
                final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                if (file != null) {
                  setState(() => isFront ? _idFront = File(file.path) : _idBack = File(file.path));
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_idFront == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload the front of your ID')),
      );
      return;
    }
    if (_selectedIdType == 'Aadhaar Card' && _idBack == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aadhaar needs both front and back')),
      );
      return;
    }

    setState(() => _uploading = true);
    try {
      // Upload front
      final frontUrl = await StorageService().uploadAvatar(_idFront!, 'kyc-front-${DateTime.now().millisecondsSinceEpoch}');
      String? backUrl;
      if (_idBack != null) {
        backUrl = await StorageService().uploadAvatar(_idBack!, 'kyc-back-${DateTime.now().millisecondsSinceEpoch}');
      }
      final idUrl = backUrl != null ? '$frontUrl|$backUrl' : frontUrl;

      // Submit KYC
      await AuthService().uploadKycDocument(idUrl, _selectedIdType!);

      // Refresh user state
      if (mounted) {
        await context.read<AppState>().refreshProfile();
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => widget.isMandatory
              ? const MainNavigation() // Lenders skip measurements
              : const MeasurementsScreen(),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMandatory = widget.isMandatory;
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!isMandatory)
            TextButton(
              onPressed: _skip,
              child: Text('Skip for now',
                  style: GoogleFonts.inter(color: AppTheme.textDark, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLime.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(FluentIcons.shield_checkmark_24_regular, color: AppTheme.textDark, size: 28),
              ),
              const SizedBox(height: 24),
              Text(
                isMandatory ? 'Verify your identity' : 'Verify yourself (optional)',
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                isMandatory
                    ? 'Required to start lending. Uploads are encrypted and only used for verification.'
                    : 'Boost your trust score and unlock higher-value rentals. Takes 2 minutes.',
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight, height: 1.4),
              ),
              const SizedBox(height: 32),
              Text('ID Type', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _idTypes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final type = _idTypes[i];
                    final isSelected = _selectedIdType == type;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIdType = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.textDark : Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: isSelected ? AppTheme.textDark : Colors.grey.shade200),
                        ),
                        child: Center(
                          child: Text(type,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? Colors.white : AppTheme.textDark,
                              )),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              _buildIdUploadBox(
                label: 'Front of ID',
                file: _idFront,
                onTap: () => _pickImage(true),
              ),
              const SizedBox(height: 16),
              if (_selectedIdType == 'Aadhaar Card') ...[
                _buildIdUploadBox(
                  label: 'Back of ID',
                  file: _idBack,
                  onTap: () => _pickImage(false),
                ),
                const SizedBox(height: 16),
              ],
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLime.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(FluentIcons.lock_closed_24_regular, color: AppTheme.textDark, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your ID is encrypted at rest and only used to verify your identity. We never share it with third parties.',
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _uploading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.textDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    elevation: 0,
                  ),
                  child: _uploading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Submit for review',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Reviews typically complete in under 24 hours.',
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdUploadBox({required String label, File? file, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: file != null ? AppTheme.textDark : Colors.grey.shade300,
            width: file != null ? 2 : 1.5,
            style: file == null ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: file == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FluentIcons.camera_24_regular, size: 36, color: AppTheme.textLight),
                  const SizedBox(height: 8),
                  Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                  const SizedBox(height: 4),
                  Text('Tap to upload',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
                ],
              )
            : Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(file, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppTheme.textDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(FluentIcons.checkmark_24_regular, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
