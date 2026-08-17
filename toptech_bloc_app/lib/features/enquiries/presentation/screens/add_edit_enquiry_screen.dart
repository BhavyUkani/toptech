import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:toptech_bloc_app/core/theme/app_theme.dart';
import 'package:toptech_bloc_app/core/utils/snackbar_utils.dart';
import 'package:toptech_bloc_app/features/auth/presentation/bloc/login_bloc.dart';
import 'package:toptech_bloc_app/features/enquiries/data/models/enquiry_model.dart';
import 'package:toptech_bloc_app/features/enquiries/presentation/bloc/enquiry_bloc.dart';
import 'package:toptech_bloc_app/features/enquiries/presentation/bloc/enquiry_event.dart';

class AddEditEnquiryScreen extends StatefulWidget {
  final EnquiryModel? enquiry;

  const AddEditEnquiryScreen({
    super.key,
    this.enquiry,
  });

  @override
  State<AddEditEnquiryScreen> createState() => _AddEditEnquiryScreenState();
}

class _AddEditEnquiryScreenState extends State<AddEditEnquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clientController;
  late TextEditingController _numberController;
  late TextEditingController _notesController;

  late String _selectedProduct;
  late String _selectedPriority;
  late int _selectedAssignedId;

  @override
  void initState() {
    super.initState();
    final enquiry = widget.enquiry;
    final loginState = context.read<LoginBloc>().state;
    final profile = loginState.userProfile;

    _clientController = TextEditingController(text: enquiry?.client ?? '');
    _numberController = TextEditingController(text: enquiry?.number ?? '');
    _notesController = TextEditingController(text: enquiry?.notes ?? '');

    _selectedProduct = enquiry?.product ?? '';
    _selectedPriority = enquiry?.priority ?? 'Medium';
    _selectedAssignedId = enquiry?.assignedToId ?? (profile?.id ?? 0);
  }

  @override
  void dispose() {
    _clientController.dispose();
    _numberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loginState = context.watch<LoginBloc>().state;
    final profile = loginState.userProfile;
    final isAdmin = profile?.isAdmin ?? false;
    final token = loginState.token ?? '';

    final enquiryBlocState = context.watch<EnquiryBloc>().state;
    final employees = enquiryBlocState.employeesList;
    final servicesList = enquiryBlocState.servicesList;

    // Build unique list of services fetched from toptech-api /services
    final serviceOptions = servicesList
        .map((s) => (s['serviceName'] as String?) ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();

    if (serviceOptions.isEmpty) {
      serviceOptions.addAll(['General', 'Web Development', 'Mobile App', 'SEO / Marketing']);
    }

    if (_selectedProduct.isEmpty) {
      _selectedProduct = serviceOptions.first;
    } else if (!serviceOptions.contains(_selectedProduct)) {
      serviceOptions.insert(0, _selectedProduct);
    }

    final isEdit = widget.enquiry != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Enquiry' : 'New Enquiry',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Client Name Field
                    Text('Client Name', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _clientController,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Enter client full name',
                        prefixIcon: Icon(Icons.person_outline_rounded, size: 18),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Client name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Phone Number Field
                    Text('Phone Number', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _numberController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 14),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: 'Enter phone number',
                        prefixIcon: Icon(Icons.phone_android_rounded, size: 18),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Service / Product Dropdown (Fetched from API)
                    Text('Service / Product', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedProduct,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.grid_view_rounded, size: 18),
                      ),
                      items: serviceOptions.map((svc) {
                        return DropdownMenuItem<String>(
                          value: svc,
                          child: Text(
                            svc,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedProduct = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Priority & Assign To Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Priority Dropdown
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Priority', style: theme.textTheme.labelLarge),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedPriority,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                items: ['High', 'Medium', 'Low'].map((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: Text(p),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedPriority = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Assigned Employee
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Assign To', style: theme.textTheme.labelLarge),
                              const SizedBox(height: 6),
                              isAdmin && employees.isNotEmpty
                                  ? DropdownButtonFormField<int>(
                                      initialValue: employees.any((e) => e['id'] == _selectedAssignedId)
                                          ? _selectedAssignedId
                                          : employees.first['id'] as int,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                      items: employees.map((emp) {
                                        final id = emp['id'] as int;
                                        final name = emp['name'] as String? ?? 'Employee';
                                        return DropdownMenuItem(
                                          value: id,
                                          child: Text(
                                            name,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _selectedAssignedId = val);
                                        }
                                      },
                                    )
                                  : TextFormField(
                                      enabled: false,
                                      initialValue: profile?.name ?? 'Self',
                                      style: const TextStyle(fontSize: 14),
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.lock_outline_rounded, size: 18),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Notes Field
                    Text('Notes', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Add notes or specific requirements...',
                        prefixIcon: Icon(Icons.notes_rounded, size: 18),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Button
                    SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondary,
                          foregroundColor: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;

                          final client = _clientController.text.trim();
                          final number = _numberController.text.trim();
                          final notes = _notesController.text.trim();

                          if (!isEdit) {
                            // Create Enquiry
                            context.read<EnquiryBloc>().add(
                                  CreateEnquiry(
                                    token: token,
                                    client: client,
                                    number: number,
                                    product: _selectedProduct,
                                    priority: _selectedPriority,
                                    notes: notes,
                                    assignedToId: isAdmin ? _selectedAssignedId : (profile?.id ?? 0),
                                    userRole: profile?.role ?? 'Employee',
                                    userEmployeeId: profile?.id ?? 0,
                                    userEmployeeName: profile?.name ?? '',
                                  ),
                                );
                            AppSnackBar.showSuccess('Enquiry created successfully');
                          } else {
                            // Update Enquiry
                            context.read<EnquiryBloc>().add(
                                  UpdateEnquiry(
                                    token: token,
                                    enquiryId: widget.enquiry!.id,
                                    client: client,
                                    number: number,
                                    product: _selectedProduct,
                                    priority: _selectedPriority,
                                    notes: notes,
                                    assignedToId: isAdmin ? _selectedAssignedId : (profile?.id ?? 0),
                                    userRole: profile?.role ?? 'Employee',
                                    userEmployeeId: profile?.id ?? 0,
                                    userEmployeeName: profile?.name ?? '',
                                  ),
                                );
                            AppSnackBar.showSuccess('Enquiry updated successfully');
                          }

                          context.pop();
                        },
                        child: Text(
                          isEdit ? 'Save Changes' : 'Submit Enquiry',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
