import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../theme.dart';
import 'listings_approval_screen.dart';
import 'damage_claims_screen.dart';
import 'support_tickets_screen.dart';
import 'users_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _index = 0;

  final _pages = const [
    _DashboardHome(),
    ListingsApprovalScreen(),
    DamageClaimsScreen(),
    SupportTicketsScreen(),
    UsersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            color: AppTheme.textDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: AppTheme.primaryLime, shape: BoxShape.circle),
                        child: const Icon(Icons.diamond, size: 18, color: AppTheme.textDark),
                      ),
                      const SizedBox(width: 10),
                      Text('DRESS', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ..._navItems.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final isSelected = i == _index;
                  return InkWell(
                    onTap: () => setState(() => _index = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryLime : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Icon(item.icon, size: 18, color: isSelected ? AppTheme.textDark : Colors.white60),
                          const SizedBox(width: 12),
                          Text(item.label, style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? AppTheme.textDark : Colors.white60,
                          )),
                        ],
                      ),
                    ),
                  );
                }),
                const Spacer(),
                const Divider(color: Colors.white12, height: 1),
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(Icons.logout, size: 18, color: Colors.white60),
                        const SizedBox(width: 12),
                        Text('Sign out', style: GoogleFonts.inter(fontSize: 13, color: Colors.white60, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main
          Expanded(child: _pages[_index]),
        ],
      ),
    );
  }

  static const _navItems = [
    _NavItem('Dashboard', Icons.dashboard),
    _NavItem('Listings', FluentIcons.tag_24_regular),
    _NavItem('Damage claims', FluentIcons.alert_24_regular),
    _NavItem('Support', FluentIcons.chat_24_regular),
    _NavItem('Users', FluentIcons.people_24_regular),
  ];
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DASHBOARD', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5)),
          Text('Today, ${DateTime.now().toString().split(' ').first}', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight)),
          const SizedBox(height: 24),
          // KPI cards
          Row(
            children: [
              Expanded(child: _kpi('Active rentals', '184', '+26 today', AppTheme.success, Icons.shopping_bag)),
              const SizedBox(width: 16),
              Expanded(child: _kpi('GMV (week)', '₹8.45L', '+24%', AppTheme.success, Icons.trending_up)),
              const SizedBox(width: 16),
              Expanded(child: _kpi('Pending listings', '12', '4 need review', AppTheme.warning, Icons.pending_actions)),
              const SizedBox(width: 16),
              Expanded(child: _kpi('Open tickets', '5', 'All within SLA', AppTheme.info, Icons.support_agent)),
            ],
          ),
          const SizedBox(height: 32),
          // Chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bookings — last 7 days', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: LineChart(LineChartData(
                    lineTouchData: const LineTouchData(enabled: false),
                    gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: AppTheme.border, strokeWidth: 1)),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(),
                      topTitles: const AxisTitles(),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          getTitlesWidget: (v, _) {
                            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            if (v.toInt() < 0 || v.toInt() >= days.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(days[v.toInt()], style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight)),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (v, _) => Text('${v.toInt()}', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight)),
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [FlSpot(0, 24), FlSpot(1, 31), FlSpot(2, 28), FlSpot(3, 42), FlSpot(4, 56), FlSpot(5, 68), FlSpot(6, 62)],
                        isCurved: true,
                        color: AppTheme.textDark,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: true, color: AppTheme.primaryLime.withOpacity(0.2)),
                      ),
                    ],
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Recent activity
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent activity', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                const SizedBox(height: 12),
                ..._mockActivity.map((a) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(color: a['color'] as Color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(a['text'] as String, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDark))),
                      Text(a['time'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpi(String label, String value, String delta, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36, height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
          const SizedBox(height: 4),
          Text(delta, style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  static const _mockActivity = [
    {'text': 'Booking confirmed: Sabyasachi Crimson Lehenga (₹14,400) by Aisha S.', 'time': '3m ago', 'color': AppTheme.success},
    {'text': 'QC Inspection passed & ₹2,500 deposit unreserved for #ORD-9805', 'time': '12m ago', 'color': AppTheme.info},
    {'text': 'New couture listing submitted: Manish Malhotra Emerald Ballgown', 'time': '28m ago', 'color': AppTheme.warning},
    {'text': 'Weekly lender payout of ₹48,200 transferred to 8 partner boutiques', 'time': '45m ago', 'color': AppTheme.success},
    {'text': 'Courier dispatched: BlueDart priority pickup for #ORD-9835', 'time': '1h ago', 'color': AppTheme.info},
    {'text': 'KYC verified & approved: Virasat Weaves, Jaipur (Vendor Partner)', 'time': '2h ago', 'color': AppTheme.success},
  ];
}
