import 'package:flutter/foundation.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/usecases/get_restaurants.dart';

class RestaurantProvider with ChangeNotifier {
  final GetRestaurants getRestaurants;

  RestaurantProvider(this.getRestaurants) {
    _subscribe();
  }

  List<Restaurant> _restaurants = [];
  List<Restaurant> get items => _restaurants;

  void _subscribe() {
    getRestaurants().listen((list) {
      _restaurants = list;
      notifyListeners();
    });
  }
}
