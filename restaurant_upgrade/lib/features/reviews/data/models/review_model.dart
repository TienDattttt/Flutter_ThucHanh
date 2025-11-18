import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.restaurantId,
    required super.userId,
    required super.userDisplayName,
    super.userPhotoUrl,
    required super.rating,
    required super.comment,
    required super.imageUrls,
    required super.createdAt,
    super.updatedAt,
    required super.isEdited,
    required super.helpfulCount,
    required super.helpfulUserIds,
  });

  /// Create ReviewModel from Review entity
  factory ReviewModel.fromEntity(Review review) {
    return ReviewModel(
      id: review.id,
      restaurantId: review.restaurantId,
      userId: review.userId,
      userDisplayName: review.userDisplayName,
      userPhotoUrl: review.userPhotoUrl,
      rating: review.rating,
      comment: review.comment,
      imageUrls: review.imageUrls,
      createdAt: review.createdAt,
      updatedAt: review.updatedAt,
      isEdited: review.isEdited,
      helpfulCount: review.helpfulCount,
      helpfulUserIds: review.helpfulUserIds,
    );
  }

  /// Create ReviewModel from Firestore document
  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ReviewModel(
      id: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      userId: data['userId'] ?? '',
      userDisplayName: data['userDisplayName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      rating: data['rating'] ?? 1,
      comment: data['comment'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isEdited: data['isEdited'] ?? false,
      helpfulCount: data['helpfulCount'] ?? 0,
      helpfulUserIds: List<String>.from(data['helpfulUserIds'] ?? []),
    );
  }

  /// Create ReviewModel from JSON
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      userId: json['userId'] ?? '',
      userDisplayName: json['userDisplayName'] ?? '',
      userPhotoUrl: json['userPhotoUrl'],
      rating: json['rating'] ?? 1,
      comment: json['comment'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
      isEdited: json['isEdited'] ?? false,
      helpfulCount: json['helpfulCount'] ?? 0,
      helpfulUserIds: List<String>.from(json['helpfulUserIds'] ?? []),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userPhotoUrl': userPhotoUrl,
      'rating': rating,
      'comment': comment,
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isEdited': isEdited,
      'helpfulCount': helpfulCount,
      'helpfulUserIds': helpfulUserIds,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userPhotoUrl': userPhotoUrl,
      'rating': rating,
      'comment': comment,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isEdited': isEdited,
      'helpfulCount': helpfulCount,
      'helpfulUserIds': helpfulUserIds,
    };
  }

  /// Create a copy with updated fields
  @override
  ReviewModel copyWith({
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
    return ReviewModel(
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

  /// Convert to Review entity
  Review toEntity() {
    return Review(
      id: id,
      restaurantId: restaurantId,
      userId: userId,
      userDisplayName: userDisplayName,
      userPhotoUrl: userPhotoUrl,
      rating: rating,
      comment: comment,
      imageUrls: imageUrls,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isEdited: isEdited,
      helpfulCount: helpfulCount,
      helpfulUserIds: helpfulUserIds,
    );
  }

  /// Create ReviewModel for new review
  factory ReviewModel.create({
    required String restaurantId,
    required String userId,
    required String userDisplayName,
    String? userPhotoUrl,
    required int rating,
    required String comment,
    List<String>? imageUrls,
  }) {
    final now = DateTime.now();
    return ReviewModel(
      id: '', // Will be set by Firestore
      restaurantId: restaurantId,
      userId: userId,
      userDisplayName: userDisplayName,
      userPhotoUrl: userPhotoUrl,
      rating: rating,
      comment: comment,
      imageUrls: imageUrls ?? [],
      createdAt: now,
      updatedAt: null,
      isEdited: false,
      helpfulCount: 0,
      helpfulUserIds: [],
    );
  }

  /// Mark as helpful by user
  ReviewModel markAsHelpful(String userId) {
    if (helpfulUserIds.contains(userId)) {
      return this; // Already marked as helpful
    }
    
    return copyWith(
      helpfulUserIds: [...helpfulUserIds, userId],
      helpfulCount: helpfulCount + 1,
    );
  }

  /// Unmark as helpful by user
  ReviewModel unmarkAsHelpful(String userId) {
    if (!helpfulUserIds.contains(userId)) {
      return this; // Not marked as helpful
    }
    
    final newHelpfulUserIds = List<String>.from(helpfulUserIds);
    newHelpfulUserIds.remove(userId);
    
    return copyWith(
      helpfulUserIds: newHelpfulUserIds,
      helpfulCount: helpfulCount - 1,
    );
  }

  /// Check if user marked this review as helpful
  bool isMarkedAsHelpfulBy(String userId) {
    return helpfulUserIds.contains(userId);
  }
}