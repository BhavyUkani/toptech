import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../price_list/view/categories_screen.dart';
import 'employees_screen.dart';
import 'services_screen.dart';
import 'followup_todos_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final menuItems = [
      _SettingsMenuItem(
        icon: Icons.people_alt_rounded,
        iconColor: const Color(0xFF5B8DEF),
        bgColor: const Color(0x1A5B8DEF),
        title: 'Employees',
        subtitle: 'Manage employee accounts & roles',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const EmployeesScreen())),
      ),
      _SettingsMenuItem(
        icon: Icons.category_rounded,
        iconColor: const Color(0xFFFE6420),
        bgColor: const Color(0x1AFE6420),
        title: 'Product Categories',
        subtitle: 'Add & remove product categories',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const _FullScreenWrapper(
              title: 'Product Categories',
              child: CategoriesScreen(),
            ),
          ),
        ),
      ),
      _SettingsMenuItem(
        icon: Icons.miscellaneous_services_rounded,
        iconColor: const Color(0xFF2ECC71),
        bgColor: const Color(0x1A2ECC71),
        title: 'Services',
        subtitle: 'Manage service offerings',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ServicesScreen())),
      ),
      _SettingsMenuItem(
        icon: Icons.checklist_rtl_rounded,
        iconColor: const Color(0xFFAA52F0),
        bgColor: const Color(0x1AAA52F0),
        title: 'Follow ups',
        subtitle: 'View & manage all follow-up reminders',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const FollowupTodosScreen())),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header

          // Menu items
          ...menuItems.map(
            (item) => _SettingsMenuCard(item: item, isDark: isDark),
          ),
        ],
      ),
    );
  }
}

class _SettingsMenuCard extends StatelessWidget {
  final _SettingsMenuItem item;
  final bool isDark;

  const _SettingsMenuCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13192F) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0x26FFFFFF) : const Color(0x1A000000),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: item.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1C2452),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white30 : Colors.black26,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsMenuItem {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsMenuItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

/// Wraps a screen with a proper AppBar for push navigation
class _FullScreenWrapper extends StatelessWidget {
  final String title;
  final Widget child;

  const _FullScreenWrapper({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF080B16)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: isDark ? const Color(0xFF0C1020) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C2452),
        elevation: 0,
      ),
      body: child,
    );
  }
}
