import 'package:get/get.dart';
import '../../core/api/api_client.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // Lazily put ApiClient so it can be resolved anywhere in the app
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
  }
}
