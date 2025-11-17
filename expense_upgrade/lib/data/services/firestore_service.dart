import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction.dart' as domain;
import '../../domain/repositories/transaction_repository.dart';
import '../../core/errors/exceptions.dart';
import '../../core/constants/app_constants.dart';
import '../models/transaction_model.dart';

class FirestoreService implements TransactionRepository {
  final FirebaseFirestore _firestore;
  
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  @override
  Future<void> addTransaction(domain.Transaction transaction) async {
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(transaction.userId)
          .collection(AppConstants.transactionsCollection)
          .add(transactionModel.toFirestore());
    } catch (e) {
      throw FirestoreException('Không thể thêm giao dịch: ${e.toString()}');
    }
  }
  
  @override
  Future<void> updateTransaction(domain.Transaction transaction) async {
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(transaction.userId)
          .collection(AppConstants.transactionsCollection)
          .doc(transaction.id)
          .update(transactionModel.toFirestore());
    } catch (e) {
      throw FirestoreException('Không thể cập nhật giao dịch: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteTransaction(String id, String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.transactionsCollection)
          .doc(id)
          .delete();
    } catch (e) {
      throw FirestoreException('Không thể xóa giao dịch: ${e.toString()}');
    }
  }
  
  @override
  Stream<List<domain.Transaction>> getTransactions(String userId) {
    try {
      return _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.transactionsCollection)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print('DEBUG: Error in getTransactions: $e');
      throw FirestoreException('Không thể lấy danh sách giao dịch: ${e.toString()}');
    }
  }
  
  @override
  Future<List<domain.Transaction>> getTransactionsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.transactionsCollection)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('date', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirestoreException('Không thể lấy giao dịch theo khoảng thời gian: ${e.toString()}');
    }
  }
  
  @override
  Future<List<domain.Transaction>> getTransactionsPaginated(
    String userId, {
    int limit = 20,
    domain.Transaction? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.transactionsCollection)
          .orderBy('date', descending: true)
          .limit(limit);
      
      if (startAfter != null) {
        // Use the date and id for cursor-based pagination
        query = query.startAfter([
          Timestamp.fromDate(startAfter.date),
          startAfter.id,
        ]);
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirestoreException('Không thể lấy giao dịch phân trang: ${e.toString()}');
    }
  }
}