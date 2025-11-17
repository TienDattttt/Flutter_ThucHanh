import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/transaction.dart' as domain;
import '../../core/errors/exceptions.dart';
import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<void> cacheTransactions(String userId, List<domain.Transaction> transactions);
  Future<List<domain.Transaction>?> getCachedTransactions(String userId);
  Future<void> addCachedTransaction(String userId, domain.Transaction transaction);
  Future<void> updateCachedTransaction(String userId, domain.Transaction transaction);
  Future<void> deleteCachedTransaction(String userId, String transactionId);
  Future<void> clearTransactionCache(String userId);
  
  // Pending operations for offline sync
  Future<void> savePendingTransaction(String userId, domain.Transaction transaction);
  Future<List<domain.Transaction>> getPendingTransactions(String userId);
  Future<void> clearPendingTransactions(String userId);
  Future<void> removePendingTransaction(String userId, String transactionId);
  
  // Sync metadata
  Future<void> setLastSyncTime(String userId, DateTime syncTime);
  Future<DateTime?> getLastSyncTime(String userId);
}

class SecureStorageTransactionDataSource implements TransactionLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  
  SecureStorageTransactionDataSource({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();
  
  @override
  Future<void> cacheTransactions(String userId, List<domain.Transaction> transactions) async {
    try {
      final transactionModels = transactions
          .map((t) => TransactionModel.fromEntity(t))
          .toList();
      
      final jsonList = transactionModels
          .map((t) => t.toJson())
          .toList();
      
      await _secureStorage.write(
        key: _getCacheKey(userId),
        value: jsonEncode(jsonList),
      );
    } catch (e) {
      throw CacheException('Không thể lưu giao dịch vào cache: ${e.toString()}');
    }
  }
  
  @override
  Future<List<domain.Transaction>?> getCachedTransactions(String userId) async {
    try {
      final jsonString = await _secureStorage.read(key: _getCacheKey(userId));
      if (jsonString == null) return null;
      
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>) as domain.Transaction)
          .toList();
    } catch (e) {
      throw CacheException('Không thể đọc giao dịch từ cache: ${e.toString()}');
    }
  }
  
  @override
  Future<void> addCachedTransaction(String userId, domain.Transaction transaction) async {
    try {
      final existingTransactions = await getCachedTransactions(userId) ?? [];
      existingTransactions.add(transaction);
      
      // Sort by date (newest first)
      existingTransactions.sort((a, b) => b.date.compareTo(a.date));
      
      await cacheTransactions(userId, existingTransactions);
    } catch (e) {
      throw CacheException('Không thể thêm giao dịch vào cache: ${e.toString()}');
    }
  }
  
  @override
  Future<void> updateCachedTransaction(String userId, domain.Transaction transaction) async {
    try {
      final existingTransactions = await getCachedTransactions(userId) ?? [];
      final index = existingTransactions.indexWhere((t) => t.id == transaction.id);
      
      if (index != -1) {
        existingTransactions[index] = transaction;
        await cacheTransactions(userId, existingTransactions);
      }
    } catch (e) {
      throw CacheException('Không thể cập nhật giao dịch trong cache: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteCachedTransaction(String userId, String transactionId) async {
    try {
      final existingTransactions = await getCachedTransactions(userId) ?? [];
      existingTransactions.removeWhere((t) => t.id == transactionId);
      await cacheTransactions(userId, existingTransactions);
    } catch (e) {
      throw CacheException('Không thể xóa giao dịch khỏi cache: ${e.toString()}');
    }
  }
  
  @override
  Future<void> clearTransactionCache(String userId) async {
    try {
      await _secureStorage.delete(key: _getCacheKey(userId));
    } catch (e) {
      throw CacheException('Không thể xóa cache giao dịch: ${e.toString()}');
    }
  }
  
  @override
  Future<void> savePendingTransaction(String userId, domain.Transaction transaction) async {
    try {
      final existingPending = await getPendingTransactions(userId);
      
      // Check if transaction already exists in pending list
      final existingIndex = existingPending.indexWhere((t) => t.id == transaction.id);
      if (existingIndex != -1) {
        existingPending[existingIndex] = transaction;
      } else {
        existingPending.add(transaction);
      }
      
      final transactionModels = existingPending
          .map((t) => TransactionModel.fromEntity(t))
          .toList();
      
      final jsonList = transactionModels
          .map((t) => t.toJson())
          .toList();
      
      await _secureStorage.write(
        key: _getPendingKey(userId),
        value: jsonEncode(jsonList),
      );
    } catch (e) {
      throw CacheException('Không thể lưu giao dịch chờ đồng bộ: ${e.toString()}');
    }
  }
  
  @override
  Future<List<domain.Transaction>> getPendingTransactions(String userId) async {
    try {
      final jsonString = await _secureStorage.read(key: _getPendingKey(userId));
      if (jsonString == null) return [];
      
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>) as domain.Transaction)
          .toList();
    } catch (e) {
      throw CacheException('Không thể đọc giao dịch chờ đồng bộ: ${e.toString()}');
    }
  }
  
  @override
  Future<void> clearPendingTransactions(String userId) async {
    try {
      await _secureStorage.delete(key: _getPendingKey(userId));
    } catch (e) {
      throw CacheException('Không thể xóa giao dịch chờ đồng bộ: ${e.toString()}');
    }
  }
  
  @override
  Future<void> removePendingTransaction(String userId, String transactionId) async {
    try {
      final existingPending = await getPendingTransactions(userId);
      existingPending.removeWhere((t) => t.id == transactionId);
      
      if (existingPending.isEmpty) {
        await clearPendingTransactions(userId);
      } else {
        final transactionModels = existingPending
            .map((t) => TransactionModel.fromEntity(t))
            .toList();
        
        final jsonList = transactionModels
            .map((t) => t.toJson())
            .toList();
        
        await _secureStorage.write(
          key: _getPendingKey(userId),
          value: jsonEncode(jsonList),
        );
      }
    } catch (e) {
      throw CacheException('Không thể xóa giao dịch chờ đồng bộ: ${e.toString()}');
    }
  }
  
  @override
  Future<void> setLastSyncTime(String userId, DateTime syncTime) async {
    try {
      await _secureStorage.write(
        key: _getSyncTimeKey(userId),
        value: syncTime.toIso8601String(),
      );
    } catch (e) {
      throw CacheException('Không thể lưu thời gian đồng bộ: ${e.toString()}');
    }
  }
  
  @override
  Future<DateTime?> getLastSyncTime(String userId) async {
    try {
      final timeString = await _secureStorage.read(key: _getSyncTimeKey(userId));
      if (timeString == null) return null;
      
      return DateTime.parse(timeString);
    } catch (e) {
      throw CacheException('Không thể đọc thời gian đồng bộ: ${e.toString()}');
    }
  }
  
  String _getCacheKey(String userId) => 'transactions_cache_$userId';
  String _getPendingKey(String userId) => 'pending_transactions_$userId';
  String _getSyncTimeKey(String userId) => 'last_sync_time_$userId';
}