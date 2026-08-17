import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/enquiries/presentation/screens/add_edit_enquiry_screen.dart';
import '../../features/enquiries/data/models/enquiry_model.dart';

class AppRouter {
  AppRouter._();

  static const String splashPath = '/';
  static const String loginPath = '/login';
  static const String homePath = '/home';
  static const String addEditEnquiryPath = '/add-edit-enquiry';

  static final GoRouter router = GoRouter(
    initialLocation: splashPath,
    routes: [
      GoRoute(
        path: splashPath,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: homePath,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: addEditEnquiryPath,
        builder: (context, state) {
          final enquiry = state.extra as EnquiryModel?;
          return AddEditEnquiryScreen(enquiry: enquiry);
        },
      ),
    ],
  );
}
