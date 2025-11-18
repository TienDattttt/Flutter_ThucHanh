import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? relatedId;

  const Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.relatedId,
  });

  Notification copyWith({
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
    return Notification(
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

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    title,
    body,
    imageUrl,
    data,
    isRead,
    createdAt,
    readAt,
    relatedId,
  ];

  @override
  String toString() {
    return 'Notification(id: $id, userId: $userId, type: $type, title: $title, body: $body, imageUrl: $imageUrl, data: $data, isRead: $isRead, createdAt: $createdAt, readAt: $readAt, relatedId: $relatedId)';
  }
}