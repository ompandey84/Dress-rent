import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dress_app/theme.dart';

/// Step indicator — 4 dots, current one filled with primary lime.
class StepIndicator extends StatelessWidget {
  final int current; // 0-based
  final int total;
  final List<String> labels;

  const StepIndicator({
    Key? key,
    required this.current,
    this.total = 4,
    this.labels = const ['Media', 'Details', 'Price', 'Pickup'],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(total, (i) {
          final isDone = i < current;
          final isCurrent = i == current;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDone
                              ? AppTheme.textDark
                              : isCurrent
                                  ? AppTheme.primaryLime
                                  : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCurrent
                                ? AppTheme.textDark
                                : AppTheme.textLight.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: isDone
                            ? const Icon(Icons.check, size: 12, color: Colors.white)
                            : Text(
                                '${i + 1}',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textDark,
                                ),
                              ),
                      ),
                      if (i < total - 1)
                        Expanded(
                          child: Container(
                            height: 1.5,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            color: isDone
                                ? AppTheme.textDark
                                : AppTheme.textLight.withOpacity(0.2),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[i],
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                      color: isCurrent ? AppTheme.textDark : AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
