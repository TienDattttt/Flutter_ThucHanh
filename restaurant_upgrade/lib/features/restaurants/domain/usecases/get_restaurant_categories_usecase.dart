import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/restaurant_repository.dart';

class GetRestaurantCategoriesUseCase implements UseCase<List<String>, NoParams> {
  final RestaurantRepository repository;

  GetRestaurantCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getRestaurantCategories();
  }
}