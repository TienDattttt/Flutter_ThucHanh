import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/restaurant.dart';

class RestaurantModel extends Restaurant {
  const RestaurantModel({
    required super.id,
    required super.name,
    required super.description,
    required super.address,
    super.phoneNumber,
    super.website,
    required super.imageUrls,
    required super.latitude,
    required super.longitude,
    required super.categories,
    required super.averageRating,
    required super.totalReviews,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
    super.ownerId,
  });

  /// Create RestaurantModel from Restaurant entity
  factory RestaurantModel.fromEntity(Restaurant restaurant) {
    return RestaurantModel(
      id: restaurant.id,
      name: restaurant.name,
      description: restaurant.description,
      address: restaurant.address,
      phoneNumber: restaurant.phoneNumber,
      website: restaurant.website,
      imageUrls: restaurant.imageUrls,
      latitude: restaurant.latitude,
      longitude: restaurant.longitude,
      categories: restaurant.categories,
      averageRating: restaurant.averageRating,
      totalReviews: restaurant.totalReviews,
      createdAt: restaurant.createdAt,
      updatedAt: restaurant.updatedAt,
      isActive: restaurant.isActive,
      ownerId: restaurant.ownerId,
    );
  }

  /// Create RestaurantModel from Firestore document
  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return RestaurantModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      phoneNumber: data['phoneNumber'],
      website: data['website'],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      latitude: data['location'] != null 
          ? (data['location']['latitude'] ?? 0.0).toDouble()
          : (data['latitude'] ?? 0.0).toDouble(),
      longitude: data['location'] != null 
          ? (data['location']['longitude'] ?? 0.0).toDouble()
          : (data['longitude'] ?? 0.0).toDouble(),
      categories: List<String>.from(data['categories'] ?? []),
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      ownerId: data['ownerId'],
    );
  }

  /// Create RestaurantModel from JSON
  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'],
      website: json['website'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      categories: List<String>.from(json['categories'] ?? []),
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
      ownerId: json['ownerId'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phoneNumber': phoneNumber,
      'website': website,
      'imageUrls': imageUrls,
      'latitude': latitude,
      'longitude': longitude,
      'categories': categories,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'ownerId': ownerId,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'phoneNumber': phoneNumber,
      'website': website,
      'imageUrls': imageUrls,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'categories': categories,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'ownerId': ownerId,
    };
  }

  /// Create a copy with updated fields
  @override
  RestaurantModel copyWith({
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
    return RestaurantModel(
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

  /// Convert to Restaurant entity
  Restaurant toEntity() {
    return Restaurant(
      id: id,
      name: name,
      description: description,
      address: address,
      phoneNumber: phoneNumber,
      website: website,
      imageUrls: imageUrls,
      latitude: latitude,
      longitude: longitude,
      categories: categories,
      averageRating: averageRating,
      totalReviews: totalReviews,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      ownerId: ownerId,
    );
  }

  /// Create RestaurantModel for new restaurant
  factory RestaurantModel.create({
    required String name,
    required String description,
    required String address,
    String? phoneNumber,
    String? website,
    required List<String> imageUrls,
    required double latitude,
    required double longitude,
    required List<String> categories,
    String? ownerId,
  }) {
    final now = DateTime.now();
    return RestaurantModel(
      id: '', // Will be set by Firestore
      name: name,
      description: description,
      address: address,
      phoneNumber: phoneNumber,
      website: website,
      imageUrls: imageUrls,
      latitude: latitude,
      longitude: longitude,
      categories: categories,
      averageRating: 0.0,
      totalReviews: 0,
      createdAt: now,
      updatedAt: now,
      isActive: true,
      ownerId: ownerId,
    );
  }
}