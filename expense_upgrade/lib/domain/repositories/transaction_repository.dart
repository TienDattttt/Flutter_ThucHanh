import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<void> addTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id, String userId);
  Stream<List<Transaction>> getTransactions(String userId);
  Future<List<Transaction>> getTransactionsByDateRange(
    String userId, 
    DateTime start, 
    DateTime end,
  );
  Future<List<Transaction>> getTransactionsPaginated(
    String userId, 
    {int limit = 20, Transaction? startAfter}
  );
}