import 'package:flutter/material.dart';
import 'package:toptech_bloc_app/core/theme/app_theme.dart';
import 'package:toptech_bloc_app/features/enquiries/presentation/screens/enquiries_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<String> _titles = const [
    'Enquiries',
    'Task',
    'Price List',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const EnquiriesView(),
          _buildEmptyTab(
            title: 'Tasks',
            icon: Icons.task_alt_outlined,
            description: 'No active tasks available.',
          ),
          _buildEmptyTab(
            title: 'Price List',
            icon: Icons.sell_outlined,
            description: 'Price list will appear here.',
          ),
          _buildEmptyTab(
            title: 'Profile',
            icon: Icons.person_outline_rounded,
            description: 'User profile details.',
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: isDark ? AppTheme.cardDark : const Color(0xFFF8FAFC),
        indicatorColor: AppTheme.secondary.withValues(alpha: 0.2),
        elevation: 2,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(
              Icons.assignment_rounded,
              color: AppTheme.secondary,
            ),
            label: 'Enquiries',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(
              Icons.task_alt_rounded,
              color: AppTheme.secondary,
            ),
            label: 'Task',
          ),
          NavigationDestination(
            icon: Icon(Icons.sell_outlined),
            selectedIcon: Icon(
              Icons.sell_rounded,
              color: AppTheme.secondary,
            ),
            label: 'Price List',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(
              Icons.person_rounded,
              color: AppTheme.secondary,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTab({
    required String title,
    required IconData icon,
    required String description,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
