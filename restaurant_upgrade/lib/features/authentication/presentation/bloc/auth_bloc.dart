import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/send_password_reset_email_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/usecases/usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final AuthRepository authRepository;

  StreamSubscription<User?>? _authStateSubscription;

  AuthBloc({
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
    required this.sendPasswordResetEmailUseCase,
    required this.updateUserProfileUseCase,
    required this.deleteAccountUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
    on<AuthProfileUpdateRequested>(_onAuthProfileUpdateRequested);
    on<AuthDeleteAccountRequested>(_onAuthDeleteAccountRequested);
    on<AuthStateChanged>(_onAuthStateChanged);

    // Listen to auth state changes
    _authStateSubscription = authRepository.authStateChanges.listen(
      (user) => add(AuthStateChanged(user)),
    );
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await getCurrentUserUseCase(const NoParams());

    result.fold(
      (failure) => emit(AuthError(
        message: failure.message,
        code: failure.code,
      )),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signUpUseCase(SignUpParams(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
      confirmPassword: event.confirmPassword,
    ));

    result.fold(
      (failure) => emit(AuthError(
        message: failure.message,
        code: failure.code,
      )),
      (user) => emit(AuthSignUpSuccess(user: user)),
    );
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signInUseCase(SignInParams(
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) => emit(AuthError(
        message: failure.message,
        code: failure.code,
      )),
      (user) => emit(AuthSignInSuccess(user: user)),
    );
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signOutUseCase(const NoParams());

    result.fold(
      (failure) => emit(AuthError(
        message: failure.message,
        code: failure.code,
      )),
      (_) => emit(const AuthSignOutSuccess()),
    );
  }

  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await sendPasswordResetEmailUseCase(
      SendPasswordResetEmailParams(email: event.email),
    );

    result.fold(
      (failure) => emit(AuthError(
        message: failure.message,
        code: failure.code,
      )),
      (_) => emit(const AuthPasswordResetSuccess()),
    );
  }

  Future<void> _onAuthProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await updateUserProfileUseCase(UpdateUserProfileParams(
      userId: event.userId,
      displayName: event.displayName,
      photoUrl: event.photoUrl,
    ));

    result.fold(
      (failure) => emit(AuthError(
        message: failure.message,
        code: failure.code,
      )),
      (user) => emit(AuthProfileUpdateSuccess(user: user)),
    );
  }

  Future<void> _onAuthDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await deleteAccountUseCase(const NoParams());

    result.fold(
      (failure) => emit(AuthError(
        message: failure.message,
        code: failure.code,
      )),
      (_) => emit(const AuthDeleteAccountSuccess()),
    );
  }

  void _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) {
    final user = event.user as User?;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}