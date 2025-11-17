import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction.dart' as domain;
import '../../domain/validators/transaction_validator.dart';

class TransactionModel extends domain.Transaction {
  const TransactionModel({
    required String id,
    required double amount,
    required String description,
    required String category,
    required DateTime date,
    required String userId,
    required DateTime createdAt,
  }) : super(
          id: id,
          amount: amount,
          description: description,
          category: category,
          date: date,
          userId: userId,
          createdAt: createdAt,
        );
  
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
  
  factory TransactionModel.fromEntity(domain.Transaction transaction) {
    TransactionValidator.validateTransaction(transaction);
    return TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      description: transaction.description,
      category: transaction.category,
      date: transaction.date,
      userId: transaction.userId,
      createdAt: transaction.createdAt,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'description': description,
      'category': category,
      'date': Timestamp.fromDate(date),
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
  
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      date: DateTime.parse(json['date']),
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}