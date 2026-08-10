import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/services/storage_service.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:dress_app/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/screens/main_navigation.dart';

/// UGC post creation — share an outfit Reel to earn credit.
class UgcShareScreen extends StatefulWidget {
  const UgcShareScreen({Key? key}) : super(key: key);

  @override
  State<UgcShareScreen> createState() => _UgcShareScreenState();
}

class _UgcShareScreenState extends State<UgcShareScreen> {
  final List<File> _media = [];
  final _caption = TextEditingController();
  final _hashtags = TextEditingController();
  bool _submitting = false;
  bool _isReel = true;

  final _suggestedHashtags = [
    '#dress', '#rental', '#weddingguest', '#ootd', '#desi',
    '#fashion', '#sustainablefashion', '#rentaloutfit', '#streetstyle',
  ];

  Future<void> _pickMedia({required ImageSource source, required bool isVideo}) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file != null) setState(() => _media.add(File(file.path)));
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(FluentIcons.camera_24_regular),
              title: Text('Take Photo', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              onTap: () { Navigator.pop(context); _pickMedia(source: ImageSource.camera, isVideo: false); },
            ),
            ListTile(
              leading: const Icon(FluentIcons.image_24_regular),
              title: Text('Choose from Gallery', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              onTap: () { Navigator.pop(context); _pickMedia(source: ImageSource.gallery, isVideo: false); },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _post() async {
    if (_media.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least 1 photo or video')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      // Upload media
      final urls = <String>[];
      for (var i = 0; i < _media.length; i++) {
        final url = await StorageService().uploadAvatar(_media[i], 'ugc-${DateTime.now().millisecondsSinceEpoch}-$i');
        urls.add(url);
      }
      // Save post
      if (SupabaseService.isConfigured) {
        final supabase = Supabase.instance.client;
        await supabase.from('ugc_posts').insert({
          'user_id': AuthService().currentUserId,
          'media_url': urls.first,
          'media_type': 'photo',
          'is_reel': _isReel,
          'caption': _caption.text,
          'hashtags': _hashtags.text.split(' ').where((t) => t.isNotEmpty).toList(),
        });
        // Credit user for posting UGC
        await supabase.from('payments').insert({
          'user_id': AuthService().currentUserId,
          'type': 'referral', // reuse type
          'amount': 100,
          'status': 'completed',
          'notes': 'UGC credit for Reel',
        });
      }
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FluentIcons.heart_circle_24_filled, color: AppTheme.primaryLime, size: 56),
                const SizedBox(height: 12),
                Text('Posted! ₹100 credited',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                const SizedBox(height: 8),
                Text(
                  'Your Reel is live in the community feed. Credit applied to your wallet.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight, height: 1.4),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainNavigation()),
                    (route) => false,
                  );
                },
                child: Text('Done', style: GoogleFonts.inter(color: AppTheme.textDark, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FluentIcons.dismiss_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('SHARE YOUR LOOK',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0)),
        actions: [
          if (_media.isNotEmpty)
            TextButton(
              onPressed: _submitting ? null : _post,
              child: _submitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.textDark))
                  : Text('POST', style: GoogleFonts.inter(color: AppTheme.textDark, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(100)),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isReel = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isReel ? AppTheme.textDark : Colors.transparent,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: Text('REEL',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: _isReel ? Colors.white : AppTheme.textDark,
                                letterSpacing: 1.0,
                              )),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isReel = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isReel ? AppTheme.textDark : Colors.transparent,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: Text('PHOTO',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: !_isReel ? Colors.white : AppTheme.textDark,
                                letterSpacing: 1.0,
                              )),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Media picker
            if (_media.isEmpty)
              GestureDetector(
                onTap: _showMediaPicker,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(FluentIcons.camera_add_24_regular, color: AppTheme.textLight, size: 36),
                      const SizedBox(height: 8),
                      Text('Add ${_isReel ? 'video' : 'photo'}',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                      Text('Earn ₹100 credit when you post',
                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              )
            else
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  ..._media.map((m) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(m, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _media.remove(m)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                                child: const Icon(FluentIcons.dismiss_24_regular, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ],
                      )),
                  if (_media.length < 6)
                    GestureDetector(
                      onTap: _showMediaPicker,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid, width: 1.5),
                        ),
                        child: const Icon(FluentIcons.add_24_regular, color: AppTheme.textLight, size: 28),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 20),

            Text('Caption', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            TextField(
              controller: _caption,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Wore this to a wedding 💕 #ootd',
                hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.textDark, width: 2)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 20),
            Text('Hashtags', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            TextField(
              controller: _hashtags,
              decoration: InputDecoration(
                hintText: '#dress #wedding #ootd',
                hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.textDark, width: 2)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _suggestedHashtags.map((h) => GestureDetector(
                onTap: () {
                  _hashtags.text = '${_hashtags.text} $h';
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: AppTheme.textDark, borderRadius: BorderRadius.circular(100)),
                  child: Text(h, style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryLime.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(FluentIcons.gift_24_regular, color: AppTheme.textDark, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Earn ₹100 credit per Reel post. Credit applied within 24h.',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark, fontWeight: FontWeight.w800, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
