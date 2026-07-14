import 'package:get/get.dart';
import '../services/storage_service.dart';
import 'api_constants.dart';

class ApiClient extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = ApiConstants.baseUrl;
    
    // Add request interceptor to attach JWT token
    httpClient.addRequestModifier<dynamic>((request) async {
      final storageService = Get.find<StorageService>();
      final token = storageService.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      return request;
    });

    super.onInit();
  }
}
