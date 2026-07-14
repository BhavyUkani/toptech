import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/delete_confirmation_dialog.dart';

class PriceListScreen extends StatefulWidget {
  const PriceListScreen({super.key});

  @override
  State<PriceListScreen> createState() => _PriceListScreenState();
}

class _PriceListScreenState extends State<PriceListScreen> {
  final authService = Get.find<AuthService>();
  final apiClient = Get.find<ApiClient>();

  // Loaded database products
  final List<Map<String, String>> _products = [];

  // Loaded database categories names for drop downs
  final List<String> _categories = [];

  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch products & categories dynamically from backend API
  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      // 1. Fetch categories
      final catRes = await apiClient.get('/categories');
      if (catRes.status.isOk && catRes.body != null) {
        final List<dynamic> list = catRes.body;
        setState(() {
          _categories.clear();
          for (final item in list) {
            _categories.add(item['name'] as String);
          }
        });
      }

      // 2. Fetch products
      final prodRes = await apiClient.get('/products');
      if (prodRes.status.isOk && prodRes.body != null) {
        final List<dynamic> list = prodRes.body;
        setState(() {
          _products.clear();
          for (final p in list) {
            _products.add({
              'id': p['id'].toString(),
              'name': p['name'].toString(),
              'code': p['code'].toString(),
              'lsp': p['lsp'].toString(),
              'hsp': p['hsp'].toString(),
              'category': p['category'].toString(),
            });
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading Price List data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Open real camera scanner view using mobile_scanner package inside a popup dialog
  void _openBarcodeScanner() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF13192F) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Scan Barcode',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () => Get.back(),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        content: SizedBox(
          width: 300,
          height: 250,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Real device/emulator camera viewport
                MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final String? code = barcodes.first.rawValue;
                      if (code != null) {
                        Get.back();
                        _handleScanResult(code);
                      }
                    }
                  },
                ),
                // Target scanning framing overlay box
                Container(
                  width: 220,
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFE6420), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(child: LaserScanLine()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Handle scanned barcode result and output dialog popup info
  void _handleScanResult(String code) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Find the product
    final product = _products.firstWhere(
      (p) => (p['code'] ?? '').toLowerCase() == code.toLowerCase(),
      orElse: () => {},
    );

    if (product.isEmpty) {
      Get.snackbar(
        'Product Not Found',
        'No product matches code: $code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // Set filter query
    setState(() {
      _searchQuery = code;
      _searchController.text = code;
    });

    // Show Details dialog!
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF13192F) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.inventory_2_rounded, color: Color(0xFFFE6420)),
            const SizedBox(width: 8),
            Text(
              'Product Details'.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product['name'] ?? 'N/A',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1C2452),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x1F2E7D32),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    (product['category'] ?? 'N/A').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x1AFFFFFF)
                        : const Color(0x0D000000),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'CODE: ${product['code'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0C1020)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0x1AFFFFFF)
                      : const Color(0x0D000000),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LSP (Lowest)',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product['lsp'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: isDark
                        ? const Color(0x1AFFFFFF)
                        : const Color(0x1F000000),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HSP (Highest)',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product['hsp'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFE6420),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Close',
              style: TextStyle(
                color: Color(0xFFFE6420),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom sheet to add new product
  void _showAddProductBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final lspController = TextEditingController();
    final hspController = TextEditingController();
    String? selectedCat = _categories.isNotEmpty ? _categories.first : null;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13192F) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add New Product',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1C2452),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: nameController,
                    labelText: 'Product Name',
                    prefixIcon: Icons.inventory_2_outlined,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: codeController,
                    labelText: 'Product Code (e.g. WAD-03)',
                    prefixIcon: Icons.qr_code_rounded,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: lspController,
                          labelText: 'LSP (e.g. ₹40,000)',
                          prefixIcon: Icons.trending_down_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: hspController,
                          labelText: 'HSP (e.g. ₹60,000)',
                          prefixIcon: Icons.trending_up_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Dropdown selection of Category
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0C1020)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? const Color(0x33FFFFFF)
                            : const Color(0x26000000),
                        width: 1.2,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCat,
                        dropdownColor: isDark
                            ? const Color(0xFF13192F)
                            : Colors.white,
                        items: _categories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setSheetState(() {
                              selectedCat = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final code = codeController.text.trim();
                      final lsp = lspController.text.trim();
                      final hsp = hspController.text.trim();

                      if (name.isEmpty ||
                          code.isEmpty ||
                          lsp.isEmpty ||
                          hsp.isEmpty ||
                          selectedCat == null) {
                        Get.snackbar(
                          'Missing Fields',
                          'Please populate all values.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      final response = await apiClient.post('/products', {
                        'name': name,
                        'code': code.toUpperCase(),
                        'lsp': lsp,
                        'hsp': hsp,
                        'category': selectedCat!,
                      });

                      if (response.status.isOk) {
                        Get.back();
                        _fetchData();
                        Get.snackbar(
                          'Success',
                          'Product created successfully.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF2E7D32),
                          colorText: Colors.white,
                        );
                      } else {
                        Get.snackbar(
                          'Error',
                          'Could not create product. Code might be duplicated.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C2452),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Add Product',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Bottom sheet to edit existing product
  void _showEditProductBottomSheet(Map<String, String> product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController(text: product['name']);
    final codeController = TextEditingController(text: product['code']);
    final lspController = TextEditingController(text: product['lsp']);
    final hspController = TextEditingController(text: product['hsp']);
    String? selectedCat = _categories.contains(product['category'])
        ? product['category']
        : (_categories.isNotEmpty ? _categories.first : null);

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13192F) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Edit Product',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1C2452),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: nameController,
                    labelText: 'Product Name',
                    prefixIcon: Icons.inventory_2_outlined,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: codeController,
                    labelText: 'Product Code (e.g. WAD-03)',
                    prefixIcon: Icons.qr_code_rounded,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: lspController,
                          labelText: 'LSP (e.g. ₹40,000)',
                          prefixIcon: Icons.trending_down_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: hspController,
                          labelText: 'HSP (e.g. ₹60,000)',
                          prefixIcon: Icons.trending_up_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Dropdown selection of Category
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0C1020)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? const Color(0x33FFFFFF)
                            : const Color(0x26000000),
                        width: 1.2,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCat,
                        dropdownColor: isDark
                            ? const Color(0xFF13192F)
                            : Colors.white,
                        items: _categories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setSheetState(() {
                              selectedCat = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final code = codeController.text.trim();
                      final lsp = lspController.text.trim();
                      final hsp = hspController.text.trim();

                      if (name.isEmpty ||
                          code.isEmpty ||
                          lsp.isEmpty ||
                          hsp.isEmpty ||
                          selectedCat == null) {
                        Get.snackbar(
                          'Missing Fields',
                          'Please populate all values.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      final response = await apiClient
                          .patch('/products/${product['id']}', {
                            'name': name,
                            'code': code.toUpperCase(),
                            'lsp': lsp,
                            'hsp': hsp,
                            'category': selectedCat!,
                          });

                      if (response.status.isOk) {
                        Get.back();
                        _fetchData();
                        Get.snackbar(
                          'Success',
                          'Product updated successfully.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF2E7D32),
                          colorText: Colors.white,
                        );
                      } else {
                        Get.snackbar(
                          'Error',
                          'Could not update product. Code might be duplicated.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C2452),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Update Product',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Delete product API request
  Future<void> _deleteProduct(String id) async {
    Get.dialog(
      DeleteConfirmationDialog(
        title: 'Delete Product',
        message: 'Are you sure you want to delete this product? This action cannot be undone.',
        onDelete: () async {
          final response = await apiClient.delete('/products/$id');
          if (response.status.isOk) {
            _fetchData();
            Get.snackbar(
              'Deleted',
              'Product deleted successfully.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF2E7D32),
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAdmin = authService.employee.value?.role == 'Admin';

    final filteredProducts = _products.where((product) {
      final nameMatches = (product['name'] ?? '').toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final codeMatches = (product['code'] ?? '').toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final categoryMatches =
          _selectedCategory == 'All' ||
          product['category'] == _selectedCategory;
      return (nameMatches || codeMatches) && categoryMatches;
    }).toList();

    // Prepare complete categories list dynamically including 'All'
    final List<String> activeCategories = ['All', ..._categories];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Search Bar + Barcode Scanner Trigger
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF13192F) : Colors.white,
                hintText: 'Search products by name or code...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark ? Colors.white54 : Colors.black54,
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Color(0xFFFE6420),
                    size: 22,
                  ),
                  tooltip: 'Scan Barcode',
                  onPressed: _openBarcodeScanner,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
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
                  borderSide: const BorderSide(
                    color: Color(0xFFFE6420),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Category horizontal chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: activeCategories.length,
              itemBuilder: (context, index) {
                final cat = activeCategories[index];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(
                      cat,
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
                          _selectedCategory = cat;
                        });
                      }
                    },
                    selectedColor: const Color(0xFFFE6420),
                    backgroundColor: isDark
                        ? const Color(0xFF13192F)
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFFFE6420)
                            : (isDark
                                  ? const Color(0x1EFFFFFF)
                                  : const Color(0x1F000000)),
                      ),
                    ),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Products List View
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFFFE6420),
              onRefresh: _fetchData,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFE6420),
                      ),
                    )
                  : filteredProducts.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.45,
                          child: Center(
                            child: Text(
                              'No products found matching filters.',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];

                        return Card(
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
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            product['name'] ?? 'N/A',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF1C2452),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0x1FFE6420)
                                                : const Color(0x1F2E7D32),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            (product['category'] ?? 'N/A')
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? const Color(0xFFFF9E73)
                                                  : const Color(0xFF2E7D32),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.qr_code_rounded,
                                          size: 14,
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black54,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Code: ${product['code'] ?? 'N/A'}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.white54
                                                : Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF0C1020)
                                            : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isDark
                                              ? const Color(0x1AFFFFFF)
                                              : const Color(0x0D000000),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'LSP (Lowest Selling)',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: isDark
                                                        ? Colors.white38
                                                        : Colors.black38,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  product['lsp'] ?? 'N/A',
                                                  style: TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark
                                                        ? const Color(0xFF81C784)
                                                        : const Color(0xFF2E7D32),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 1,
                                            height: 28,
                                            color: isDark
                                                ? const Color(0x1AFFFFFF)
                                                : const Color(0x1F000000),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'HSP (Highest Selling)',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: isDark
                                                        ? Colors.white38
                                                        : Colors.black38,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  product['hsp'] ?? 'N/A',
                                                  style: const TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFFE6420),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isAdmin) ...[
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
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () =>
                                            _showEditProductBottomSheet(
                                          product,
                                        ),
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 16,
                                          color: Colors.blueAccent,
                                        ),
                                        label: const Text(
                                          'Edit',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blueAccent,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize
                                              .shrinkWrap,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      TextButton.icon(
                                        onPressed: () =>
                                            _deleteProduct(product['id']!),
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 16,
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
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize
                                              .shrinkWrap,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _showAddProductBottomSheet,
              backgroundColor: const Color(0xFFFE6420),
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

// Stateful laser line repeating animation for simulated camera scanning view
class LaserScanLine extends StatefulWidget {
  const LaserScanLine({super.key});

  @override
  State<LaserScanLine> createState() => _LaserScanLineState();
}

class _LaserScanLineState extends State<LaserScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -40.0, end: 40.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: 180,
            height: 2.5,
            decoration: const BoxDecoration(
              color: Color(0xFF00FF00),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF00FF00),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
