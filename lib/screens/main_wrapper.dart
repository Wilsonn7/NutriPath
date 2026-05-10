import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import 'home/dashboard_screen.dart';
import 'scan/scan_screen.dart';
import 'history/history_screen.dart';
import 'search/search_screen.dart';
import 'insight/insight_screen.dart';
import 'profile/profile_screen.dart';
import '../core/theme.dart';
import '../state/auth_provider.dart';
import '../state/nutrition_provider.dart';
import 'package:provider/provider.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  String? _syncedEmail;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ScanScreen(),
    const HistoryScreen(),
    const SearchScreen(),
    const InsightScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentEmail = auth.currentUser?.email;
    if (_syncedEmail != currentEmail) {
      _syncedEmail = currentEmail;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<NutritionProvider>().syncForUser(currentEmail);
        }
      });
    }

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: AppTheme.glowingShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: AppTheme.surface.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, LucideIcons.layoutDashboard, 'Home'),
                    _buildNavItem(1, LucideIcons.scanLine, 'Scan'),
                    _buildNavItem(2, LucideIcons.history, 'History'),
                    _buildNavItem(3, LucideIcons.search, 'Search'),
                    _buildNavItem(4, LucideIcons.sparkles, 'Insight'),
                    _buildNavItem(5, LucideIcons.user, 'Profile'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.glowingShadow,
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppTheme.textSecondary, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
