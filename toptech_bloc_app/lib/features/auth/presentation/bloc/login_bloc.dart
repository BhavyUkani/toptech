import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(const LoginState()) {
    on<PhoneNumberChanged>(_onPhoneNumberChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<ToggleRememberMe>(_onToggleRememberMe);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<AutoLoginSuccess>(_onAutoLoginSuccess);
    on<LogoutRequested>(_onLogoutRequested);
  }

  void _onPhoneNumberChanged(
    PhoneNumberChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      phoneNumber: event.phoneNumber,
      status: LoginStatus.initial,
    ));
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      password: event.password,
      status: LoginStatus.initial,
    ));
  }

  void _onTogglePasswordVisibility(
    TogglePasswordVisibility event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void _onToggleRememberMe(
    ToggleRememberMe event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(isRememberMe: !state.isRememberMe));
  }

  void _onAutoLoginSuccess(
    AutoLoginSuccess event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      status: LoginStatus.success,
      token: event.token,
      userProfile: event.profile,
    ));
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LoginState> emit,
  ) async {
    await _authRepository.logout();
    emit(const LoginState());
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isFormValid) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Please enter both phone number and password',
      ));
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));

    try {
      final response = await _authRepository.login(
        identifier: state.phoneNumber.trim(),
        password: state.password.trim(),
      );

      // Fetch employee profile to check role (Admin vs Employee)
      final profile = await _authRepository.getProfile(response.accessToken);

      emit(state.copyWith(
        status: LoginStatus.success,
        token: response.accessToken,
        userProfile: profile,
      ));
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'An unexpected error occurred: $e',
      ));
    }
  }
}
