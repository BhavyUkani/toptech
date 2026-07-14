import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';

class AuthRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<Response> login(String identifier, String password) {
    return _apiClient.post(
      ApiConstants.login,
      {
        'identifier': identifier,
        'password': password,
      },
    );
  }

  Future<Response> getProfile() {
    return _apiClient.get(ApiConstants.profile);
  }
}
