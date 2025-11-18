import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String restaurantId;
  final String userId;
  final String userDisplayName;
  final String? userPhotoUrl;
  final int rating;
  final String comment;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEdited;
  final int helpfulCount;
  final List<String> helpfulUserIds;

  const Review({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.userDisplayName,
    this.userPhotoUrl,
    required this.rating,
    required this.comment,
    required this.imageUrls,
    required this.createdAt,
    this.updatedAt,
    required this.isEdited,
    required this.helpfulCount,
    required this.helpfulUserIds,
  });

  Review copyWith({
    String? id,
    String? restaurantId,
    String? userId,
    String? userDisplayName,
    String? userPhotoUrl,
    int? rating,
    String? comment,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEdited,
    int? helpfulCount,
    List<String>? helpfulUserIds,
  }) {
    return Review(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      helpfulUserIds: helpfulUserIds ?? this.helpfulUserIds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        restaurantId,
        userId,
        userDisplayName,
        userPhotoUrl,
        rating,
        comment,
        imageUrls,
        createdAt,
        updatedAt,
        isEdited,
        helpfulCount,
        helpfulUserIds,
      ];

  @override
  String toString() {
    return 'Review(id: $id, restaurantId: $restaurantId, userId: $userId, userDisplayName: $userDisplayName, userPhotoUrl: $userPhotoUrl, rating: $rating, comment: $comment, imageUrls: $imageUrls, createdAt: $createdAt, updatedAt: $updatedAt, isEdited: $isEdited, helpfulCount: $helpfulCount, helpfulUserIds: $helpfulUserIds)';
  }
}