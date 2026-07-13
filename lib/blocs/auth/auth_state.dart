import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticatedStudent extends AuthState {
  final StudentProfile student;

  const AuthAuthenticatedStudent(this.student);

  @override
  List<Object> get props => [student];
}

class AuthAuthenticatedStartup extends AuthState {
  final StartupProfile startup;

  const AuthAuthenticatedStartup(this.startup);

  @override
  List<Object> get props => [startup];
}

class AuthUnverifiedStartup extends AuthState {
  final StartupProfile startup;

  const AuthUnverifiedStartup(this.startup);

  @override
  List<Object> get props => [startup];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String errorMessage;

  const AuthFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
