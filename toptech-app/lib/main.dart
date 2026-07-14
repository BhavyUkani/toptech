import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'app/routes/app_routes.dart';
import 'app/routes/app_pages.dart';
import 'app/bindings/initial_binding.dart';
import 'app/theme/app_theme.dart';
import 'core/services/storage_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/auth_service.dart';
import 'core/api/api_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(ApiConstants.oneSignalAppId);

  // Initialize critical services synchronously before app launch
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => ConnectivityService().init());
  await Get.putAsync(() => AuthService().init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return GetMaterialApp(
      title: 'TopTech App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode
          .system, // Automatically use dark/light based on system settings
      initialRoute: authService.isLoggedIn.value ? Routes.home : Routes.login,
      initialBinding: InitialBinding(),
      getPages: AppPages.routes,
    );
  }
}
