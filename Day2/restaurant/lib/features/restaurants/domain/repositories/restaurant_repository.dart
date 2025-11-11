import '../entities/restaurant.dart';

abstract class RestaurantRepository {
  Stream<List<Restaurant>> watchRestaurants();
  Future<Restaurant> getById(String id);
}
