import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../validators/transaction_validator.dart';
import '../../core/errors/exceptions.dart';

class TransactionUseCase {
  final TransactionRepository _transactionRepository;
  
  TransactionUseCase(this._transactionRepository);
  
  Future<void> addTransaction(Transaction transaction) async {
    TransactionValidator.validateTransaction(transaction);
    return await _transactionRepository.addTransaction(transaction);
  }
  
  Future<void> updateTransaction(Transaction transaction) async {
    TransactionValidator.validateTransaction(transaction);
    return await _transactionRepository.updateTransaction(transaction);
  }
  
  Future<void> deleteTransaction(String id, String userId) async {
    if (id.isEmpty) {
      throw const ValidationException('Transaction ID không được để trống');
    }
    if (userId.isEmpty) {
      throw const ValidationException('User ID không được để trống');
    }
    
    return await _transactionRepository.deleteTransaction(id, userId);
  }
  
  Stream<List<Transaction>> getTransactions(String userId) {
    if (userId.isEmpty) {
      throw const ValidationException('User ID không được để trống');
    }
    
    return _transactionRepository.getTransactions(userId);
  }
  
  Future<List<Transaction>> getTransactionsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    if (userId.isEmpty) {
      throw const ValidationException('User ID không được để trống');
    }
    
    if (start.isAfter(end)) {
      throw const ValidationException('Ngày bắt đầu không thể sau ngày kết thúc');
    }
    
    return await _transactionRepository.getTransactionsByDateRange(
      userId,
      start,
      end,
    );
  }
  
  Future<List<Transaction>> getTransactionsPaginated(
    String userId, {
    int limit = 20,
    Transaction? startAfter,
  }) async {
    if (userId.isEmpty) {
      throw const ValidationException('User ID không được để trống');
    }
    
    if (limit <= 0) {
      throw const ValidationException('Limit phải lớn hơn 0');
    }
    
    return await _transactionRepository.getTransactionsPaginated(
      userId,
      limit: limit,
      startAfter: startAfter,
    );
  }
}