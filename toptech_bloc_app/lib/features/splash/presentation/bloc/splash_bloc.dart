import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/auth_repository.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthRepository _authRepository;

  SplashBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashLoading());

    // Minimum splash animation delay
    await Future.delayed(const Duration(milliseconds: 1200));

    final token = _authRepository.getSavedToken();

    if (token == null || token.isEmpty) {
      emit(SplashUnauthenticated());
      return;
    }

    try {
      // Verify stored JWT token against GET /auth/profile
      final profile = await _authRepository.getProfile(token);
      emit(SplashAuthenticated(token: token, profile: profile));
    } catch (_) {
      // Token is invalid/expired -> clear storage and direct to login
      await _authRepository.logout();
      emit(SplashUnauthenticated());
    }
  }
}
