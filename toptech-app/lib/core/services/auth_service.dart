import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../../features/auth/model/employee.dart';
import '../../app/routes/app_routes.dart';
import '../api/api_client.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  final StorageService _storageService = Get.find<StorageService>();

  final RxBool isLoggedIn = false.obs;
  final Rxn<Employee> employee = Rxn<Employee>();

  Future<AuthService> init() async {
    final token = _storageService.getToken();
    final empJson = _storageService.getEmployee();

    if (token != null) {
      isLoggedIn.value = true;
      if (empJson != null) {
        try {
          employee.value = Employee.fromJson(
            jsonDecode(empJson) as Map<String, dynamic>,
          );
        } catch (e) {
          debugPrint('Error parsing stored employee: $e');
        }
      }
      // Request permission on auto-login boot too, so the device registers with OneSignal
      OneSignal.Notifications.requestPermission(true);
    }

    // Reactively update OneSignal External User ID based on login state
    ever(employee, (emp) {
      if (emp != null) {
        OneSignal.login(emp.id.toString());
        // Retry upload with delay to give OneSignal time to finish registering
        _retryUploadOneSignalId();
      } else {
        OneSignal.logout();
      }
    });

    // Also upload whenever push subscription state changes (e.g., ID becomes available)
    OneSignal.User.pushSubscription.addObserver((state) {
      uploadOneSignalId();
    });

    return this;
  }

  void saveLoginSession(String token, Employee emp) {
    _storageService.saveToken(token);
    _storageService.saveEmployee(jsonEncode(emp.toJson()));
    employee.value = emp;
    isLoggedIn.value = true;
    OneSignal.Notifications.requestPermission(true);
    _retryUploadOneSignalId();
  }

  /// Retries uploadOneSignalId with exponential back-off to handle the case
  /// where OneSignal has not finished registering the device yet.
  void _retryUploadOneSignalId() {
    // Try immediately
    uploadOneSignalId();
    // Then retry after 3s, 8s, 15s in case OneSignal registration was delayed
    for (final delay in [3, 8, 15]) {
      Future.delayed(Duration(seconds: delay), uploadOneSignalId);
    }
  }

  Future<void> uploadOneSignalId() async {
    final subId = OneSignal.User.pushSubscription.id;
    if (subId == null || !isLoggedIn.value) {
      debugPrint('OneSignal: subscription ID not ready yet (subId=$subId, loggedIn=${isLoggedIn.value})');
      return;
    }
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.post('/auth/profile/onesignal', {
        'onesignalPlayerId': subId,
      });
      if (response.status.isOk) {
        debugPrint('✅ OneSignal Player ID saved to DB: $subId');
      } else {
        debugPrint('❌ Failed to save OneSignal ID. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error saving OneSignal Player ID: $e');
    }
  }

  Future<void> logout() async {
    await _storageService.clear();
    employee.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed(Routes.login);
  }
}
