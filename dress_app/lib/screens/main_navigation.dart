import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/home_screen.dart';
import 'package:dress_app/screens/cart_screen.dart';
import 'package:dress_app/screens/vendor/my_wardrobe_screen.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/screens/vendor/vendor_dashboard_screen.dart';
import 'package:dress_app/screens/vendor/vendor_add_item_screen.dart';
import 'package:dress_app/screens/vendor/vendor_bookings_screen.dart';
import 'package:dress_app/screens/vendor/vendor_inventory_screen.dart';
import 'package:dress_app/screens/vendor/vendor_financials_screen.dart';
import 'package:dress_app/screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  bool _showVendorMenu = false;

  List<Widget> _getPages(bool isVendor) {
    return [
      const HomeScreen(),
      const CartScreen(),
      isVendor ? const VendorDashboardScreen() : const MyWardrobeScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isVendor = Provider.of<AppState>(context).currentUser.isVendor;
    final pages = _getPages(isVendor);

    return PopScope(
      canPop: _currentIndex == 0 && !_showVendorMenu,
      onPopInvoked: (didPop) {
        if (!didPop) {
          setState(() {
            if (_showVendorMenu) {
              _showVendorMenu = false;
            } else {
              _currentIndex = 0;
            }
          });
        }
      },
      child: Scaffold(
        extendBody: true,
        body: pages[_currentIndex],
        bottomNavigationBar: Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 15),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 1),
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showVendorMenu && isVendor)
                _buildExtendedVendorMenu(context),
              Container(
                height: 72,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, FluentIcons.home_24_filled,
                        FluentIcons.home_24_regular, isVendor),
                    _buildNavItem(1, FluentIcons.shopping_bag_24_filled,
                        FluentIcons.shopping_bag_24_regular, isVendor),
                    _buildNavItem(2, FluentIcons.clothes_hanger_24_filled,
                        FluentIcons.clothes_hanger_24_regular, isVendor),
                    _buildNavItem(3, FluentIcons.person_24_filled,
                        FluentIcons.person_24_regular, isVendor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData activeIcon, IconData inactiveIcon, bool isVendor) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          if (index == 2 && isVendor) {
            _showVendorMenu = true;
          } else {
            _showVendorMenu = false;
          }
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.darkBackground : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isActive ? activeIcon : inactiveIcon,
          color: isActive ? AppTheme.surfaceWhite : AppTheme.textLight,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildExtendedVendorMenu(BuildContext context) {
    // Increased to 85% of the screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final menuWidth = screenWidth * 0.85;

    return Container(
      width: menuWidth,
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8), // Slightly lighter nested wrapper
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMenuAction(FluentIcons.add_circle_24_regular, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const VendorAddItemScreen()));
          }),
          _buildMenuAction(FluentIcons.calendar_24_regular, () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const VendorBookingsScreen()));
          }),
          _buildMenuAction(FluentIcons.box_24_regular, () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const VendorInventoryScreen()));
          }),
          _buildMenuAction(FluentIcons.money_24_regular, () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const VendorFinancialsScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildMenuAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryLime.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.textDark, size: 24),
      ),
    );
  }
}
