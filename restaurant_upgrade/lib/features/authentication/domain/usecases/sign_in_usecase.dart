import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase implements UseCase<User, SignInParams> {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
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

    // Call repository to sign in
    return await repository.signInWithEmailAndPassword(
      email: params.email.trim(),
      password: params.password,
    );
  }
}

class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];

  @override
  String toString() {
    return 'SignInParams(email: $email, password: [HIDDEN])';
  }
}