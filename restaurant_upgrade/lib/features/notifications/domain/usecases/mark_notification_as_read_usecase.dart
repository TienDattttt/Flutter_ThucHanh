import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/string_utils.dart';
import '../repositories/notification_repository.dart';

class MarkNotificationAsReadUseCase implements UseCase<void, MarkNotificationAsReadParams> {
  final NotificationRepository repository;

  MarkNotificationAsReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkNotificationAsReadParams params) async {
    // Validate notification ID
    if (StringUtils.isNullOrEmpty(params.notificationId)) {
      return const Left(ValidationFailure(
        message: 'ID thông báo không được để trống',
        code: 'invalid-notification-id',
      ));
    }

    return await repository.markNotificationAsRead(params.notificationId);
  }
}

class MarkNotificationAsReadParams extends Equatable {
  final String notificationId;

  const MarkNotificationAsReadParams({
    required this.notificationId,
  });

  @override
  List<Object> get props => [notificationId];

  @override
  String toString() {
    return 'MarkNotificationAsReadParams(notificationId: $notificationId)';
  }
}