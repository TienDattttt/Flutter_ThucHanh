import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase implements UseCase<User, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    // Validate input parameters
    final emailValidation = Validators.validateEmail(params.email);
    if (emailValidation != null) {
      return Left(ValidationFailure(
        message: emailValidation,
        code: 'invalid-email',
      ));
    }

    final passwordValidation = Validators.validatePassword(params.password);
    if (passwordValidation != null) {
      return Left(ValidationFailure(
        message: passwordValidation,
        code: 'invalid-password',
      ));
    }

    final displayNameValidation = Validators.validateDisplayName(params.displayName);
    if (displayNameValidation != null) {
      return Left(ValidationFailure(
        message: displayNameValidation,
        code: 'invalid-display-name',
      ));
    }

    // Validate confirm password if provided
    if (params.confirmPassword != null) {
      final confirmPasswordValidation = Validators.validateConfirmPassword(
        params.password,
        params.confirmPassword,
      );
      if (confirmPasswordValidation != null) {
        return Left(ValidationFailure(
          message: confirmPasswordValidation,
          code: 'password-mismatch',
        ));
      }
    }

    // Call repository to sign up
    return await repository.signUpWithEmailAndPassword(
      email: params.email.trim(),
      password: params.password,
      displayName: params.displayName.trim(),
    );
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String displayName;
  final String? confirmPassword;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.displayName,
    this.confirmPassword,
  });

  @override
  List<Object?> get props => [email, password, displayName, confirmPassword];

  @override
  String toString() {
    return 'SignUpParams(email: $email, password: [HIDDEN], displayName: $displayName, confirmPassword: [HIDDEN])';
  }
}