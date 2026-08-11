import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/home_screen.dart';
import 'package:dress_app/screens/cart_screen.dart';
import 'package:dress_app/screens/vendor/my_wardrobe_screen.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/screens/vendor/vendor_dashboard_screen.dart';
import 'package:dress_app/screens/reels_screen.dart';
import 'package:dress_app/screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  /// 5 tabs: Home, Bag, [Reel (center)], Wardrobe/Dashboard, Profile.
  /// The center "Reel" button is rendered as a circular floating button
  /// to stand out, exactly like Instagram / ShareChat.
  static const int _reelIndex = 2;

  List<Widget> _getPages(bool isVendor) {
    return [
      const HomeScreen(),
      const CartScreen(),
      const ReelsScreen(),
      isVendor ? const VendorDashboardScreen() : const MyWardrobeScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isVendor = Provider.of<AppState>(context).currentUser.isVendor;
    final pages = _getPages(isVendor);

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvoked: (didPop) {
        if (!didPop) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        extendBody: true,
        body: pages[_currentIndex],
        bottomNavigationBar: _buildBottomBar(isVendor),
      ),
    );
  }

  Widget _buildBottomBar(bool isVendor) {
    return Container(
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
      child: SizedBox(
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem(0, FluentIcons.home_24_filled,
                FluentIcons.home_24_regular),
            _buildNavItem(1, FluentIcons.shopping_bag_24_filled,
                FluentIcons.shopping_bag_24_regular),
            // Center Reel button — a circular floating button to stand out
            _buildReelButton(),
            _buildNavItem(3, FluentIcons.clothes_hanger_24_filled,
                FluentIcons.clothes_hanger_24_regular),
            _buildNavItem(4, FluentIcons.person_24_filled,
                FluentIcons.person_24_regular),
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

  /// The center "Reel" button. Slightly larger and uses the lime accent
  /// to draw the eye; opens the Reels feed (Instagram / ShareChat pattern).
  Widget _buildReelButton() {
    final bool isActive = _currentIndex == _reelIndex;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = _reelIndex),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE4F4FA), AppTheme.primaryLime],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.textDark, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryLime.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          isActive
              ? FluentIcons.video_24_filled
              : FluentIcons.video_24_regular,
          color: AppTheme.textDark,
          size: 26,
        ),
      ),
    );
  }
}
