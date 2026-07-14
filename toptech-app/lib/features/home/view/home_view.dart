import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/model/employee.dart';
import '../../enquiries/view/enquiries_screen.dart';
import '../../price_list/view/price_list_screen.dart';
import '../../settings/view/settings_screen.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  final authService = Get.find<AuthService>();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // Fetch logged-in profile if null or to update cache
  Future<void> _fetchProfile() async {
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/auth/profile');
      if (response.status.isOk && response.body != null) {
        final emp = Employee.fromJson(response.body as Map<String, dynamic>);
        authService.employee.value = emp;
        final storage = Get.find<StorageService>();
        await storage.saveEmployee(jsonEncode(emp.toJson()));
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
    _checkFollowUpReminders(); // Check alarms on startup
  }

  // Check database for active follow-up alarms and prompt in-screen dialog popups on startup
  Future<void> _checkFollowUpReminders() async {
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/enquiries');
      if (response.status.isOk && response.body != null) {
        final list = response.body as List<dynamic>;
        final emp = authService.employee.value;
        if (emp == null) return;

        final now = DateTime.now();
        final List<dynamic> dueReminders = [];

        for (var item in list) {
          final reminderDateStr = item['reminderDate'] as String?;
          if (reminderDateStr != null && reminderDateStr.isNotEmpty) {
            try {
              final reminderTime = DateTime.parse(reminderDateStr);
              // Trigger reminder if due or past due
              if (reminderTime.isBefore(now.add(const Duration(minutes: 2)))) {
                final assignedToName = item['assignedEmployee'] != null
                    ? item['assignedEmployee']['name']
                    : (item['assigned'] ?? '');
                if (emp.role == 'Admin' || assignedToName == emp.name) {
                  dueReminders.add(item);
                }
              }
            } catch (e) {
              debugPrint('Error parsing reminder date: $e');
            }
          }
        }

        if (dueReminders.isNotEmpty) {
          // Show local visual notification banner
          Get.snackbar(
            '⏰ Follow-up Reminder',
            'You have ${dueReminders.length} scheduled follow-up reminder(s) due now.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFFE6420),
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 6),
          );

          // Show in-screen popup alert dialog
          Get.dialog(
            AlertDialog(
              backgroundColor:
                  Theme.of(Get.context!).brightness == Brightness.dark
                  ? const Color(0xFF13192F)
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Row(
                children: [
                  Icon(Icons.alarm_on_rounded, color: Color(0xFFFE6420)),
                  SizedBox(width: 10),
                  Text(
                    'Follow-up Reminders',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: dueReminders.length,
                  itemBuilder: (context, index) {
                    final item = dueReminders[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (item['client'] ?? 'N/A').toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Product: ${item['product'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 12.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Contact: ${item['number'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 12.5),
                          ),
                          const Divider(),
                        ],
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    // Acknowledge and clear reminderDate on database for all these items
                    final apiClient = Get.find<ApiClient>();
                    for (var item in dueReminders) {
                      await apiClient.patch('/enquiries/${item['id']}', {
                        'reminderDate': '',
                      });
                    }
                    Get.back();
                  },
                  child: const Text(
                    'Dismiss & Acknowledge',
                    style: TextStyle(
                      color: Color(0xFFFE6420),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            barrierDismissible: false,
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking reminders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final isAdmin = authService.employee.value?.role == 'Admin';
      final List<Widget> screens = [
        const EnquiriesScreen(),
        const PriceListScreen(),
        if (isAdmin) const SettingsScreen(),
      ];

      return Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF080B16)
            : const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.contain,
              height: 40,
            ),
          ),
          backgroundColor: isDark ? const Color(0xFF0C1020) : Colors.white,
          foregroundColor: isDark ? Colors.white : const Color(0xFF1C2452),
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: PopupMenuButton<void>(
                offset: const Offset(0, 50),
                color: isDark ? const Color(0xFF13192F) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0x1AFFFFFF)
                        : const Color(0x0D000000),
                    width: 1,
                  ),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  child: Text(
                    (authService.employee.value?.name ?? 'U')
                        .substring(0, 1)
                        .toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                itemBuilder: (context) {
                  final emp = authService.employee.value;
                  return [
                    PopupMenuItem<void>(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            emp?.name ?? 'User',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            emp?.number ?? 'No phone',
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              (emp?.role ?? 'Employee').toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                fontSize: 9,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<void>(
                      onTap: () => authService.logout(),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            size: 18,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ),
          ],
        ),
        body: screens[_currentIndex < screens.length ? _currentIndex : 0],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex < screens.length ? _currentIndex : 0,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: isDark ? const Color(0xFF0C1020) : Colors.white,
          indicatorColor: const Color(0x26FE6420),
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.forum_outlined,
                color: isDark ? Colors.white70 : const Color(0xFF1C2452),
              ),
              selectedIcon: const Icon(Icons.forum, color: Color(0xFFFE6420)),
              label: 'Enquiries',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.receipt_long_outlined,
                color: isDark ? Colors.white70 : const Color(0xFF1C2452),
              ),
              selectedIcon: const Icon(
                Icons.receipt_long,
                color: Color(0xFFFE6420),
              ),
              label: 'Price List',
            ),
            if (isAdmin)
              NavigationDestination(
                icon: Icon(
                  Icons.settings_outlined,
                  color: isDark ? Colors.white70 : const Color(0xFF1C2452),
                ),
                selectedIcon: const Icon(
                  Icons.settings_rounded,
                  color: Color(0xFFFE6420),
                ),
                label: 'Settings',
              ),
          ],
        ),
      );
    });
  }
}
