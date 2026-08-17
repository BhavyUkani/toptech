import 'package:equatable/equatable.dart';
import '../../../auth/data/models/employee_profile.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashAuthenticated extends SplashState {
  final String token;
  final EmployeeProfile profile;

  const SplashAuthenticated({
    required this.token,
    required this.profile,
  });

  @override
  List<Object?> get props => [token, profile];
}

class SplashUnauthenticated extends SplashState {}
