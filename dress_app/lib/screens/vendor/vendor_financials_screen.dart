import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';

class VendorFinancialsScreen extends StatelessWidget {
  const VendorFinancialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'FINANCIALS',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Earnings Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1C222B), Color(0xFF2E3A4A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1C222B).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Earnings', style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withOpacity(0.6))),
                  const SizedBox(height: 8),
                  Text('AED 45,200', style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.trending_up, size: 12, color: Colors.green),
                            const SizedBox(width: 4),
                            Text('+18.5%', style: GoogleFonts.inter(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('vs last month', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.5))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pending', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withOpacity(0.5))),
                              const SizedBox(height: 4),
                              Text('AED 3,200', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.orange)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('This Month', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withOpacity(0.5))),
                              const SizedBox(height: 4),
                              Text('AED 8,500', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryLime)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Monthly Earnings Chart
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Monthly Earnings', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF6F8FA), borderRadius: BorderRadius.circular(100)),
                        child: Text('2026', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildMonthlyChart(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Transactions
            Text('Recent Transactions', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 16),
            _buildTransactionCard('Premium Hoodie', 'BK-2841', 'AED 2,450', 'Credited', Colors.green, 'Mar 8'),
            _buildTransactionCard('Denim Jacket', 'BK-2840', 'AED 1,800', 'Credited', Colors.green, 'Mar 6'),
            _buildTransactionCard('Casual T-Shirt', 'BK-2839', 'AED 900', 'Pending', Colors.orange, 'Mar 5'),
            _buildTransactionCard('Summer Dress', 'BK-2835', 'AED 2,100', 'Credited', Colors.green, 'Mar 2'),
            _buildTransactionCard('Leather Jacket', 'BK-2833', 'AED 3,200', 'Credited', Colors.green, 'Feb 28'),

            const SizedBox(height: 24),

            // Download Reports
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Report downloaded!', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    backgroundColor: const Color(0xFF2E8A99),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLime,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryLime.withOpacity(0.3), offset: const Offset(0, 8), blurRadius: 15),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(FluentIcons.arrow_download_24_regular, color: AppTheme.textDark, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'DOWNLOAD FINANCIAL REPORT',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart() {
    final months = [
      {'month': 'Jan', 'value': 0.5},
      {'month': 'Feb', 'value': 0.7},
      {'month': 'Mar', 'value': 0.85},
    ];

    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: months.map((item) {
          final isLatest = item['month'] == 'Mar';
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'AED ${((item['value'] as double) * 10).toStringAsFixed(1)}K',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isLatest ? AppTheme.textDark : AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: (item['value'] as double) * 90,
                    decoration: BoxDecoration(
                      color: isLatest ? AppTheme.primaryLime : const Color(0xFF2E8A99).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['month'] as String,
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionCard(String dress, String bookingId, String amount, String status, Color statusColor, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textLight.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              status == 'Credited' ? FluentIcons.arrow_download_24_regular : FluentIcons.clock_24_regular,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dress, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                const SizedBox(height: 2),
                Text(bookingId, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: statusColor == Colors.green ? AppTheme.textDark : Colors.orange)),
              const SizedBox(height: 2),
              Text(date, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight)),
            ],
          ),
        ],
      ),
    );
  }
}
