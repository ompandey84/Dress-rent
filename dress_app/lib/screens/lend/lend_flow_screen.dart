import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/listing_draft.dart';
import 'package:dress_app/widgets/step_indicator.dart';
import 'package:dress_app/screens/lend/upload_media_screen.dart';
import 'package:dress_app/screens/lend/item_details_screen.dart';
import 'package:dress_app/screens/lend/set_price_screen.dart';
import 'package:dress_app/screens/lend/set_pickup_address_screen.dart';
import 'package:dress_app/screens/lend/listing_submitted_screen.dart';
import 'package:dress_app/services/listing_service.dart';

/// Multi-step lender listing flow — 4 steps + admin approval.
class LendFlowScreen extends StatefulWidget {
  const LendFlowScreen({Key? key}) : super(key: key);

  @override
  State<LendFlowScreen> createState() => _LendFlowScreenState();
}

class _LendFlowScreenState extends State<LendFlowScreen> {
  final PageController _pageController = PageController();
  final ListingDraft _draft = ListingDraft();
  int _currentStep = 0;
  bool _submitting = false;

  bool get _canAdvance {
    switch (_currentStep) {
      case 0: return _draft.isValidStep1();
      case 1: return _draft.isValidStep2();
      case 2: return _draft.isValidStep3();
      case 3: return _draft.isValidStep4();
    }
    return false;
  }

  void _next() {
    if (!_canAdvance) {
      _showIncomplete();
      return;
    }
    if (_currentStep < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      Navigator.pop(context);
    }
  }

  void _showIncomplete() {
    String msg;
    switch (_currentStep) {
      case 0: msg = 'Add at least 1 photo to continue'; break;
      case 1: msg = 'Title, description, sizes, and color required'; break;
      case 2: msg = 'Set a per-day price and deposit'; break;
      case 3: msg = 'Complete the pickup address'; break;
      default: msg = 'Complete this step to continue';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    if (!_draft.isValidStep1() || !_draft.isValidStep2() || !_draft.isValidStep3() || !_draft.isValidStep4()) {
      _showIncomplete();
      return;
    }
    setState(() => _submitting = true);
    try {
      await ListingService().submitForReview(_draft);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ListingSubmittedScreen(draft: _draft)),
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
          onPressed: _back,
        ),
        title: Text(
          'LIST AN ITEM',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0),
        ),
      ),
      body: Column(
        children: [
          StepIndicator(current: _currentStep),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEAEAEA)),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                UploadMediaScreen(draft: _draft),
                ItemDetailsScreen(draft: _draft),
                SetPriceScreen(draft: _draft),
                SetPickupAddressScreen(draft: _draft),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submitting ? null : _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canAdvance ? AppTheme.textDark : AppTheme.textLight.withOpacity(0.3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                elevation: 0,
                disabledBackgroundColor: AppTheme.textLight.withOpacity(0.3),
                disabledForegroundColor: Colors.white,
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _currentStep == 3 ? 'SUBMIT FOR REVIEW' : 'CONTINUE',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
