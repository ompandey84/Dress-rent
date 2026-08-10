import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/models/measurements.dart';
import 'package:dress_app/screens/main_navigation.dart';
import 'package:provider/provider.dart';

/// Measurements input screen — helps recommend right size across listings.
class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({Key? key}) : super(key: key);

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  final _bust = TextEditingController();
  final _waist = TextEditingController();
  final _hips = TextEditingController();
  final _height = TextEditingController();
  final _shoulder = TextEditingController();
  final _inseam = TextEditingController();
  final _weight = TextEditingController();
  String _preferredSize = 'M';
  String _unit = 'cm';
  bool _saving = false;

  final _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final userId = context.read<AppState>().currentUser.id;
      final measurements = Measurements(
        id: '',
        userId: userId,
        bust: double.tryParse(_bust.text),
        waist: double.tryParse(_waist.text),
        hips: double.tryParse(_hips.text),
        height: double.tryParse(_height.text),
        shoulder: double.tryParse(_shoulder.text),
        inseam: double.tryParse(_inseam.text),
        weight: double.tryParse(_weight.text),
        preferredSize: _preferredSize,
        updatedAt: DateTime.now(),
      );

      if (SupabaseService.isConfigured) {
        final supabase = Supabase.instance.client;
        await supabase.from('user_measurements').upsert({
          'user_id': userId,
          'bust': measurements.bust,
          'waist': measurements.waist,
          'hips': measurements.hips,
          'height': measurements.height,
          'shoulder': measurements.shoulder,
          'inseam': measurements.inseam,
          'weight': measurements.weight,
          'preferred_size': measurements.preferredSize,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
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
          TextButton(
            onPressed: _skip,
            child: Text('Skip',
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
                child: const Icon(FluentIcons.ruler_24_regular, color: AppTheme.textDark, size: 28),
              ),
              const SizedBox(height: 24),
              Text(
                'Your measurements',
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                "We'll use these to recommend sizes that fit you. Only you can see this.",
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight, height: 1.4),
              ),
              const SizedBox(height: 32),
              // Unit toggle
              Row(
                children: [
                  Text('Unit', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: ['cm', 'in'].map((u) {
                        final isSelected = _unit == u;
                        return GestureDetector(
                          onTap: () => setState(() => _unit = u),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.textDark : Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(u,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.white : AppTheme.textDark,
                                )),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildField('Bust', _bust, 'cm')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField('Waist', _waist, 'cm')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildField('Hips', _hips, 'cm')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField('Shoulder', _shoulder, 'cm')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildField('Height', _height, 'cm')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField('Inseam', _inseam, 'cm')),
                ],
              ),
              const SizedBox(height: 12),
              _buildField('Weight', _weight, 'kg'),
              const SizedBox(height: 32),
              Text('Preferred size', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _sizes.map((s) {
                  final isSelected = _preferredSize == s;
                  return GestureDetector(
                    onTap: () => setState(() => _preferredSize = s),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.textDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? AppTheme.textDark : Colors.grey.shade200),
                      ),
                      child: Center(
                        child: Text(s,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : AppTheme.textDark,
                            )),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.textDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Save & Continue',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'You can update these anytime in your profile.',
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textLight)),
        const SizedBox(height: 6),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(suffix, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _bust.dispose();
    _waist.dispose();
    _hips.dispose();
    _height.dispose();
    _shoulder.dispose();
    _inseam.dispose();
    _weight.dispose();
    super.dispose();
  }
}
