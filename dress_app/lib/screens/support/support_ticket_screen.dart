import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dress_app/theme.dart';
import 'package:dress_app/services/support_service.dart';

/// Create a support ticket with category, subject, description, attachments.
class SupportTicketScreen extends StatefulWidget {
  final String? relatedBookingId;
  final String? relatedUserId;
  final SupportCategory? preselectCategory;
  const SupportTicketScreen({
    Key? key,
    this.relatedBookingId,
    this.relatedUserId,
    this.preselectCategory,
  }) : super(key: key);

  @override
  State<SupportTicketScreen> createState() => _SupportTicketScreenState();
}

class _SupportTicketScreenState extends State<SupportTicketScreen> {
  SupportCategory _category = SupportCategory.booking;
  final _subject = TextEditingController();
  final _description = TextEditingController();
  final List<File> _attachments = [];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.preselectCategory != null) {
      _category = widget.preselectCategory!;
    }
  }

  Future<void> _pickAttachment() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) {
      setState(() => _attachments.add(File(file.path)));
    }
  }

  Future<void> _submit() async {
    if (_subject.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a subject')),
      );
      return;
    }
    if (_description.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a description')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await SupportService().createTicket(
        category: _category,
        subject: _subject.text.trim(),
        description: _description.text.trim(),
        relatedBookingId: widget.relatedBookingId,
        relatedUserId: widget.relatedUserId,
        attachments: _attachments.map((f) => f.path).toList(),
      );
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppTheme.primaryLime, shape: BoxShape.circle),
                child: const Icon(FluentIcons.checkmark_24_regular, size: 20, color: AppTheme.textDark),
              ),
              const SizedBox(width: 10),
              Text('Ticket raised!', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          content: Text(
            "We'll respond within 4 hours. You'll get a notification once our team replies.",
            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Text('DONE', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppTheme.textDark)),
            ),
          ],
        ),
      );
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
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('RAISE A TICKET', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            Text('CATEGORY', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SupportCategory.values.map((c) {
                final isSelected = _category == c;
                return GestureDetector(
                  onTap: () => setState(() => _category = c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.textDark : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: isSelected ? AppTheme.textDark : AppTheme.textLight.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      c.label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Subject
            Text('SUBJECT', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            TextField(
              controller: _subject,
              onChanged: (v) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Brief summary of the issue',
                hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.textDark, width: 1.5)),
              ),
            ),
            const SizedBox(height: 20),
            // Description
            Text('DESCRIPTION', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            TextField(
              controller: _description,
              maxLines: 6,
              onChanged: (v) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'What happened? Include booking ID if relevant.',
                hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.textDark, width: 1.5)),
              ),
            ),
            const SizedBox(height: 20),
            // Attachments
            Text('ATTACHMENTS (OPTIONAL)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text('Photos help us resolve faster', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._attachments.asMap().entries.map((entry) {
                  final i = entry.key;
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(entry.value, width: 80, height: 80, fit: BoxFit.cover),
                      ),
                      Positioned(
                        right: -4,
                        top: -4,
                        child: GestureDetector(
                          onTap: () => setState(() => _attachments.removeAt(i)),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                if (_attachments.length < 4)
                  GestureDetector(
                    onTap: _pickAttachment,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.textLight.withOpacity(0.3), width: 1.5, style: BorderStyle.solid),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FluentIcons.add_24_regular, size: 22, color: AppTheme.textDark),
                          SizedBox(height: 2),
                          Text('Add', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryLime.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(FluentIcons.clock_24_regular, size: 16, color: AppTheme.textDark),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Median response time: 2h 14m\nFor urgent safety issues, call 112',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark, fontWeight: FontWeight.w600, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('SUBMIT TICKET', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
