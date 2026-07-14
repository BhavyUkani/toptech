import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/delete_confirmation_dialog.dart';
import 'followup_timeline_screen.dart';

class EnquiriesScreen extends StatefulWidget {
  const EnquiriesScreen({super.key});

  @override
  State<EnquiriesScreen> createState() => _EnquiriesScreenState();
}

class _EnquiriesScreenState extends State<EnquiriesScreen> {
  final List<dynamic> enquiries = [];
  final List<dynamic> _employeesList = [];
  bool _isLoadingEnquiries = false;
  bool _isLoadingEmployees = false;
  bool _isLoadingServices = false;
  final List<dynamic> _servicesList = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedServiceFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchEnquiries();
    _fetchEmployees();
    _fetchServices();
  }

  // Fetch enquiries list from backend API
  Future<void> _fetchEnquiries() async {
    if (!mounted) return;
    setState(() {
      _isLoadingEnquiries = true;
    });
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/enquiries');
      debugPrint('Enquiries Fetch Status: ${response.statusCode}');
      debugPrint('Enquiries Fetch Body: ${response.body}');
      debugPrint('Enquiries Fetch StatusText: ${response.statusText}');
      if (response.status.isOk && response.body != null) {
        if (mounted) {
          final authService = Get.find<AuthService>();
          final emp = authService.employee.value;
          final list = response.body as List<dynamic>;

          setState(() {
            enquiries.clear();
            if (emp != null && emp.role == 'Admin') {
              enquiries.addAll(list);
            } else {
              final empName = emp?.name ?? '';
              enquiries.addAll(
                list.where((item) {
                  final assignedName = item['assignedEmployee'] != null
                      ? item['assignedEmployee']['name']
                      : (item['assigned'] ?? '');
                  return assignedName == empName;
                }).toList(),
              );
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching enquiries: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingEnquiries = false;
        });
      }
    }
  }

  // Fetch employees list from the API for the dropdown
  Future<void> _fetchEmployees() async {
    if (!mounted) return;
    setState(() {
      _isLoadingEmployees = true;
    });
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/employees');
      debugPrint('Employees Fetch Status: ${response.statusCode}');
      debugPrint('Employees Fetch Body: ${response.body}');
      debugPrint('Employees Fetch StatusText: ${response.statusText}');
      if (response.status.isOk && response.body != null) {
        if (mounted) {
          setState(() {
            _employeesList.clear();
            _employeesList.addAll(response.body as List<dynamic>);
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching employees: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingEmployees = false;
        });
      }
    }
  }

  // Fetch services list from the API for the dropdown
  Future<void> _fetchServices() async {
    if (!mounted) return;
    setState(() {
      _isLoadingServices = true;
    });
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/services');
      if (response.status.isOk && response.body != null) {
        if (mounted) {
          setState(() {
            _servicesList.clear();
            _servicesList.addAll(response.body as List<dynamic>);
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingServices = false;
        });
      }
    }
  }

  // Show bottom sheet to add or edit an inquiry
  void _showAddEnquiryBottomSheet({int? editIndex}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final nameController = TextEditingController();
    final numberController = TextEditingController();
    final notesController = TextEditingController();
    String? selectedEmployee;
    String? selectedService;
    int? selectedServiceId;

    if (editIndex != null) {
      final item = enquiries[editIndex];
      nameController.text = item['client'] ?? '';
      numberController.text = item['number'] ?? '';
      notesController.text = item['notes'] ?? '';
      selectedEmployee = item['assignedEmployee']?['name'] ?? item['assigned'];

      if (item['serviceId'] != null) {
        selectedServiceId = item['serviceId'] as int?;
        final svc = _servicesList.firstWhere(
          (s) => s['id'] == selectedServiceId,
          orElse: () => null,
        );
        if (svc != null) {
          selectedService = svc['serviceName'] as String?;
        }
      } else if (item['product'] != null) {
        final svc = _servicesList.firstWhere(
          (s) =>
              s['serviceName'].toString().toLowerCase() ==
              item['product'].toString().toLowerCase(),
          orElse: () => null,
        );
        if (svc != null) {
          selectedService = svc['serviceName'] as String?;
          selectedServiceId = svc['id'] as int?;
        } else {
          // Fallback to storing product string if it doesn't match a seeded service
          selectedService = item['product'] as String?;
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF13192F) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                        editIndex == null ? 'Add New Enquiry' : 'Edit Enquiry',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: nameController,
                    labelText: 'Client Name',
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    controller: numberController,
                    labelText: 'Phone Number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),

                  _isLoadingServices
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          dropdownColor: isDark
                              ? const Color(0xFF13192F)
                              : Colors.white,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Product / Service Name',
                            labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 13,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            filled: false,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          initialValue: selectedService,
                          items: _servicesList.map<DropdownMenuItem<String>>((
                            svc,
                          ) {
                            final svcName =
                                svc['serviceName'] as String? ?? 'Unknown';
                            return DropdownMenuItem<String>(
                              value: svcName,
                              child: Text(svcName),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setModalState(() {
                              selectedService = val;
                              final svc = _servicesList.firstWhere(
                                (s) => s['serviceName'] == val,
                                orElse: () => null,
                              );
                              selectedServiceId = svc != null
                                  ? svc['id'] as int?
                                  : null;
                            });
                          },
                        ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    controller: notesController,
                    labelText: 'Notes',
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),

                  _isLoadingEmployees
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          dropdownColor: isDark
                              ? const Color(0xFF13192F)
                              : Colors.white,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Assign To Employee',
                            labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 13,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            filled: false,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          initialValue: selectedEmployee,
                          items: _employeesList.map<DropdownMenuItem<String>>((
                            emp,
                          ) {
                            final empName = emp['name'] as String? ?? 'Unknown';
                            return DropdownMenuItem<String>(
                              value: empName,
                              child: Text(empName),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setModalState(() {
                              selectedEmployee = val;
                            });
                          },
                        ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final number = numberController.text.trim();

                      if (name.isEmpty ||
                          number.isEmpty ||
                          selectedService == null ||
                          selectedEmployee == null) {
                        Get.snackbar(
                          'Missing Fields',
                          'Please fill all details and select an assigned employee.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                          borderRadius: 12,
                          margin: const EdgeInsets.all(16),
                        );
                        return;
                      }

                      final apiClient = Get.find<ApiClient>();
                      final selectedEmpRecord = _employeesList.firstWhere(
                        (emp) => emp['name'] == selectedEmployee,
                        orElse: () => null,
                      );
                      final int? assignedToId = selectedEmpRecord != null
                          ? selectedEmpRecord['id'] as int?
                          : null;

                      if (editIndex == null) {
                        final response = await apiClient.post('/enquiries', {
                          'client': name,
                          'number': number,
                          'product': selectedService,
                          'serviceId': selectedServiceId,
                          'assignedToId': assignedToId,
                          'status': 'New',
                          'notes': notesController.text.trim(),
                        });
                        if (response.status.isOk) {
                          _fetchEnquiries();
                        } else {
                          Get.snackbar(
                            'Error',
                            'Failed to add enquiry to database.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                          return;
                        }
                      } else {
                        final item = enquiries[editIndex];
                        final id = item['id'];
                        final response = await apiClient
                            .patch('/enquiries/$id', {
                              'client': name,
                              'number': number,
                              'product': selectedService,
                              'serviceId': selectedServiceId,
                              'assignedToId': assignedToId,
                              'notes': notesController.text.trim(),
                            });
                        if (response.status.isOk) {
                          _fetchEnquiries();
                        } else {
                          Get.snackbar(
                            'Error',
                            'Failed to update enquiry in database.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                          return;
                        }
                      }

                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      editIndex == null ? 'Submit Enquiry' : 'Save Changes',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Delete enquiry
  void _deleteEnquiry(Map<String, dynamic> item) {
    Get.dialog(
      DeleteConfirmationDialog(
        title: 'Delete Enquiry',
        message:
            'Are you sure you want to delete this enquiry? This action cannot be undone.',
        onDelete: () async {
          final id = item['id'];
          final apiClient = Get.find<ApiClient>();
          final response = await apiClient.delete('/enquiries/$id');
          if (response.status.isOk) {
            _fetchEnquiries();
            Get.snackbar(
              'Deleted',
              'Enquiry deleted successfully.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.black87,
              colorText: Colors.white,
              borderRadius: 12,
              margin: const EdgeInsets.all(16),
            );
          } else {
            Get.snackbar(
              'Error',
              'Failed to delete enquiry.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }

  void _showAddServiceDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF13192F) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? const Color(0x1AFFFFFF) : const Color(0x0D000000),
            width: 1,
          ),
        ),
        title: Text(
          'Add New Service',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: CustomTextField(
          controller: textController,
          labelText: 'Service Name',
          prefixIcon: Icons.business_center_outlined,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = textController.text.trim();
              if (name.isEmpty) {
                Get.snackbar('Error', 'Please enter a service name.');
                return;
              }
              final apiClient = Get.find<ApiClient>();
              final res = await apiClient.post('/services', {
                'serviceName': name,
              });
              if (res.status.isOk) {
                _fetchServices();
                Get.back();
                Get.snackbar(
                  'Success',
                  'Service added successfully.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.black87,
                  colorText: Colors.white,
                  borderRadius: 12,
                  margin: const EdgeInsets.all(16),
                );
              } else {
                Get.snackbar('Error', 'Failed to save service.');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _navigateToTimeline(Map<String, dynamic> item) {
    Get.to(() => FollowUpTimelineScreen(enquiry: item))?.then((_) {
      _fetchEnquiries(); // Reload on return
    });
  }

  // Helper widget to render the latest follow-up note in a concise container inside cards

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authService = Get.find<AuthService>();

    // Filter enquiries in-memory based on search text and active service filter
    final filteredEnquiries = enquiries.where((item) {
      final query = _searchController.text.trim().toLowerCase();
      final client = (item['client'] ?? '').toString().toLowerCase();
      final number = (item['number'] ?? '').toString().toLowerCase();
      final product = (item['product'] ?? '').toString().toLowerCase();
      final notes = (item['notes'] ?? '').toString().toLowerCase();

      final matchesQuery =
          query.isEmpty ||
          client.contains(query) ||
          number.contains(query) ||
          product.contains(query) ||
          notes.contains(query);

      final matchesService =
          _selectedServiceFilter == 'All' ||
          product.toLowerCase() == _selectedServiceFilter.toLowerCase();

      return matchesQuery && matchesService;
    }).toList();

    // Build the list of active services for chips
    final activeServices = [
      'All',
      ..._servicesList.map((s) => s['serviceName'] as String),
    ];

    return Scaffold(
      backgroundColor:
          Colors.transparent, // Let Scaffold of HomeView handle background
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {});
              },
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search client, phone, service, notes...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white30 : Colors.black38,
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark ? Colors.white54 : Colors.black54,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0x33FFFFFF)
                        : const Color(0x26000000),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Horizontal service chips filter
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount:
                  activeServices.length +
                  (authService.employee.value?.role == 'Admin' ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == activeServices.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ActionChip(
                      onPressed: _showAddServiceDialog,
                      backgroundColor: isDark
                          ? const Color(0xFF1E293B)
                          : Colors.grey[100],
                      side: BorderSide(
                        color: isDark
                            ? const Color(0x1AFFFFFF)
                            : const Color(0x0D000000),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      avatar: Icon(
                        Icons.add_rounded,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      label: Text(
                        'Add Service',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                }

                final svc = activeServices[index];
                final isSelected =
                    svc.toLowerCase() == _selectedServiceFilter.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    showCheckmark: false,
                    label: Text(
                      svc,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedServiceFilter = svc;
                        });
                      }
                    },
                    selectedColor: theme.colorScheme.primary,
                    backgroundColor: isDark
                        ? const Color(0xFF13192F)
                        : Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isDark
                                ? const Color(0x1AFFFFFF)
                                : const Color(0x0D000000)),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),

          // Enquiries List
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFFFE6420),
              onRefresh: _fetchEnquiries, // Pull down to refresh handler
              child: _isLoadingEnquiries && enquiries.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFE6420),
                      ),
                    )
                  : filteredEnquiries.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Text(
                              'No enquiries found.',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                      physics:
                          const AlwaysScrollableScrollPhysics(), // Ensures pull-to-refresh works even when content fits screen
                      itemCount: filteredEnquiries.length,
                      itemBuilder: (context, index) {
                        final item = filteredEnquiries[index];
                        final status = item['status'] ?? 'New';

                        Color badgeColor;
                        Color textColor;
                        switch (status) {
                          case 'New':
                            badgeColor = const Color(0x1FFE6420);
                            textColor = const Color(0xFFFE6420);
                            break;
                          case 'Pending':
                            badgeColor = isDark
                                ? const Color(0x264F60AA)
                                : const Color(0x1F1C2452);
                            textColor = isDark
                                ? const Color(0xFF8B9EDF)
                                : const Color(0xFF1C2452);
                            break;
                          case 'Completed':
                            badgeColor = const Color(0x1F2E7D32);
                            textColor = const Color(0xFF2E7D32);
                            break;
                          default:
                            badgeColor = const Color(0x1F757575);
                            textColor = const Color(0xFF757575);
                        }

                        // Find the original index in enquiries for edit matching ID
                        final int originalIndex = enquiries.indexWhere(
                          (e) => e['id'] == item['id'],
                        );

                        return Hero(
                          tag: 'enquiry_card_${item['id']}',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Card(
                              color: isDark
                                  ? const Color(0xFF13192F)
                                  : Colors.white,
                              margin: const EdgeInsets.only(bottom: 14.0),
                              elevation: 0,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isDark
                                      ? const Color(0x33FFFFFF)
                                      : const Color(0x26000000),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () => _navigateToTimeline(item),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  (item['client'] ?? 'N/A')
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF1E293B,
                                                          ),
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: badgeColor,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  status,
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "${(item['date'] ?? 'Today').toLowerCase()}  |  To: ${item['assignedEmployee']?['name'] ?? item['assigned'] ?? 'Unassigned'}  |  By: ${item['creatorEmployee']?['name'] ?? item['assignedBy'] ?? 'System'}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? Colors.white54
                                                  : Colors.black54,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                          // Product/Service Name
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.description_outlined,
                                                size: 15,
                                                color: isDark
                                                    ? const Color(0xFFFF9E73)
                                                    : const Color(0xFFFE6420),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  item['product'] ?? 'N/A',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: isDark
                                                        ? Colors.white70
                                                        : Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),

                                          // Number
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.phone_outlined,
                                                size: 15,
                                                color: isDark
                                                    ? Colors.white54
                                                    : Colors.black54,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                item['number'] ?? 'N/A',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? Colors.white70
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (item['notes'] != null &&
                                              (item['notes'] as String)
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.notes_rounded,
                                                  size: 15,
                                                  color: isDark
                                                      ? Colors.white54
                                                      : Colors.black54,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    item['notes'],
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: isDark
                                                          ? Colors.white70
                                                          : Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF0F1424)
                                          : const Color(0xFFF8FAFC),
                                      border: Border(
                                        top: BorderSide(
                                          color: isDark
                                              ? const Color(0x1AFFFFFF)
                                              : const Color(0x0D000000),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (Get.find<AuthService>()
                                                .employee
                                                .value
                                                ?.role ==
                                            'Admin')
                                          TextButton.icon(
                                            onPressed: () =>
                                                _showAddEnquiryBottomSheet(
                                                  editIndex: originalIndex,
                                                ),
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            icon: Icon(
                                              Icons.edit_outlined,
                                              size: 14,
                                              color: isDark
                                                  ? const Color(0xFFFF9E73)
                                                  : const Color(0xFF1C2452),
                                            ),
                                            label: Text(
                                              'Edit',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark
                                                    ? const Color(0xFFFF9E73)
                                                    : const Color(0xFF1C2452),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        TextButton.icon(
                                          onPressed: () =>
                                              _navigateToTimeline(item),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          icon: const Icon(
                                            Icons.sync_outlined,
                                            size: 14,
                                            color: Color(0xFFFE6420),
                                          ),
                                          label: const Text(
                                            'Follow-up',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFFE6420),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () => _deleteEnquiry(item),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 14,
                                            color: Colors.redAccent,
                                          ),
                                          label: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEnquiryBottomSheet(),
        backgroundColor: const Color(0xFFFE6420),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
