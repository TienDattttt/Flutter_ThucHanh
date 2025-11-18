import 'package:equatable/equatable.dart';

class Restaurant extends Equatable {
  final String id;
  final String name;
  final String description;
  final String address;
  final String? phoneNumber;
  final String? website;
  final List<String> imageUrls;
  final double latitude;
  final double longitude;
  final List<String> categories;
  final double averageRating;
  final int totalReviews;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? ownerId;

  const Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    this.phoneNumber,
    this.website,
    required this.imageUrls,
    required this.latitude,
    required this.longitude,
    required this.categories,
    required this.averageRating,
    required this.totalReviews,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.ownerId,
  });

  Restaurant copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? phoneNumber,
    String? website,
    List<String>? imageUrls,
    double? latitude,
    double? longitude,
    List<String>? categories,
    double? averageRating,
    int? totalReviews,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? ownerId,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      imageUrls: imageUrls ?? this.imageUrls,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      categories: categories ?? this.categories,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        address,
        phoneNumber,
        website,
        imageUrls,
        latitude,
        longitude,
        categories,
        averageRating,
        totalReviews,
        createdAt,
        updatedAt,
        isActive,
        ownerId,
      ];

  @override
  String toString() {
    return 'Restaurant(id: $id, name: $name, description: $description, address: $address, phoneNumber: $phoneNumber, website: $website, imageUrls: $imageUrls, latitude: $latitude, longitude: $longitude, categories: $categories, averageRating: $averageRating, totalReviews: $totalReviews, createdAt: $createdAt, updatedAt: $updatedAt, isActive: $isActive, ownerId: $ownerId)';
  }
}