import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  final String? confirmPassword;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.displayName,
    this.confirmPassword,
  });

  @override
  List<Object?> get props => [email, password, displayName, confirmPassword];
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({
    required this.email,
  });

  @override
  List<Object> get props => [email];
}

class AuthProfileUpdateRequested extends AuthEvent {
  final String userId;
  final String? displayName;
  final String? photoUrl;

  const AuthProfileUpdateRequested({
    required this.userId,
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [userId, displayName, photoUrl];
}

class AuthDeleteAccountRequested extends AuthEvent {
  const AuthDeleteAccountRequested();
}

class AuthStateChanged extends AuthEvent {
  final dynamic user; // Can be User or null

  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}