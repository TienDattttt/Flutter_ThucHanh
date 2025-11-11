import '../../domain/entities/restaurant.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String address;
  final double avgRating;
  final String coverImageUrl;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.address,
    required this.avgRating,
    required this.coverImageUrl,
  });

  factory RestaurantModel.fromMap(String id, Map<String, dynamic> map) {
    return RestaurantModel(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      avgRating: (map['avgRating'] ?? 0).toDouble(),
      coverImageUrl: map['coverImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'address': address,
    'avgRating': avgRating,
    'coverImageUrl': coverImageUrl,
  };

  Restaurant toEntity() => Restaurant(
    id: id,
    name: name,
    address: address,
    avgRating: avgRating,
    coverImageUrl: coverImageUrl,
  );

  factory RestaurantModel.fromEntity(Restaurant restaurant) => RestaurantModel(
    id: restaurant.id,
    name: restaurant.name,
    address: restaurant.address,
    avgRating: restaurant.avgRating,
    coverImageUrl: restaurant.coverImageUrl,
  );
}
