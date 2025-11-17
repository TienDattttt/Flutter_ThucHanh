import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/expense_category.dart';
import '../../core/errors/exceptions.dart';
import '../models/transaction_model.dart';
import '../models/expense_category_model.dart';

class LocalStorageService {
  final FlutterSecureStorage _secureStorage;
  final Connectivity _connectivity;
  
  LocalStorageService({
    FlutterSecureStorage? secureStorage,
    Connectivity? connectivity,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _connectivity = connectivity ?? Connectivity();
  
  // Transaction caching
  Future<void> cacheTransactions(String userId, List<Transaction> transactions) async {
    try {
      final transactionModels = transactions
          .map((t) => TransactionModel.fromEntity(t))
          .toList();
      
      final jsonList = transactionModels
          .map((t) => t.toJson())
          .toList();
      
      await _secureStorage.write(
        key: 'transactions_$userId',
        value: jsonEncode(jsonList),
      );
    } catch (e) {
      throw CacheException('Không thể lưu giao dịch vào cache: ${e.toString()}');
    }
  }
  
  Future<List<Transaction>?> getCachedTransactions(String userId) async {
    try {
      final jsonString = await _secureStorage.read(key: 'transactions_$userId');
      if (jsonString == null) return null;
      
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>) as Transaction)
          .toList();
    } catch (e) {
      throw CacheException('Không thể đọc giao dịch từ cache: ${e.toString()}');
    }
  }
  
  // Category caching
  Future<void> cacheCategories(String userId, List<ExpenseCategory> categories) async {
    try {
      final categoryModels = categories
          .map((c) => ExpenseCategoryModel.fromEntity(c))
          .toList();
      
      final jsonList = categoryModels
          .map((c) => c.toJson())
          .toList();
      
      await _secureStorage.write(
        key: 'categories_$userId',
        value: jsonEncode(jsonList),
      );
    } catch (e) {
      throw CacheException('Không thể lưu danh mục vào cache: ${e.toString()}');
    }
  }
  
  Future<List<ExpenseCategory>?> getCachedCategories(String userId) async {
    try {
      final jsonString = await _secureStorage.read(key: 'categories_$userId');
      if (jsonString == null) return null;
      
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => ExpenseCategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Không thể đọc danh mục từ cache: ${e.toString()}');
    }
  }
  
  // User preferences
  Future<void> saveUserPreference(String key, String value) async {
    try {
      await _secureStorage.write(key: 'pref_$key', value: value);
    } catch (e) {
      throw CacheException('Không thể lưu cài đặt: ${e.toString()}');
    }
  }
  
  Future<String?> getUserPreference(String key) async {
    try {
      return await _secureStorage.read(key: 'pref_$key');
    } catch (e) {
      throw CacheException('Không thể đọc cài đặt: ${e.toString()}');
    }
  }
  
  // Clear all cached data
  Future<void> clearAllCache() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw CacheException('Không thể xóa cache: ${e.toString()}');
    }
  }
  
  // Clear user-specific cache
  Future<void> clearUserCache(String userId) async {
    try {
      await _secureStorage.delete(key: 'transactions_$userId');
      await _secureStorage.delete(key: 'categories_$userId');
      await _secureStorage.delete(key: 'pending_transactions_$userId');
      await _secureStorage.delete(key: 'last_sync_$userId');
    } catch (e) {
      throw CacheException('Không thể xóa cache người dùng: ${e.toString()}');
    }
  }

  // Offline sync support
  Future<void> savePendingTransaction(String userId, Transaction transaction) async {
    try {
      final existingPending = await getPendingTransactions(userId);
      existingPending.add(transaction);
      
      final transactionModels = existingPending
          .map((t) => TransactionModel.fromEntity(t))
          .toList();
      
      final jsonList = transactionModels
          .map((t) => t.toJson())
          .toList();
      
      await _secureStorage.write(
        key: 'pending_transactions_$userId',
        value: jsonEncode(jsonList),
      );
    } catch (e) {
      throw CacheException('Không thể lưu giao dịch chờ đồng bộ: ${e.toString()}');
    }
  }

  Future<List<Transaction>> getPendingTransactions(String userId) async {
    try {
      final jsonString = await _secureStorage.read(key: 'pending_transactions_$userId');
      if (jsonString == null) return [];
      
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>) as Transaction)
          .toList();
    } catch (e) {
      throw CacheException('Không thể đọc giao dịch chờ đồng bộ: ${e.toString()}');
    }
  }

  Future<void> clearPendingTransactions(String userId) async {
    try {
      await _secureStorage.delete(key: 'pending_transactions_$userId');
    } catch (e) {
      throw CacheException('Không thể xóa giao dịch chờ đồng bộ: ${e.toString()}');
    }
  }

  Future<void> saveLastSyncTime(String userId, DateTime syncTime) async {
    try {
      await _secureStorage.write(
        key: 'last_sync_$userId',
        value: syncTime.toIso8601String(),
      );
    } catch (e) {
      throw CacheException('Không thể lưu thời gian đồng bộ: ${e.toString()}');
    }
  }

  Future<DateTime?> getLastSyncTime(String userId) async {
    try {
      final timeString = await _secureStorage.read(key: 'last_sync_$userId');
      if (timeString == null) return null;
      
      return DateTime.parse(timeString);
    } catch (e) {
      throw CacheException('Không thể đọc thời gian đồng bộ: ${e.toString()}');
    }
  }

  // Network connectivity
  Future<bool> isConnected() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  Stream<ConnectivityResult> get connectivityStream => 
      _connectivity.onConnectivityChanged.map((results) => results.first);

  // Error logging
  Future<void> logError(String error, {String? userId}) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final errorLog = {
        'timestamp': timestamp,
        'error': error,
        'userId': userId,
      };
      
      final existingLogs = await getErrorLogs();
      existingLogs.add(errorLog);
      
      // Keep only last 100 errors
      if (existingLogs.length > 100) {
        existingLogs.removeRange(0, existingLogs.length - 100);
      }
      
      await _secureStorage.write(
        key: 'error_logs',
        value: jsonEncode(existingLogs),
      );
    } catch (e) {
      // Ignore errors in error logging to prevent infinite loops
    }
  }

  Future<List<Map<String, dynamic>>> getErrorLogs() async {
    try {
      final jsonString = await _secureStorage.read(key: 'error_logs');
      if (jsonString == null) return [];
      
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearErrorLogs() async {
    try {
      await _secureStorage.delete(key: 'error_logs');
    } catch (e) {
      // Ignore errors in clearing error logs
    }
  }
}