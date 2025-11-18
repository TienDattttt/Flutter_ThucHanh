import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/string_utils.dart';
import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

class GetRestaurantByIdUseCase implements UseCase<Restaurant, GetRestaurantByIdParams> {
  final RestaurantRepository repository;

  GetRestaurantByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Restaurant>> call(GetRestaurantByIdParams params) async {
    // Validate restaurant ID
    if (StringUtils.isNullOrEmpty(params.restaurantId)) {
      return const Left(ValidationFailure(
        message: 'ID nhà hàng không được để trống',
        code: 'invalid-restaurant-id',
      ));
    }

    return await repository.getRestaurantById(params.restaurantId);
  }
}

class GetRestaurantByIdParams extends Equatable {
  final String restaurantId;

  const GetRestaurantByIdParams({
    required this.restaurantId,
  });

  @override
  List<Object> get props => [restaurantId];

  @override
  String toString() {
    return 'GetRestaurantByIdParams(restaurantId: $restaurantId)';
  }
}