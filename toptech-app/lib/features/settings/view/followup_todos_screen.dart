import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/delete_confirmation_dialog.dart';

class FollowupTodosScreen extends StatefulWidget {
  const FollowupTodosScreen({super.key});

  @override
  State<FollowupTodosScreen> createState() => _FollowupTodosScreenState();
}

class _FollowupTodosScreenState extends State<FollowupTodosScreen> {
  final apiClient = Get.find<ApiClient>();
  final List<dynamic> _statuses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchStatuses();
  }

  Future<void> _fetchStatuses() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await apiClient.get('/followup-statuses');
      if (response.status.isOk && response.body != null) {
        setState(() {
          _statuses.clear();
          _statuses.addAll(response.body as List<dynamic>);
        });
      }
    } catch (e) {
      debugPrint('Error fetching follow-up statuses: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddStatusDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF13192F) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Follow-up Label',
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
                controller: ctrl,
                labelText: 'Followup Label',
                prefixIcon: Icons.label_important_outline_rounded,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final name = ctrl.text.trim();
                  if (name.isEmpty) return;

                  if (_statuses.any(
                    (s) =>
                        (s['name'] as String).toLowerCase() ==
                        name.toLowerCase(),
                  )) {
                    Get.snackbar(
                      'Duplicate',
                      'This follow-up label already exists.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  final response = await apiClient.post('/followup-statuses', {
                    'name': name,
                  });

                  if (response.status.isOk) {
                    Get.back();
                    _fetchStatuses();
                    Get.snackbar(
                      'Success',
                      'Follow-up label added successfully.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF2E7D32),
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAA52F0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditStatusDialog(String id, String currentName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = TextEditingController(text: currentName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF13192F) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Follow-up Label',
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
                controller: ctrl,
                labelText: 'Followup Label',
                prefixIcon: Icons.label_important_outline_rounded,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final name = ctrl.text.trim();
                  if (name.isEmpty) return;

                  final response = await apiClient.patch('/followup-statuses/$id', {
                    'name': name,
                  });

                  if (response.status.isOk) {
                    Get.back();
                    _fetchStatuses();
                    Get.snackbar(
                      'Success',
                      'Follow-up label updated successfully.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF2E7D32),
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAA52F0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF080B16) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Follow ups',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: isDark ? const Color(0xFF0C1020) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C2452),
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: const Color(0xFFAA52F0),
        onRefresh: _fetchStatuses,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFAA52F0)),
              )
            : _statuses.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: const Center(
                          child: Text(
                            'No follow-up labels available.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _statuses.length,
                    onReorder: (oldIndex, newIndex) async {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      setState(() {
                        final item = _statuses.removeAt(oldIndex);
                        _statuses.insert(newIndex, item);
                      });

                      // Prepare payload for backend
                      final List<Map<String, dynamic>> orders = [];
                      for (int i = 0; i < _statuses.length; i++) {
                        orders.add({
                          'id': _statuses[i]['id'],
                          'displayOrder': i,
                        });
                      }

                      // Save reordered list to backend database
                      await apiClient.post('/followup-statuses/reorder', {
                        'orders': orders,
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = _statuses[index];
                      final id = item['id'].toString();
                      final name = item['name'] as String? ?? '';

                      return Container(
                        key: ValueKey(id),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF13192F) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0x26FFFFFF)
                                : const Color(0x1A000000),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.drag_indicator_rounded,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0x1AAA52F0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.checklist_rtl_rounded,
                                  color: Color(0xFFAA52F0),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color:
                                  isDark ? Colors.white : const Color(0xFF1C2452),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Color(0xFFAA52F0),
                                ),
                                onPressed: () => _showEditStatusDialog(id, name),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => Get.dialog(
                                  DeleteConfirmationDialog(
                                    title: 'Delete Followup Label',
                                    message:
                                        'Are you sure you want to delete "$name"?',
                                    onDelete: () async {
                                      final response = await apiClient.delete(
                                        '/followup-statuses/$id',
                                      );
                                      if (response.status.isOk) {
                                        _fetchStatuses();
                                        Get.snackbar(
                                          'Deleted',
                                          'Follow-up label deleted successfully.',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor:
                                              const Color(0xFF2E7D32),
                                          colorText: Colors.white,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStatusDialog,
        backgroundColor: const Color(0xFFAA52F0),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
