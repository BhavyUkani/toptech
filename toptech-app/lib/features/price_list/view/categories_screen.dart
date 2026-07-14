import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/delete_confirmation_dialog.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final apiClient = Get.find<ApiClient>();
  final List<dynamic> _categoriesData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await apiClient.get('/categories');
      if (response.status.isOk && response.body != null) {
        setState(() {
          _categoriesData.clear();
          _categoriesData.addAll(response.body as List<dynamic>);
        });
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Bottom sheet to add new category
  void _showAddCategoryDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final catController = TextEditingController();

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
                    'Add Category',
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
                controller: catController,
                labelText: 'Category Name',
                prefixIcon: Icons.category_outlined,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final catName = catController.text.trim();
                  if (catName.isEmpty) return;

                  if (_categoriesData.any(
                    (c) =>
                        (c['name'] as String).toLowerCase() ==
                        catName.toLowerCase(),
                  )) {
                    Get.snackbar(
                      'Duplicate Category',
                      'Category already exists.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  final response = await apiClient.post('/categories', {
                    'name': catName,
                  });
                  if (response.status.isOk) {
                    Get.back();
                    _fetchCategories();
                    Get.snackbar(
                      'Success',
                      'Category added successfully.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF2E7D32),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: const Color(0xFFFE6420),
        onRefresh: _fetchCategories,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFE6420)),
              )
            : _categoriesData.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: const Center(
                      child: Text(
                        'No categories available.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _categoriesData.length,
                itemBuilder: (context, index) {
                  final item = _categoriesData[index];
                  final catId = item['id'].toString();
                  final catName = item['name'] as String;

                  return Card(
                    color: isDark ? const Color(0xFF13192F) : Colors.white,
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
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
                      leading: const Icon(
                        Icons.folder_open_rounded,
                        color: Color(0xFFFE6420),
                      ),
                      title: Text(
                        catName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1C2452),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFFFE6420),
                            ),
                            onPressed: () => _showEditCategoryDialog(catId, catName),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => Get.dialog(
                              DeleteConfirmationDialog(
                                title: 'Delete Category',
                                message:
                                    'Are you sure you want to delete category "$catName"?',
                                onDelete: () async {
                                  final response = await apiClient.delete(
                                    '/categories/$catId',
                                  );
                                  if (response.status.isOk) {
                                    _fetchCategories();
                                    Get.snackbar(
                                      'Deleted',
                                      'Category deleted successfully.',
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
        onPressed: _showAddCategoryDialog,
        backgroundColor: const Color(0xFFFE6420),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditCategoryDialog(String catId, String currentName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catController = TextEditingController(text: currentName);

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
                    'Edit Category',
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
                controller: catController,
                labelText: 'Category Name',
                prefixIcon: Icons.category_outlined,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final catName = catController.text.trim();
                  if (catName.isEmpty) return;

                  final response = await apiClient.patch('/categories/$catId', {
                    'name': catName,
                  });
                  if (response.status.isOk) {
                    Get.back();
                    _fetchCategories();
                    Get.snackbar(
                      'Success',
                      'Category updated successfully.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF2E7D32),
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
        );
      },
    );
  }
}
