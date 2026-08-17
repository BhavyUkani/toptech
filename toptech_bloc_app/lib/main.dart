import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/snackbar_utils.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/login_bloc.dart';
import 'features/enquiries/data/enquiries_repository.dart';
import 'features/enquiries/presentation/bloc/enquiry_bloc.dart';
import 'features/splash/presentation/bloc/splash_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();
  runApp(TopTechApp(storageService: storageService));
}

class TopTechApp extends StatelessWidget {
  final StorageService storageService;

  const TopTechApp({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository(storage: storageService);
    final enquiriesRepository = EnquiriesRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<StorageService>.value(value: storageService),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<EnquiriesRepository>.value(value: enquiriesRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SplashBloc>(
            create: (context) => SplashBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<EnquiryBloc>(
            create: (context) => EnquiryBloc(
              repository: context.read<EnquiriesRepository>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'TopTech App',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: AppSnackBar.messengerKey,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
