import 'package:equatable/equatable.dart';
import '../../domain/entities/restaurant.dart';

abstract class RestaurantState extends Equatable {
  const RestaurantState();

  @override
  List<Object?> get props => [];
}

class RestaurantInitial extends RestaurantState {
  const RestaurantInitial();
}

class RestaurantLoading extends RestaurantState {
  const RestaurantLoading();
}

class RestaurantLoaded extends RestaurantState {
  final List<Restaurant> restaurants;
  final String? currentCategory;
  final double? currentMinRating;
  final String? currentSearchQuery;

  const RestaurantLoaded({
    required this.restaurants,
    this.currentCategory,
    this.currentMinRating,
    this.currentSearchQuery,
  });

  @override
  List<Object?> get props => [
    restaurants,
    currentCategory,
    currentMinRating,
    currentSearchQuery,
  ];
}

class RestaurantDetailLoaded extends RestaurantState {
  final Restaurant restaurant;

  const RestaurantDetailLoaded({
    required this.restaurant,
  });

  @override
  List<Object> get props => [restaurant];
}

class RestaurantCategoriesLoaded extends RestaurantState {
  final List<String> categories;

  const RestaurantCategoriesLoaded({
    required this.categories,
  });

  @override
  List<Object> get props => [categories];
}

class RestaurantError extends RestaurantState {
  final String message;
  final String code;

  const RestaurantError({
    required this.message,
    required this.code,
  });

  @override
  List<Object> get props => [message, code];
}

class RestaurantEmpty extends RestaurantState {
  final String message;

  const RestaurantEmpty({
    this.message = 'Không tìm thấy nhà hàng nào',
  });

  @override
  List<Object> get props => [message];
}

class RestaurantAddSuccess extends RestaurantState {
  final Restaurant restaurant;
  final String message;

  const RestaurantAddSuccess({
    required this.restaurant,
    this.message = 'Thêm nhà hàng thành công!',
  });

  @override
  List<Object> get props => [restaurant, message];
}

class RestaurantSearchLoading extends RestaurantState {
  final String query;

  const RestaurantSearchLoading({
    required this.query,
  });

  @override
  List<Object> get props => [query];
}

class RestaurantSearchLoaded extends RestaurantState {
  final List<Restaurant> restaurants;
  final String query;

  const RestaurantSearchLoaded({
    required this.restaurants,
    required this.query,
  });

  @override
  List<Object> get props => [restaurants, query];
}

class RestaurantLocationLoading extends RestaurantState {
  final double latitude;
  final double longitude;
  final double radiusInKm;

  const RestaurantLocationLoading({
    required this.latitude,
    required this.longitude,
    required this.radiusInKm,
  });

  @override
  List<Object> get props => [latitude, longitude, radiusInKm];
}

class RestaurantLocationLoaded extends RestaurantState {
  final List<Restaurant> restaurants;
  final double latitude;
  final double longitude;
  final double radiusInKm;

  const RestaurantLocationLoaded({
    required this.restaurants,
    required this.latitude,
    required this.longitude,
    required this.radiusInKm,
  });

  @override
  List<Object> get props => [restaurants, latitude, longitude, radiusInKm];
}