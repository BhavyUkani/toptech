import 'package:equatable/equatable.dart';
import '../../data/models/employee_profile.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final String phoneNumber;
  final String password;
  final bool isPasswordVisible;
  final bool isRememberMe;
  final LoginStatus status;
  final String? token;
  final EmployeeProfile? userProfile;
  final String? errorMessage;

  const LoginState({
    this.phoneNumber = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.isRememberMe = false,
    this.status = LoginStatus.initial,
    this.token,
    this.userProfile,
    this.errorMessage,
  });

  bool get isFormValid =>
      phoneNumber.trim().isNotEmpty && password.trim().isNotEmpty;

  LoginState copyWith({
    String? phoneNumber,
    String? password,
    bool? isPasswordVisible,
    bool? isRememberMe,
    LoginStatus? status,
    String? token,
    EmployeeProfile? userProfile,
    String? errorMessage,
  }) {
    return LoginState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isRememberMe: isRememberMe ?? this.isRememberMe,
      status: status ?? this.status,
      token: token ?? this.token,
      userProfile: userProfile ?? this.userProfile,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        phoneNumber,
        password,
        isPasswordVisible,
        isRememberMe,
        status,
        token,
        userProfile,
        errorMessage,
      ];
}
