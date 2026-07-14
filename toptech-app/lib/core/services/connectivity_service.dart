import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final RxBool isConnected = true.obs;

  Future<ConnectivityService> init() async {
    // In production, integrate connectivity_plus package here to listen to network status
    return this;
  }
}
