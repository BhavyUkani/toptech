import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/delete_confirmation_dialog.dart';
import '../../auth/model/employee.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final apiClient = Get.find<ApiClient>();
  final authService = Get.find<AuthService>();
  final List<dynamic> _employees = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await apiClient.get('/employees');
      if (response.status.isOk && response.body != null) {
        setState(() {
          _employees.clear();
          _employees.addAll(response.body as List<dynamic>);
        });
      }
    } catch (e) {
      debugPrint('Error fetching employees: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddEmployeeDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final numberCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedRole = 'Employee';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF13192F) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add Employee',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black87),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: nameCtrl,
                      labelText: 'Full Name',
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: usernameCtrl,
                      labelText: 'Username',
                      prefixIcon: Icons.alternate_email_rounded,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: numberCtrl,
                      labelText: 'Phone Number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: emailCtrl,
                      labelText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: passwordCtrl,
                      labelText: 'Password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    // Role selector
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark
                              ? const Color(0x4DFFFFFF)
                              : const Color(0x42000000),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedRole,
                          dropdownColor:
                              isDark ? const Color(0xFF13192F) : Colors.white,
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF1C2452),
                            fontSize: 14,
                          ),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                          items: ['Employee', 'Admin'].map((role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Row(
                                children: [
                                  Icon(
                                    role == 'Admin'
                                        ? Icons.shield_rounded
                                        : Icons.person_rounded,
                                    size: 18,
                                    color: role == 'Admin'
                                        ? const Color(0xFFFE6420)
                                        : const Color(0xFF5B8DEF),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(role),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => selectedRole = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final username = usernameCtrl.text.trim();
                        final number = numberCtrl.text.trim();
                        final email = emailCtrl.text.trim();
                        final password = passwordCtrl.text.trim();

                        if (name.isEmpty ||
                            username.isEmpty ||
                            number.isEmpty ||
                            password.isEmpty) {
                          Get.snackbar(
                            'Missing Fields',
                            'Please fill in all required fields.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        final response = await apiClient.post('/employees', {
                          'name': name,
                          'username': username,
                          'number': number,
                          'email': email,
                          'password': password,
                          'role': selectedRole,
                        });

                        if (response.status.isOk) {
                          Get.back();
                          _fetchEmployees();
                          Get.snackbar(
                            'Success',
                            'Employee added successfully.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF2E7D32),
                            colorText: Colors.white,
                          );
                        } else {
                          Get.snackbar(
                            'Error',
                            'Failed to add employee. Please try again.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFE6420),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _roleColor(String role) {
    return role == 'Admin' ? const Color(0xFFFE6420) : const Color(0xFF5B8DEF);
  }

  IconData _roleIcon(String role) {
    return role == 'Admin' ? Icons.shield_rounded : Icons.person_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loggedInId = authService.employee.value?.id;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF080B16) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Employees',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: isDark ? const Color(0xFF0C1020) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C2452),
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFE6420),
        onRefresh: _fetchEmployees,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFE6420)),
              )
            : _employees.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: const Center(
                      child: Text(
                        'No employees found.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _employees.length,
                itemBuilder: (context, index) {
                  final emp = _employees[index];
                  final empId = emp['id'] as int;
                  final name = emp['name'] as String? ?? 'Unknown';
                  final username = emp['username'] as String? ?? '';
                  final number = emp['number'] as String? ?? '';
                  final role = emp['role'] as String? ?? 'Employee';
                  final isSelf = empId == loggedInId;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF13192F) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0x26FFFFFF)
                            : const Color(0x1A000000),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: _roleColor(role).withOpacity(0.15),
                            child: Text(
                              name.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: _roleColor(role),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1C2452),
                                      ),
                                    ),
                                    if (isSelf) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFFE6420,
                                          ).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'YOU',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFE6420),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '@$username • $number',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _roleColor(role).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _roleIcon(role),
                                      size: 11,
                                      color: _roleColor(role),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      role.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _roleColor(role),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => _showEditEmployeeDialog(emp),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.edit_outlined,
                                        color: Color(0xFFFE6420),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  if (!isSelf) ...[
                                    const SizedBox(width: 8),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () => Get.dialog(
                                        DeleteConfirmationDialog(
                                          title: 'Remove Employee',
                                          message:
                                              'Are you sure you want to remove "$name"?',
                                          onDelete: () async {
                                            final response = await apiClient.delete(
                                              '/employees/$empId',
                                            );
                                            if (response.status.isOk) {
                                              _fetchEmployees();
                                              Get.snackbar(
                                                'Removed',
                                                'Employee removed successfully.',
                                                snackPosition:
                                                    SnackPosition.BOTTOM,
                                                backgroundColor: const Color(
                                                  0xFF2E7D32,
                                                ),
                                                colorText: Colors.white,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.redAccent,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEmployeeDialog,
        backgroundColor: const Color(0xFFFE6420),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }

  void _showEditEmployeeDialog(Map<String, dynamic> emp) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameCtrl = TextEditingController(text: emp['name']);
    final usernameCtrl = TextEditingController(text: emp['username']);
    final numberCtrl = TextEditingController(text: emp['number']);
    final emailCtrl = TextEditingController(text: emp['email']);
    final passwordCtrl = TextEditingController();
    String selectedRole = emp['role'] ?? 'Employee';
    final empId = emp['id'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF13192F) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Employee',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black87),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: nameCtrl,
                      labelText: 'Full Name',
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: usernameCtrl,
                      labelText: 'Username',
                      prefixIcon: Icons.alternate_email_rounded,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: numberCtrl,
                      labelText: 'Phone Number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: emailCtrl,
                      labelText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: passwordCtrl,
                      labelText: 'Password (leave blank to keep current)',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark
                              ? const Color(0x4DFFFFFF)
                              : const Color(0x42000000),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedRole,
                          dropdownColor:
                              isDark ? const Color(0xFF13192F) : Colors.white,
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF1C2452),
                            fontSize: 14,
                          ),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                          items: ['Employee', 'Admin'].map((role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Row(
                                children: [
                                  Icon(
                                    role == 'Admin'
                                        ? Icons.shield_rounded
                                        : Icons.person_rounded,
                                    size: 18,
                                    color: role == 'Admin'
                                        ? const Color(0xFFFE6420)
                                        : const Color(0xFF5B8DEF),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(role),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => selectedRole = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final username = usernameCtrl.text.trim();
                        final number = numberCtrl.text.trim();
                        final email = emailCtrl.text.trim();
                        final password = passwordCtrl.text.trim();

                        if (name.isEmpty || username.isEmpty || number.isEmpty) {
                          Get.snackbar(
                            'Missing Fields',
                            'Please fill in all required fields.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        final data = {
                          'name': name,
                          'username': username,
                          'number': number,
                          'email': email,
                          'role': selectedRole,
                        };
                        if (password.isNotEmpty) {
                          data['password'] = password;
                        }

                        final response = await apiClient.patch('/employees/$empId', data);

                        if (response.status.isOk) {
                          Get.back();
                          _fetchEmployees();
                          Get.snackbar(
                            'Success',
                            'Employee updated successfully.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF2E7D32),
                            colorText: Colors.white,
                          );
                        } else {
                          Get.snackbar(
                            'Error',
                            'Failed to update employee.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFE6420),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
