import 'package:equatable/equatable.dart';

abstract class RestaurantEvent extends Equatable {
  const RestaurantEvent();

  @override
  List<Object?> get props => [];
}

class RestaurantLoadRequested extends RestaurantEvent {
  final String? category;
  final double? minRating;
  final String? searchQuery;
  final int? limit;

  const RestaurantLoadRequested({
    this.category,
    this.minRating,
    this.searchQuery,
    this.limit,
  });

  @override
  List<Object?> get props => [category, minRating, searchQuery, limit];
}

class RestaurantByIdLoadRequested extends RestaurantEvent {
  final String restaurantId;

  const RestaurantByIdLoadRequested({
    required this.restaurantId,
  });

  @override
  List<Object> get props => [restaurantId];
}

class RestaurantNearLocationLoadRequested extends RestaurantEvent {
  final double latitude;
  final double longitude;
  final double radiusInKm;
  final String? category;
  final double? minRating;
  final int? limit;

  const RestaurantNearLocationLoadRequested({
    required this.latitude,
    required this.longitude,
    required this.radiusInKm,
    this.category,
    this.minRating,
    this.limit,
  });

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    radiusInKm,
    category,
    minRating,
    limit,
  ];
}

class RestaurantSearchRequested extends RestaurantEvent {
  final String query;
  final String? category;
  final double? minRating;
  final int? limit;

  const RestaurantSearchRequested({
    required this.query,
    this.category,
    this.minRating,
    this.limit,
  });

  @override
  List<Object?> get props => [query, category, minRating, limit];
}

class RestaurantCategoriesLoadRequested extends RestaurantEvent {
  const RestaurantCategoriesLoadRequested();
}

class RestaurantFilterChanged extends RestaurantEvent {
  final String? category;
  final double? minRating;

  const RestaurantFilterChanged({
    this.category,
    this.minRating,
  });

  @override
  List<Object?> get props => [category, minRating];
}

class RestaurantRefreshRequested extends RestaurantEvent {
  const RestaurantRefreshRequested();
}

class RestaurantAddRequested extends RestaurantEvent {
  final String name;
  final String description;
  final String address;
  final String? phoneNumber;
  final String? website;
  final List<String> imageUrls;
  final double latitude;
  final double longitude;
  final List<String> categories;
  final String? ownerId;

  const RestaurantAddRequested({
    required this.name,
    required this.description,
    required this.address,
    this.phoneNumber,
    this.website,
    required this.imageUrls,
    required this.latitude,
    required this.longitude,
    required this.categories,
    this.ownerId,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    address,
    phoneNumber,
    website,
    imageUrls,
    latitude,
    longitude,
    categories,
    ownerId,
  ];
}