import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction.dart' as domain;
import '../../core/errors/exceptions.dart';
import '../../core/constants/app_constants.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<void> addTransaction(domain.Transaction transaction);
  Future<void> updateTransaction(domain.Transaction transaction);
  Future<void> deleteTransaction(String id, String userId);
  Stream<List<domain.Transaction>> getTransactionsStream(String userId);
  Future<List<domain.Transaction>> getTransactionsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  );
  Future<List<domain.Transaction>> getTransactionsPaginated(
    String userId, {
    int limit = 20,
    domain.Transaction? startAfter,
  });
}

class FirestoreTransactionDataSource implements TransactionRemoteDataSource {
  final FirebaseFirestore _firestore;
  
  FirestoreTransactionDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  @override
  Future<void> addTransaction(domain.Transaction transaction) async {
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      
      final docRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(transaction.userId)
          .collection(AppConstants.transactionsCollection);
      
      if (transaction.id.isEmpty) {
        // Auto-generate ID
        await docRef.add(transactionModel.toFirestore());
      } else {
        // Use provided ID
        await docRef.doc(transaction.id).set(transactionModel.toFirestore());
      }
    } on FirebaseException catch (e) {
      throw FirestoreException('Lỗi Firebase khi thêm giao dịch: ${e.message}');
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
    } on FirebaseException catch (e) {
      throw FirestoreException('Lỗi Firebase khi cập nhật giao dịch: ${e.message}');
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
    } on FirebaseException catch (e) {
      throw FirestoreException('Lỗi Firebase khi xóa giao dịch: ${e.message}');
    } catch (e) {
      throw FirestoreException('Không thể xóa giao dịch: ${e.toString()}');
    }
  }
  
  @override
  Stream<List<domain.Transaction>> getTransactionsStream(String userId) {
    try {
      return _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.transactionsCollection)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc) as domain.Transaction)
            .toList();
      });
    } catch (e) {
      throw FirestoreException('Không thể lấy stream giao dịch: ${e.toString()}');
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
          .map((doc) => TransactionModel.fromFirestore(doc) as domain.Transaction)
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException('Lỗi Firebase khi lấy giao dịch theo ngày: ${e.message}');
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
          .orderBy(FieldPath.documentId) // Secondary sort for consistent pagination
          .limit(limit);
      
      if (startAfter != null) {
        // Use compound cursor for reliable pagination
        query = query.startAfter([
          Timestamp.fromDate(startAfter.date),
          startAfter.id,
        ]);
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc) as domain.Transaction)
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException('Lỗi Firebase khi phân trang giao dịch: ${e.message}');
    } catch (e) {
      throw FirestoreException('Không thể lấy giao dịch phân trang: ${e.toString()}');
    }
  }
}