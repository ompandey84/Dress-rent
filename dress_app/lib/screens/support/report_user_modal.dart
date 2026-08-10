import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/services/support_service.dart';

/// Show as bottom sheet — Report a user for a specific reason.
class ReportUserModal extends StatefulWidget {
  final String userId;
  final String userName;
  final String? relatedBookingId;
  const ReportUserModal({
    Key? key,
    required this.userId,
    required this.userName,
    this.relatedBookingId,
  }) : super(key: key);

  static Future<bool?> show(BuildContext context, {
    required String userId,
    required String userName,
    String? relatedBookingId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReportUserModal(
        userId: userId,
        userName: userName,
        relatedBookingId: relatedBookingId,
      ),
    );
  }

  @override
  State<ReportUserModal> createState() => _ReportUserModalState();
}

class _ReportUserModalState extends State<ReportUserModal> {
  String? _selectedReason;
  final _notes = TextEditingController();
  bool _submitting = false;
  bool _blockToo = false;

  static const _reasons = [
    {'id': 'harassment', 'label': 'Harassment / abusive language', 'icon': FluentIcons.warning_24_regular},
    {'id': 'fake_listing', 'label': 'Fake listing or scam', 'icon': FluentIcons.tag_error_24_regular},
    {'id': 'inappropriate', 'label': 'Inappropriate content', 'icon': FluentIcons.eye_off_24_regular},
    {'id': 'no_show', 'label': 'No-show / cancelled last minute', 'icon': FluentIcons.clock_alarm_24_regular},
    {'id': 'damaged_item', 'label': 'Item returned damaged', 'icon': FluentIcons.alert_24_regular},
    {'id': 'other', 'label': 'Other reason', 'icon': FluentIcons.more_horizontal_24_regular},
  ];

  Future<void> _submit() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a reason')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await SupportService().reportUser(
        userId: widget.userId,
        reason: _selectedReason!,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        relatedBookingId: widget.relatedBookingId,
      );
      if (_blockToo) {
        await SupportService().blockUser(widget.userId);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_blockToo
              ? 'Reported & blocked. We\'ll review within 24h.'
              : 'Reported. We\'ll review within 24h.'),
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
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.textLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(FluentIcons.warning_24_regular, color: Colors.red, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Report ${widget.userName}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                          Text('We\'ll review within 24 hours', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('REASON', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                ..._reasons.map((r) {
                  final isSelected = _selectedReason == r['id'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedReason = r['id'] as String),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.textDark : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.textDark : AppTheme.textLight.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(r['icon'] as IconData, size: 18, color: isSelected ? Colors.white : AppTheme.textDark),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                r['label'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : AppTheme.textDark,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Text('NOTES (OPTIONAL)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                TextField(
                  controller: _notes,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add any context that helps us review',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.textDark, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 16),
                // Block too
                GestureDetector(
                  onTap: () => setState(() => _blockToo = !_blockToo),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _blockToo ? AppTheme.textDark : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _blockToo ? AppTheme.textDark : AppTheme.textLight.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(FluentIcons.lock_closed_24_regular, size: 18, color: _blockToo ? Colors.white : AppTheme.textDark),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Also block this user', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: _blockToo ? Colors.white : AppTheme.textDark)),
                              Text('They won\'t see your listings or contact you', style: GoogleFonts.inter(fontSize: 11, color: _blockToo ? Colors.white70 : AppTheme.textLight)),
                            ],
                          ),
                        ),
                        Switch(
                          value: _blockToo,
                          onChanged: (v) => setState(() => _blockToo = v),
                          activeColor: AppTheme.primaryLime,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      elevation: 0,
                    ),
                    child: _submitting
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('SUBMIT REPORT', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
