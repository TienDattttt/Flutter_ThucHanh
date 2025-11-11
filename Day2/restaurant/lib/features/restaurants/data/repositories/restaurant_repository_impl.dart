import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_remote_ds.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remote;

  RestaurantRepositoryImpl(this.remote);

  @override
  Stream<List<Restaurant>> watchRestaurants() {
    return remote
        .watchRestaurants()
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Restaurant> getById(String id) async {
    final model = await remote.getById(id);
    return model.toEntity();
  }
}
