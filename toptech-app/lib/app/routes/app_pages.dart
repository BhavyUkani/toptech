import 'package:get/get.dart';
import '../../features/auth/view/login_view.dart';
import '../../features/auth/binding/auth_binding.dart';
import '../../features/home/view/home_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = Routes.initial;

  static final routes = [
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
    ),
  ];
}
