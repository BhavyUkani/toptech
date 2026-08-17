import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api/api_constants.dart';
import '../../../core/services/storage_service.dart';
import 'models/auth_response.dart';
import 'models/employee_profile.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  final http.Client _client;
  final StorageService? _storageService;

  AuthRepository({http.Client? client, StorageService? storage})
      : _client = client ?? http.Client(),
        _storageService = storage;

  /// Retrieves saved token from SharedPreferences
  String? getSavedToken() {
    return _storageService?.getToken();
  }

  /// Executes login API request to toptech-api POST /auth/login
  Future<AuthResponse> login({
    required String identifier,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'number': identifier,
          'password': password,
        }),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>?;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (body != null && body.containsKey('access_token')) {
          final authRes = AuthResponse.fromJson(body);
          // Persist token locally
          await _storageService?.saveToken(authRes.accessToken);
          return authRes;
        }
        throw const AuthException('Invalid response format from server');
      } else if (response.statusCode == 401) {
        final msg = body?['message'] as String? ?? 'Invalid credentials';
        throw AuthException(msg);
      } else {
        final msg = body?['message'] as String? ?? 'Authentication failed (Status ${response.statusCode})';
        throw AuthException(msg);
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Network error: Unable to connect to server ($e)');
    }
  }

  /// Fetches current employee profile GET /auth/profile
  Future<EmployeeProfile> getProfile(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}');

    try {
      final response = await _client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>?;

      if (response.statusCode == 200 && body != null) {
        return EmployeeProfile.fromJson(body);
      } else {
        throw const AuthException('Failed to fetch user profile');
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Network error while fetching profile: $e');
    }
  }

  /// Clears stored login token
  Future<void> logout() async {
    await _storageService?.clearToken();
  }
}
