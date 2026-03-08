import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';

class VendorBookingsScreen extends StatefulWidget {
  const VendorBookingsScreen({super.key});

  @override
  State<VendorBookingsScreen> createState() => _VendorBookingsScreenState();
}

class _VendorBookingsScreenState extends State<VendorBookingsScreen> {
  String selectedTab = 'Active';

  final List<Map<String, dynamic>> bookings = [
    {
      'id': 'BK-2841',
      'dress': 'Premium Hoodie',
      'dates': 'Mar 20 – Mar 23',
      'customer': 'Arafat Khan',
      'status': 'Pending',
    },
    {
      'id': 'BK-2840',
      'dress': 'Denim Jacket',
      'dates': 'Mar 18 – Mar 20',
      'customer': 'Sara Ahmed',
      'status': 'Ready',
    },
    {
      'id': 'BK-2839',
      'dress': 'Casual T-Shirt',
      'dates': 'Mar 15 – Mar 17',
      'customer': 'David Lee',
      'status': 'Dispatched',
    },
    {
      'id': 'BK-2835',
      'dress': 'Summer Dress',
      'dates': 'Mar 10 – Mar 12',
      'customer': 'Priya Sharma',
      'status': 'Returned',
    },
  ];

  List<Map<String, dynamic>> get filteredBookings {
    if (selectedTab == 'Active') {
      return bookings.where((b) => b['status'] != 'Returned').toList();
    } else if (selectedTab == 'Pending') {
      return bookings.where((b) => b['status'] == 'Pending').toList();
    } else {
      return bookings.where((b) => b['status'] == 'Returned').toList();
    }
  }

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
          'BOOKINGS',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0),
        ),
      ),
      body: Column(
        children: [
          // Tab filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Active', 'Pending', 'Completed'].map((tab) {
                  final isSelected = selectedTab == tab;
                  return GestureDetector(
                    onTap: () => setState(() => selectedTab = tab),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.textDark : const Color(0xFFF6F8FA),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        tab,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppTheme.textLight,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Booking cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filteredBookings.length,
              itemBuilder: (context, index) => _buildBookingCard(filteredBookings[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status'] as String;
    Color statusColor;
    switch (status) {
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Ready':
        statusColor = const Color(0xFF2E8A99);
        break;
      case 'Dispatched':
        statusColor = Colors.blue;
        break;
      case 'Returned':
        statusColor = Colors.green;
        break;
      default:
        statusColor = AppTheme.textLight;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.textLight.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(booking['id'], style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textLight)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(status, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dress & Customer
          Text(booking['dress'], style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(FluentIcons.person_24_regular, size: 14, color: AppTheme.textLight),
              const SizedBox(width: 6),
              Text(booking['customer'], style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight, fontWeight: FontWeight.w500)),
              const SizedBox(width: 16),
              const Icon(FluentIcons.calendar_24_regular, size: 14, color: AppTheme.textLight),
              const SizedBox(width: 6),
              Text(booking['dates'], style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: _buildActionButtons(booking),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(Map<String, dynamic> booking) {
    String status = booking['status'];
    switch (status) {
      case 'Pending':
        return [
          _buildActionBtn('Accept', AppTheme.primaryLime, AppTheme.textDark, true, () {
            setState(() => booking['status'] = 'Ready');
            _showSnack('Booking Accepted!');
          }),
          const SizedBox(width: 8),
          _buildActionBtn('Decline', Colors.transparent, AppTheme.textLight, false, () {
            setState(() => bookings.remove(booking));
            _showSnack('Booking Declined');
          }),
        ];
      case 'Ready':
        return [
          _buildActionBtn('Mark Dispatched', AppTheme.primaryLime, AppTheme.textDark, true, () {
            setState(() => booking['status'] = 'Dispatched');
            _showSnack('Item Dispatched!');
          }),
        ];
      case 'Dispatched':
        return [
          _buildActionBtn('Mark Returned', AppTheme.primaryLime, AppTheme.textDark, true, () {
            setState(() => booking['status'] = 'Returned');
            _showSnack('Item Returned successfully!');
          }),
        ];
      case 'Returned':
        return [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 14, color: Colors.green),
                const SizedBox(width: 6),
                Text('Completed', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.green)),
              ],
            ),
          ),
        ];
      default:
        return [];
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.textDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildActionBtn(String label, Color bgColor, Color textColor, bool isFilled, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isFilled ? bgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            border: isFilled ? null : Border.all(color: AppTheme.textLight.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
