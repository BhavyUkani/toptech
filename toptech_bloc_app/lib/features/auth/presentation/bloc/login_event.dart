import 'package:equatable/equatable.dart';
import '../../data/models/employee_profile.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class PhoneNumberChanged extends LoginEvent {
  final String phoneNumber;
  const PhoneNumberChanged(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class PasswordChanged extends LoginEvent {
  final String password;
  const PasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class TogglePasswordVisibility extends LoginEvent {}

class ToggleRememberMe extends LoginEvent {}

class LoginSubmitted extends LoginEvent {}

class AutoLoginSuccess extends LoginEvent {
  final String token;
  final EmployeeProfile profile;

  const AutoLoginSuccess({
    required this.token,
    required this.profile,
  });

  @override
  List<Object?> get props => [token, profile];
}

class LogoutRequested extends LoginEvent {}
