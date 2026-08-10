import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/listing_draft.dart';

/// Step 2: Item details — title, description, category, occasion, condition,
/// sizes, color, fabric.
class ItemDetailsScreen extends StatefulWidget {
  final ListingDraft draft;
  const ItemDetailsScreen({Key? key, required this.draft}) : super(key: key);

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _color;
  late final TextEditingController _fabric;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.draft.title);
    _description = TextEditingController(text: widget.draft.description);
    _color = TextEditingController(text: widget.draft.color);
    _fabric = TextEditingController(text: widget.draft.fabric);
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _color.dispose();
    _fabric.dispose();
    super.dispose();
  }

  Widget _chipGroup({
    required String label,
    required List<String> options,
    required String selected,
    required void Function(String) onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = opt == selected;
            return GestureDetector(
              onTap: () => setState(() => onTap(opt)),
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
                  opt,
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
      ],
    );
  }

  Widget _multiChipGroup({
    required String label,
    required List<String> options,
    required Set<String> selected,
    required void Function(String) onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = selected.contains(opt);
            return GestureDetector(
              onTap: () => setState(() => onTap(opt)),
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
                  opt,
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
      ],
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    String? helper,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: (v) {
            if (onChanged != null) onChanged(v);
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.textDark, width: 1.5)),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(helper, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight)),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputField(
            label: 'TITLE *',
            controller: _title,
            hint: 'e.g. Black Sequin Evening Gown',
            helper: 'Be specific — helps renters find it',
            onChanged: (v) => widget.draft.title = v,
          ),
          _inputField(
            label: 'DESCRIPTION *',
            controller: _description,
            hint: 'Fit notes, styling tips, condition details…',
            maxLines: 4,
            onChanged: (v) => widget.draft.description = v,
          ),
          _chipGroup(
            label: 'CATEGORY',
            options: const ['Casual', 'Ethnic', 'Formal', 'Party', 'Bridal', 'Sports'],
            selected: widget.draft.category,
            onTap: (v) => widget.draft.category = v,
          ),
          const SizedBox(height: 16),
          _chipGroup(
            label: 'GENDER',
            options: const ['Women', 'Men', 'Unisex'],
            selected: widget.draft.gender,
            onTap: (v) => widget.draft.gender = v,
          ),
          const SizedBox(height: 16),
          _chipGroup(
            label: 'OCCASION',
            options: const ['Casual', 'Wedding', 'Party', 'Festive', 'Cocktail', 'Bridal', 'Work'],
            selected: widget.draft.occasion,
            onTap: (v) => widget.draft.occasion = v,
          ),
          const SizedBox(height: 16),
          _chipGroup(
            label: 'CONDITION',
            options: const ['New', 'Like New', 'Good', 'Fair'],
            selected: widget.draft.condition,
            onTap: (v) => widget.draft.condition = v,
          ),
          const SizedBox(height: 16),
          _multiChipGroup(
            label: 'AVAILABLE SIZES *',
            options: const ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'Free Size'],
            selected: widget.draft.sizes,
            onTap: (v) {
              setState(() {
                if (widget.draft.sizes.contains(v)) {
                  widget.draft.sizes.remove(v);
                } else {
                  widget.draft.sizes.add(v);
                }
              });
            },
          ),
          const SizedBox(height: 16),
          _inputField(
            label: 'COLOR *',
            controller: _color,
            hint: 'Black / Midnight Blue / Blush Pink…',
            onChanged: (v) => widget.draft.color = v,
          ),
          _inputField(
            label: 'FABRIC (OPTIONAL)',
            controller: _fabric,
            hint: 'Silk, cotton, georgette…',
            onChanged: (v) => widget.draft.fabric = v,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
