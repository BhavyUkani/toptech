import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/delete_confirmation_dialog.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final apiClient = Get.find<ApiClient>();
  final List<dynamic> _services = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await apiClient.get('/services');
      if (response.status.isOk && response.body != null) {
        setState(() {
          _services.clear();
          _services.addAll(response.body as List<dynamic>);
        });
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddServiceDialog() {
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
                    'Add Service',
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
                labelText: 'Service Name',
                prefixIcon: Icons.miscellaneous_services_rounded,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final name = ctrl.text.trim();
                  if (name.isEmpty) return;

                  if (_services.any(
                    (s) =>
                        (s['serviceName'] as String).toLowerCase() ==
                        name.toLowerCase(),
                  )) {
                    Get.snackbar(
                      'Duplicate',
                      'This service already exists.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  final response = await apiClient.post('/services', {
                    'serviceName': name,
                  });

                  if (response.status.isOk) {
                    Get.back();
                    _fetchServices();
                    Get.snackbar(
                      'Success',
                      'Service added successfully.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF2E7D32),
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF080B16) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Services',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: isDark ? const Color(0xFF0C1020) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C2452),
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: const Color(0xFF2ECC71),
        onRefresh: _fetchServices,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
              )
            : _services.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: const Center(
                      child: Text(
                        'No services available.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final item = _services[index];
                  final svcId = item['id'].toString();
                  final svcName = item['serviceName'] as String? ?? '';

                  return Container(
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
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0x1A2ECC71),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.miscellaneous_services_rounded,
                          color: Color(0xFF2ECC71),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        svcName,
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
                              color: Color(0xFF2ECC71),
                            ),
                            onPressed: () => _showEditServiceDialog(svcId, svcName),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => Get.dialog(
                              DeleteConfirmationDialog(
                                title: 'Delete Service',
                                message:
                                    'Are you sure you want to delete "$svcName"?',
                                onDelete: () async {
                                  final response =
                                      await apiClient.delete('/services/$svcId');
                                  if (response.status.isOk) {
                                    _fetchServices();
                                    Get.snackbar(
                                      'Deleted',
                                      'Service deleted successfully.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFF2E7D32),
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
        onPressed: _showAddServiceDialog,
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditServiceDialog(String svcId, String currentName) {
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
                    'Edit Service',
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
                labelText: 'Service Name',
                prefixIcon: Icons.miscellaneous_services_rounded,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final name = ctrl.text.trim();
                  if (name.isEmpty) return;

                  final response = await apiClient.patch('/services/$svcId', {
                    'serviceName': name,
                  });

                  if (response.status.isOk) {
                    Get.back();
                    _fetchServices();
                    Get.snackbar(
                      'Success',
                      'Service updated successfully.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF2E7D32),
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
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
}
