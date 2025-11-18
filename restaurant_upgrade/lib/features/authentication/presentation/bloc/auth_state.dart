import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final String code;

  const AuthError({
    required this.message,
    required this.code,
  });

  @override
  List<Object> get props => [message, code];
}

class AuthSignUpSuccess extends AuthState {
  final User user;
  final String message;

  const AuthSignUpSuccess({
    required this.user,
    this.message = 'Đăng ký thành công! Vui lòng kiểm tra email để xác thực tài khoản.',
  });

  @override
  List<Object> get props => [user, message];
}

class AuthSignInSuccess extends AuthState {
  final User user;
  final String message;

  const AuthSignInSuccess({
    required this.user,
    this.message = 'Đăng nhập thành công!',
  });

  @override
  List<Object> get props => [user, message];
}

class AuthSignOutSuccess extends AuthState {
  final String message;

  const AuthSignOutSuccess({
    this.message = 'Đăng xuất thành công!',
  });

  @override
  List<Object> get props => [message];
}

class AuthPasswordResetSuccess extends AuthState {
  final String message;

  const AuthPasswordResetSuccess({
    this.message = 'Email đặt lại mật khẩu đã được gửi!',
  });

  @override
  List<Object> get props => [message];
}

class AuthProfileUpdateSuccess extends AuthState {
  final User user;
  final String message;

  const AuthProfileUpdateSuccess({
    required this.user,
    this.message = 'Cập nhật hồ sơ thành công!',
  });

  @override
  List<Object> get props => [user, message];
}

class AuthDeleteAccountSuccess extends AuthState {
  final String message;

  const AuthDeleteAccountSuccess({
    this.message = 'Tài khoản đã được xóa thành công!',
  });

  @override
  List<Object> get props => [message];
}