import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';

class VendorAvailabilityScreen extends StatefulWidget {
  const VendorAvailabilityScreen({super.key});

  @override
  State<VendorAvailabilityScreen> createState() => _VendorAvailabilityScreenState();
}

class _VendorAvailabilityScreenState extends State<VendorAvailabilityScreen> {
  // Simulated booked dates
  final Set<int> bookedDates = {5, 6, 7, 12, 13, 20, 21, 22};
  // Simulated blocked dates
  final Set<int> blockedDates = {25, 26};

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
          'AVAILABILITY',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage Availability',
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Block dates to prevent bookings. Booked dates are automatically locked.',
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Calendar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, 10), blurRadius: 30),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(FluentIcons.chevron_left_24_regular, size: 20, color: AppTheme.textDark),
                      Text('March 2026', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                      const Icon(FluentIcons.chevron_right_24_regular, size: 20, color: AppTheme.textDark),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                      return Text(day, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textLight));
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: 31,
                    itemBuilder: (context, index) {
                      int day = index + 1;
                      bool isBooked = bookedDates.contains(day);
                      bool isBlocked = blockedDates.contains(day);
                      bool isPast = day < 8;

                      Color bgColor = Colors.transparent;
                      Color textColor = AppTheme.textDark;

                      if (isBooked) {
                        bgColor = const Color(0xFFE53935).withOpacity(0.15);
                        textColor = const Color(0xFFE53935);
                      } else if (isBlocked) {
                        bgColor = Colors.orange.withOpacity(0.15);
                        textColor = Colors.orange;
                      } else if (isPast) {
                        textColor = Colors.grey.shade400;
                      }

                      return GestureDetector(
                        onTap: () {
                          if (!isBooked && !isPast) {
                            setState(() {
                              if (isBlocked) {
                                blockedDates.remove(day);
                              } else {
                                blockedDates.add(day);
                              }
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                day.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: (isBooked || isBlocked) ? FontWeight.w800 : FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              if (isBooked)
                                Positioned(
                                  bottom: 2,
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegend('Booked', const Color(0xFFE53935)),
                      const SizedBox(width: 20),
                      _buildLegend('Blocked', Colors.orange),
                      const SizedBox(width: 20),
                      _buildLegend('Available', Colors.green),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Inventory Status
            Text('Inventory Status', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 16),
            _buildInventoryStatus('Premium Hoodie', 8, 3, 5),
            const SizedBox(height: 10),
            _buildInventoryStatus('Denim Jacket', 5, 2, 3),
            const SizedBox(height: 10),
            _buildInventoryStatus('Casual T-Shirt', 12, 1, 11),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color.withOpacity(0.3), shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
      ],
    );
  }

  Widget _buildInventoryStatus(String name, int total, int rented, int available) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: rented / total,
                    minHeight: 6,
                    backgroundColor: Colors.green.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$available avail.', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.green)),
              const SizedBox(height: 2),
              Text('$rented rented', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
            ],
          ),
        ],
      ),
    );
  }
}
