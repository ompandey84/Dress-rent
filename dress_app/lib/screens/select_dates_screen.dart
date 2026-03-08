import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/product.dart';
import 'package:dress_app/screens/checkout_screen.dart';

class SelectDatesScreen extends StatefulWidget {
  final Product product;
  const SelectDatesScreen({super.key, required this.product});

  @override
  State<SelectDatesScreen> createState() => _SelectDatesScreenState();
}

class _SelectDatesScreenState extends State<SelectDatesScreen> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now().add(const Duration(days: 2));
    endDate = DateTime.now().add(const Duration(days: 5));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SELECT DATES',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'When do you need it?',
                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select your rental period. We recommend booking 2 days before your event.',
                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight, height: 1.5),
                ),
                const SizedBox(height: 32),
                
                // Mock Calendar UI
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, 10), blurRadius: 30),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(FluentIcons.chevron_left_24_regular, size: 20, color: AppTheme.textDark),
                          Text(
                            'March 2026',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                          ),
                          const Icon(FluentIcons.chevron_right_24_regular, size: 20, color: AppTheme.textDark),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                          return Text(
                            day,
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textLight),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Mock Dates Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: 31,
                        itemBuilder: (context, index) {
                          int day = index + 1;
                          bool isStart = day == 15;
                          bool isEnd = day == 18;
                          bool isInBetween = day > 15 && day < 18;
                          bool isPast = day < 10;
                          
                          Color bgColor = Colors.transparent;
                          Color textColor = AppTheme.textDark;
                          
                          if (isStart || isEnd) {
                            bgColor = AppTheme.primaryLime;
                            textColor = AppTheme.textDark;
                          } else if (isInBetween) {
                            bgColor = AppTheme.primaryLime.withValues(alpha: 0.2);
                          } else if (isPast) {
                            textColor = Colors.grey.shade400;
                          }
                          
                          return Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              shape: isStart || isEnd ? BoxShape.circle : BoxShape.rectangle,
                              borderRadius: isInBetween ? BorderRadius.circular(8) : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              day.toString(),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: (isStart || isEnd) ? FontWeight.w800 : FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primaryLime, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text('Start/End', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: AppTheme.primaryLime.withValues(alpha: 0.2), shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text('Rental Period', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                // Summary preview
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rental Duration', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight)),
                        const SizedBox(height: 4),
                        Text('3 Days', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Est. Rental Price', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight)),
                        const SizedBox(height: 4),
                        Text('AED ${widget.product.price.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Floating Bottom Button
          Positioned(
            bottom: 15, // 15px padding
            left: 24,
            right: 24,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryLime,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryLime.withValues(alpha: 0.3), offset: const Offset(0, 8), blurRadius: 15),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CheckoutScreen(product: widget.product)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: Center(
                  child: Text(
                    'NEXT: ORDER PREPARATION',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
