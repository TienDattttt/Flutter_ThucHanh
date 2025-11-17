import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../../domain/validators/user_validator.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    required super.createdAt,
  });
  
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
  
  factory UserModel.fromEntity(User user) {
    UserValidator.validateUser(user);
    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      createdAt: user.createdAt,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}