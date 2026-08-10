import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/listing_draft.dart';

/// Step 1: Multi-photo + short video upload.
class UploadMediaScreen extends StatefulWidget {
  final ListingDraft draft;
  const UploadMediaScreen({Key? key, required this.draft}) : super(key: key);

  @override
  State<UploadMediaScreen> createState() => _UploadMediaScreenState();
}

class _UploadMediaScreenState extends State<UploadMediaScreen> {
  final _picker = ImagePicker();

  Future<void> _pickPhoto({ImageSource source = ImageSource.gallery}) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file != null) {
      setState(() => widget.draft.photos.add(File(file.path)));
    }
  }

  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 30));
    if (file != null) {
      setState(() => widget.draft.video = File(file.path));
    }
  }

  void _removePhoto(int index) {
    setState(() => widget.draft.photos.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add photos of your item',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            'First photo is the cover. Add up to 6 photos.',
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          // Photo grid
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              ...widget.draft.photos.asMap().entries.map((entry) {
                final i = entry.key;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(entry.value, fit: BoxFit.cover),
                    ),
                    if (i == 0)
                      Positioned(
                        left: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.textDark,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'COVER',
                            style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: GestureDetector(
                        onTap: () => _removePhoto(i),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              if (widget.draft.photos.length < 6)
                GestureDetector(
                  onTap: () => _pickPhoto(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLime.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.textDark, width: 1.5, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(FluentIcons.add_24_regular, size: 28, color: AppTheme.textDark),
                        const SizedBox(height: 4),
                        Text('Add photo', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          // Video section
          Text(
            'Optional: 15s video',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            'Show how it drapes, moves, or fits. Boost approvals by 2x.',
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          if (widget.draft.video != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    color: Colors.black,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(FluentIcons.video_24_regular, color: Colors.white54, size: 48),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => widget.draft.video = null),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: _pickVideo,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.textLight.withOpacity(0.3), width: 1.5),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: AppTheme.primaryLime, shape: BoxShape.circle),
                      child: const Icon(FluentIcons.video_24_regular, size: 24, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 8),
                    Text('Tap to record or upload', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                    Text('Up to 30 seconds', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          // Tips card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryLime.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(FluentIcons.lightbulb_24_regular, size: 18, color: AppTheme.textDark),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Use natural light, plain backgrounds, and show the full item. Avoid selfies or filters.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
