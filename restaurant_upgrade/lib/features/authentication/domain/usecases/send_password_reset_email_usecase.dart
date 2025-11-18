import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetEmailUseCase implements UseCase<void, SendPasswordResetEmailParams> {
  final AuthRepository repository;

  SendPasswordResetEmailUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SendPasswordResetEmailParams params) async {
    // Validate email
    final emailValidation = Validators.validateEmail(params.email);
    if (emailValidation != null) {
      return Left(ValidationFailure(
        message: emailValidation,
        code: 'invalid-email',
      ));
    }

    return await repository.sendPasswordResetEmail(
      email: params.email.trim(),
    );
  }
}

class SendPasswordResetEmailParams extends Equatable {
  final String email;

  const SendPasswordResetEmailParams({
    required this.email,
  });

  @override
  List<Object> get props => [email];

  @override
  String toString() {
    return 'SendPasswordResetEmailParams(email: $email)';
  }
}