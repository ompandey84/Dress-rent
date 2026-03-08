import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/home_screen.dart';
import 'package:dress_app/screens/explore_screen.dart';
import 'package:dress_app/screens/tracking_order_screen.dart';
import 'package:dress_app/screens/profile_screen.dart';

// Placeholder screens for navigation

class CartPlaceholder extends StatelessWidget {
  const CartPlaceholder({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Center(child: Text('Cart'));
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const ExploreScreen(),
    const CartPlaceholder(),
    const TrackingOrderScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 5),
        height: 72,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                0,
                FluentIcons.home_24_filled,
                FluentIcons.home_24_regular,
              ),
              _buildNavItem(
                1,
                FluentIcons.compass_northwest_24_filled,
                FluentIcons.compass_northwest_24_regular,
              ),
              _buildCartItem(2),
              _buildNavItem(
                3,
                FluentIcons.map_24_filled,
                FluentIcons.map_24_regular,
              ),
              _buildNavItem(
                4,
                FluentIcons.person_24_filled,
                FluentIcons.person_24_regular,
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
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

  Widget _buildCartItem(int index) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.darkBackground : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Icon(
              isActive
                  ? FluentIcons.cart_24_filled
                  : FluentIcons.cart_24_regular,
              color: isActive ? AppTheme.surfaceWhite : AppTheme.textLight,
              size: 24,
            ),
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
