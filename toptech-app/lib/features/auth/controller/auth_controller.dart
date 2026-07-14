import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../model/employee.dart';
import '../repository/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storageService = Get.find<StorageService>();

  final identifierController = TextEditingController();
  final passwordController = TextEditingController();
  
  final isLoading = false.obs;
  final obscurePassword = true.obs;

  @override
  void onClose() {
    identifierController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    final identifier = identifierController.text.trim();
    final password = passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter your username, email, or number and password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await _authRepository.login(identifier, password);

      if (response.status.isOk && response.body != null) {
        final token = response.body['access_token'] as String;

        // Save token to storage first so ApiClient can use it for profile call (awaiting async save)
        await _storageService.saveToken(token);

        // Fetch employee details
        final profileResponse = await _authRepository.getProfile();

        if (profileResponse.status.isOk && profileResponse.body != null) {
          final emp = Employee.fromJson(profileResponse.body as Map<String, dynamic>);
          
          // Complete login session
          _authService.saveLoginSession(token, emp);

          Get.snackbar(
            'Success',
            'Welcome back, ${emp.name}!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF2CB67D),
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
          );

          // Clear text controllers
          identifierController.clear();
          passwordController.clear();

          // Navigate to home dashboard
          Get.offAllNamed(Routes.home);
        } else {
          await _storageService.clear();
          throw Exception('Failed to fetch user profile.');
        }
      } else {
        // Handle auth errors (e.g. invalid credentials)
        final errMsg = response.body != null && response.body['message'] != null
            ? response.body['message'].toString()
            : 'Authentication failed. Please check your credentials.';
        
        Get.snackbar(
          'Login Failed',
          errMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Connection Error',
        'Could not connect to the authentication server',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
