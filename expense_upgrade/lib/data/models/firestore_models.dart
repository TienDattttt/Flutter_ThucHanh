/// This file contains all Firestore document models and their structure
/// Used for consistent data modeling across the application

import 'package:cloud_firestore/cloud_firestore.dart';

/// Base interface for all Firestore models
abstract class FirestoreModel {
  Map<String, dynamic> toFirestore();
  String get id;
}

/// User document structure in Firestore
/// Collection: users/{userId}
class UserFirestoreModel implements FirestoreModel {
  @override
  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? preferences;
  
  UserFirestoreModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
    this.preferences,
  });
  
  factory UserFirestoreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserFirestoreModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      preferences: data['preferences'] as Map<String, dynamic>?,
    );
  }
  
  @override
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (preferences != null) 'preferences': preferences,
    };
  }
}

/// Transaction document structure in Firestore
/// Collection: users/{userId}/transactions/{transactionId}
class TransactionFirestoreModel implements FirestoreModel {
  @override
  final String id;
  final double amount;
  final String description;
  final String category;
  final DateTime date;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;
  
  TransactionFirestoreModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });
  
  factory TransactionFirestoreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionFirestoreModel(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }
  
  @override
  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'description': description,
      'category': category,
      'date': Timestamp.fromDate(date),
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Category document structure in Firestore
/// Collection: users/{userId}/categories/{categoryId}
class CategoryFirestoreModel implements FirestoreModel {
  @override
  final String id;
  final String name;
  final String icon;
  final String color;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? sortOrder;
  
  CategoryFirestoreModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isDefault,
    required this.createdAt,
    this.updatedAt,
    this.sortOrder,
  });
  
  factory CategoryFirestoreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryFirestoreModel(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      color: data['color'] ?? '',
      isDefault: data['isDefault'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      sortOrder: data['sortOrder'] as int?,
    );
  }
  
  @override
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (sortOrder != null) 'sortOrder': sortOrder,
    };
  }
}

/// Settings document structure in Firestore
/// Collection: users/{userId}/settings/{settingId}
class SettingsFirestoreModel implements FirestoreModel {
  @override
  final String id;
  final String key;
  final dynamic value;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  SettingsFirestoreModel({
    required this.id,
    required this.key,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory SettingsFirestoreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SettingsFirestoreModel(
      id: doc.id,
      key: data['key'] ?? '',
      value: data['value'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
  
  @override
  Map<String, dynamic> toFirestore() {
    return {
      'key': key,
      'value': value,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// Audit log document structure in Firestore
/// Collection: auditLogs/{logId}
class AuditLogFirestoreModel implements FirestoreModel {
  @override
  final String id;
  final String userId;
  final String action;
  final String resourceType;
  final String? resourceId;
  final Map<String, dynamic>? details;
  final DateTime timestamp;
  final String? ipAddress;
  final String? userAgent;
  
  AuditLogFirestoreModel({
    required this.id,
    required this.userId,
    required this.action,
    required this.resourceType,
    this.resourceId,
    this.details,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
  });
  
  factory AuditLogFirestoreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuditLogFirestoreModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      action: data['action'] ?? '',
      resourceType: data['resourceType'] ?? '',
      resourceId: data['resourceId'] as String?,
      details: data['details'] as Map<String, dynamic>?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      ipAddress: data['ipAddress'] as String?,
      userAgent: data['userAgent'] as String?,
    );
  }
  
  @override
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'action': action,
      'resourceType': resourceType,
      if (resourceId != null) 'resourceId': resourceId,
      if (details != null) 'details': details,
      'timestamp': Timestamp.fromDate(timestamp),
      if (ipAddress != null) 'ipAddress': ipAddress,
      if (userAgent != null) 'userAgent': userAgent,
    };
  }
}

/// Firestore collection and document structure constants
class FirestoreStructure {
  // Root collections
  static const String users = 'users';
  static const String defaultCategories = 'defaultCategories';
  static const String auditLogs = 'auditLogs';
  static const String system = 'system';
  
  // User subcollections
  static const String transactions = 'transactions';
  static const String categories = 'categories';
  static const String settings = 'settings';
  
  // Document paths
  static String userPath(String userId) => '$users/$userId';
  static String transactionPath(String userId, String transactionId) => 
      '$users/$userId/$transactions/$transactionId';
  static String categoryPath(String userId, String categoryId) => 
      '$users/$userId/$categories/$categoryId';
  static String settingPath(String userId, String settingId) => 
      '$users/$userId/$settings/$settingId';
  static String auditLogPath(String logId) => '$auditLogs/$logId';
  
  // Collection references
  static CollectionReference usersCollection(FirebaseFirestore firestore) =>
      firestore.collection(users);
  
  static CollectionReference transactionsCollection(
    FirebaseFirestore firestore, 
    String userId,
  ) => firestore.collection(users).doc(userId).collection(transactions);
  
  static CollectionReference categoriesCollection(
    FirebaseFirestore firestore, 
    String userId,
  ) => firestore.collection(users).doc(userId).collection(categories);
  
  static CollectionReference settingsCollection(
    FirebaseFirestore firestore, 
    String userId,
  ) => firestore.collection(users).doc(userId).collection(settings);
  
  static CollectionReference auditLogsCollection(FirebaseFirestore firestore) =>
      firestore.collection(auditLogs);
}

/// Validation helpers for Firestore models
class FirestoreValidation {
  static bool isValidTransactionData(Map<String, dynamic> data) {
    return data.containsKey('amount') &&
           data.containsKey('description') &&
           data.containsKey('category') &&
           data.containsKey('date') &&
           data.containsKey('userId') &&
           data.containsKey('createdAt') &&
           data['amount'] is num &&
           data['amount'] > 0 &&
           data['description'] is String &&
           data['category'] is String &&
           data['date'] is Timestamp &&
           data['userId'] is String &&
           data['createdAt'] is Timestamp;
  }
  
  static bool isValidCategoryData(Map<String, dynamic> data) {
    return data.containsKey('name') &&
           data.containsKey('icon') &&
           data.containsKey('color') &&
           data.containsKey('isDefault') &&
           data.containsKey('createdAt') &&
           data['name'] is String &&
           data['icon'] is String &&
           data['color'] is String &&
           data['isDefault'] is bool &&
           data['createdAt'] is Timestamp;
  }
  
  static bool isValidUserData(Map<String, dynamic> data) {
    return data.containsKey('email') &&
           data.containsKey('displayName') &&
           data.containsKey('createdAt') &&
           data['email'] is String &&
           data['displayName'] is String &&
           data['createdAt'] is Timestamp;
  }
}