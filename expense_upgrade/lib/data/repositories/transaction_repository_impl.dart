import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';
import '../../core/errors/exceptions.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final FirestoreService _firestoreService;
  final LocalStorageService _localStorageService;
  final SyncService _syncService;
  
  TransactionRepositoryImpl({
    required FirestoreService firestoreService,
    required LocalStorageService localStorageService,
    required SyncService syncService,
  }) : _firestoreService = firestoreService,
       _localStorageService = localStorageService,
       _syncService = syncService;
  
  @override
  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _syncService.addTransactionWithSync(transaction.userId, transaction);
    } catch (e) {
      throw FirestoreException('Không thể thêm giao dịch: ${e.toString()}');
    }
  }
  
  @override
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _syncService.updateTransactionWithSync(transaction.userId, transaction);
    } catch (e) {
      throw FirestoreException('Không thể cập nhật giao dịch: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteTransaction(String id, String userId) async {
    try {
      await _syncService.deleteTransactionWithSync(userId, id);
    } catch (e) {
      throw FirestoreException('Không thể xóa giao dịch: ${e.toString()}');
    }
  }
  
  @override
  Stream<List<Transaction>> getTransactions(String userId) {
    try {
      // Return Firestore stream for real-time updates
      // Local cache is handled by sync service
      return _firestoreService.getTransactions(userId);
    } catch (e) {
      throw FirestoreException('Không thể lấy danh sách giao dịch: ${e.toString()}');
    }
  }
  
  @override
  Future<List<Transaction>> getTransactionsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final isConnected = await _localStorageService.isConnected();
      
      if (isConnected) {
        // Get from Firestore and cache the result
        final transactions = await _firestoreService.getTransactionsByDateRange(
          userId, start, end,
        );
        
        // Update cache with fresh data
        await _localStorageService.cacheTransactions(userId, transactions);
        
        return transactions;
      } else {
        // Get from cache when offline
        final cachedTransactions = await _localStorageService.getCachedTransactions(userId);
        if (cachedTransactions == null) {
          throw NetworkException('Không có kết nối internet và không có dữ liệu cache');
        }
        
        // Filter cached transactions by date range
        return cachedTransactions.where((transaction) {
          return transaction.date.isAfter(start.subtract(const Duration(days: 1))) &&
                 transaction.date.isBefore(end.add(const Duration(days: 1)));
        }).toList();
      }
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw FirestoreException('Không thể lấy giao dịch theo khoảng thời gian: ${e.toString()}');
    }
  }
  
  @override
  Future<List<Transaction>> getTransactionsPaginated(
    String userId, {
    int limit = 20,
    Transaction? startAfter,
  }) async {
    try {
      final isConnected = await _localStorageService.isConnected();
      
      if (isConnected) {
        // Get from Firestore
        final transactions = await _firestoreService.getTransactionsPaginated(
          userId,
          limit: limit,
          startAfter: startAfter,
        );
        
        // Update cache with fresh data (merge with existing cache)
        final existingCache = await _localStorageService.getCachedTransactions(userId) ?? [];
        final mergedTransactions = _mergeTransactions(existingCache, transactions);
        await _localStorageService.cacheTransactions(userId, mergedTransactions);
        
        return transactions;
      } else {
        // Get from cache when offline
        final cachedTransactions = await _localStorageService.getCachedTransactions(userId);
        if (cachedTransactions == null) {
          throw NetworkException('Không có kết nối internet và không có dữ liệu cache');
        }
        
        // Implement simple pagination on cached data
        final sortedTransactions = List<Transaction>.from(cachedTransactions)
          ..sort((a, b) => b.date.compareTo(a.date));
        
        int startIndex = 0;
        if (startAfter != null) {
          startIndex = sortedTransactions.indexWhere((t) => t.id == startAfter.id) + 1;
          if (startIndex <= 0) startIndex = 0;
        }
        
        final endIndex = (startIndex + limit).clamp(0, sortedTransactions.length);
        return sortedTransactions.sublist(startIndex, endIndex);
      }
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw FirestoreException('Không thể lấy giao dịch phân trang: ${e.toString()}');
    }
  }
  
  /// Get cached transactions for offline access
  Future<List<Transaction>?> getCachedTransactions(String userId) async {
    try {
      return await _localStorageService.getCachedTransactions(userId);
    } catch (e) {
      throw CacheException('Không thể lấy dữ liệu cache: ${e.toString()}');
    }
  }
  
  /// Force sync pending transactions
  Future<void> syncPendingTransactions(String userId) async {
    try {
      await _syncService.syncPendingTransactions(userId);
    } catch (e) {
      throw FirestoreException('Không thể đồng bộ dữ liệu: ${e.toString()}');
    }
  }
  
  /// Get sync status
  Future<SyncStatus> getSyncStatus(String userId) async {
    try {
      return await _syncService.getSyncStatus(userId);
    } catch (e) {
      throw FirestoreException('Không thể lấy trạng thái đồng bộ: ${e.toString()}');
    }
  }
  
  /// Clear user cache
  Future<void> clearUserCache(String userId) async {
    try {
      await _localStorageService.clearUserCache(userId);
    } catch (e) {
      throw CacheException('Không thể xóa cache: ${e.toString()}');
    }
  }
  
  /// Merge transactions, avoiding duplicates
  List<Transaction> _mergeTransactions(List<Transaction> existing, List<Transaction> newTransactions) {
    final Map<String, Transaction> transactionMap = {};
    
    // Add existing transactions
    for (final transaction in existing) {
      transactionMap[transaction.id] = transaction;
    }
    
    // Add/update with new transactions
    for (final transaction in newTransactions) {
      transactionMap[transaction.id] = transaction;
    }
    
    return transactionMap.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}