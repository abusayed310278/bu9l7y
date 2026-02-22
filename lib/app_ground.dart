import 'package:bu9l7y/core/constants/assets.dart';
import 'package:bu9l7y/feature/credits/views/credits_screen.dart';
import 'package:bu9l7y/feature/home/views/home_screen.dart';
import 'package:bu9l7y/feature/profile/views/profile_screen.dart';
import 'package:flutter/material.dart';

class AppGround extends StatefulWidget {
  const AppGround({
    super.key,
    this.homeScreen,
    this.creditsScreen,
    this.profileScreen,
    this.initialIndex = 0,
  });

  final Widget? homeScreen;
  final Widget? creditsScreen;
  final Widget? profileScreen;
  final int initialIndex;

  @override
  State<AppGround> createState() => _AppGroundState();
}

class _AppGroundState extends State<AppGround> {
  late int _currentIndex;

  late final List<Widget> _screens = [
    widget.homeScreen ?? const HomeScreen(),
    widget.creditsScreen ?? const CreditsScreen(),
    widget.profileScreen ?? const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFEFEF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                label: 'Home',
                iconPath: Images.home,
                isActive: _currentIndex == 0,
                onTap: () => _onTabSelected(0),
              ),
              _NavItem(
                label: 'Credits',
                iconPath: Images.credits,
                isActive: _currentIndex == 1,
                onTap: () => _onTabSelected(1),
              ),
              _NavItem(
                label: 'Profile',
                iconPath: Images.user,
                isActive: _currentIndex == 2,
                onTap: () => _onTabSelected(2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.iconPath,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final String iconPath;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final itemColor = isActive ? Colors.white : const Color(0xFF000000);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 92,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF284968) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageIcon(AssetImage(iconPath), size: 16, color: itemColor),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                height: 1,
                color: itemColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
