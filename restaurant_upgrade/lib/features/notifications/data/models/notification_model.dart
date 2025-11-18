import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification.dart';

class NotificationModel extends Notification {
  const NotificationModel({
    required String id,
    required String userId,
    required String type,
    required String title,
    required String body,
    String? imageUrl,
    required Map<String, dynamic> data,
    required bool isRead,
    required DateTime createdAt,
    DateTime? readAt,
    String? relatedId,
  }) : super(
    id: id,
    userId: userId,
    type: type,
    title: title,
    body: body,
    imageUrl: imageUrl,
    data: data,
    isRead: isRead,
    createdAt: createdAt,
    readAt: readAt,
    relatedId: relatedId,
  );

  /// Create NotificationModel from Notification entity
  factory NotificationModel.fromEntity(Notification notification) {
    return NotificationModel(
      id: notification.id,
      userId: notification.userId,
      type: notification.type,
      title: notification.title,
      body: notification.body,
      imageUrl: notification.imageUrl,
      data: notification.data,
      isRead: notification.isRead,
      createdAt: notification.createdAt,
      readAt: notification.readAt,
      relatedId: notification.relatedId,
    );
  }

  /// Create NotificationModel from Firestore document
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      imageUrl: data['imageUrl'],
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      relatedId: data['relatedId'],
    );
  }

  /// Create NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      imageUrl: json['imageUrl'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      readAt: json['readAt'] != null 
          ? DateTime.parse(json['readAt'])
          : null,
      relatedId: json['relatedId'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'relatedId': relatedId,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'relatedId': relatedId,
    };
  }

  /// Create a copy with updated fields
  @override
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? body,
    String? imageUrl,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    String? relatedId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      relatedId: relatedId ?? this.relatedId,
    );
  }

  /// Convert to Notification entity
  Notification toEntity() {
    return Notification(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
      isRead: isRead,
      createdAt: createdAt,
      readAt: readAt,
      relatedId: relatedId,
    );
  }

  /// Create NotificationModel for new notification
  factory NotificationModel.create({
    required String userId,
    required String type,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
    String? relatedId,
  }) {
    final now = DateTime.now();
    return NotificationModel(
      id: '', // Will be set by Firestore
      userId: userId,
      type: type,
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data ?? {},
      isRead: false,
      createdAt: now,
      readAt: null,
      relatedId: relatedId,
    );
  }

  /// Mark notification as read
  NotificationModel markAsRead() {
    if (isRead) return this;
    
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  /// Check if notification is recent (within 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  /// Get notification icon based on type
  String get iconName {
    switch (type) {
      case 'new_review':
        return 'rate_review';
      case 'review_reply':
        return 'reply';
      case 'restaurant_update':
        return 'restaurant';
      case 'system_announcement':
        return 'announcement';
      default:
        return 'notifications';
    }
  }

  /// Get notification color based on type
  String get colorHex {
    switch (type) {
      case 'new_review':
        return '#4CAF50'; // Green
      case 'review_reply':
        return '#2196F3'; // Blue
      case 'restaurant_update':
        return '#FF9800'; // Orange
      case 'system_announcement':
        return '#9C27B0'; // Purple
      default:
        return '#757575'; // Grey
    }
  }
}