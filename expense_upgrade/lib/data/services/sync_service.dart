import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../core/errors/exceptions.dart';
import 'local_storage_service.dart';
import 'firestore_service.dart';

class SyncService {
  final LocalStorageService _localStorageService;
  final FirestoreService _firestoreService;
  final Connectivity _connectivity;
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _syncTimer;
  
  SyncService({
    required LocalStorageService localStorageService,
    required FirestoreService firestoreService,
    Connectivity? connectivity,
  }) : _localStorageService = localStorageService,
       _firestoreService = firestoreService,
       _connectivity = connectivity ?? Connectivity();

  /// Initialize sync service and start monitoring connectivity
  void initialize() {
    _startConnectivityMonitoring();
    _startPeriodicSync();
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }

  /// Add transaction with offline support
  Future<void> addTransactionWithSync(String userId, Transaction transaction) async {
    try {
      final isConnected = await _localStorageService.isConnected();
      
      if (isConnected) {
        // Try to add directly to Firestore
        await _firestoreService.addTransaction(transaction);
        
        // Update local cache
        final cachedTransactions = await _localStorageService.getCachedTransactions(userId) ?? [];
        cachedTransactions.add(transaction);
        await _localStorageService.cacheTransactions(userId, cachedTransactions);
      } else {
        // Save to pending transactions for later sync
        await _localStorageService.savePendingTransaction(userId, transaction);
        
        // Update local cache immediately for UI
        final cachedTransactions = await _localStorageService.getCachedTransactions(userId) ?? [];
        cachedTransactions.add(transaction);
        await _localStorageService.cacheTransactions(userId, cachedTransactions);
      }
    } catch (e) {
      await _localStorageService.logError('Failed to add transaction: $e', userId: userId);
      
      // Fallback to offline storage
      await _localStorageService.savePendingTransaction(userId, transaction);
      
      // Update local cache
      final cachedTransactions = await _localStorageService.getCachedTransactions(userId) ?? [];
      cachedTransactions.add(transaction);
      await _localStorageService.cacheTransactions(userId, cachedTransactions);
      
      rethrow;
    }
  }

  /// Update transaction with offline support
  Future<void> updateTransactionWithSync(String userId, Transaction transaction) async {
    try {
      final isConnected = await _localStorageService.isConnected();
      
      if (isConnected) {
        // Try to update directly in Firestore
        await _firestoreService.updateTransaction(transaction);
        
        // Update local cache
        await _updateTransactionInCache(userId, transaction);
      } else {
        // Save to pending transactions for later sync
        await _localStorageService.savePendingTransaction(userId, transaction);
        
        // Update local cache immediately for UI
        await _updateTransactionInCache(userId, transaction);
      }
    } catch (e) {
      await _localStorageService.logError('Failed to update transaction: $e', userId: userId);
      
      // Fallback to offline storage
      await _localStorageService.savePendingTransaction(userId, transaction);
      await _updateTransactionInCache(userId, transaction);
      
      rethrow;
    }
  }

  /// Delete transaction with offline support
  Future<void> deleteTransactionWithSync(String userId, String transactionId) async {
    try {
      final isConnected = await _localStorageService.isConnected();
      
      if (isConnected) {
        // Try to delete directly from Firestore
        await _firestoreService.deleteTransaction(transactionId, userId);
        
        // Update local cache
        await _removeTransactionFromCache(userId, transactionId);
      } else {
        // Mark for deletion in pending operations
        final deletionMarker = Transaction(
          id: transactionId,
          amount: 0,
          description: '__DELETED__',
          category: '__DELETED__',
          date: DateTime.now(),
          userId: userId,
          createdAt: DateTime.now(),
        );
        
        await _localStorageService.savePendingTransaction(userId, deletionMarker);
        
        // Remove from local cache immediately for UI
        await _removeTransactionFromCache(userId, transactionId);
      }
    } catch (e) {
      await _localStorageService.logError('Failed to delete transaction: $e', userId: userId);
      rethrow;
    }
  }

  /// Sync pending transactions when connection is restored
  Future<void> syncPendingTransactions(String userId) async {
    try {
      final isConnected = await _localStorageService.isConnected();
      if (!isConnected) return;

      final pendingTransactions = await _localStorageService.getPendingTransactions(userId);
      if (pendingTransactions.isEmpty) return;

      final List<Transaction> successfullysynced = [];

      for (final transaction in pendingTransactions) {
        try {
          if (transaction.description == '__DELETED__') {
            // Handle deletion
            await _firestoreService.deleteTransaction(transaction.id, userId);
          } else if (transaction.createdAt.isBefore(DateTime.now().subtract(const Duration(minutes: 1)))) {
            // Handle update (if transaction is older than 1 minute, assume it's an update)
            await _firestoreService.updateTransaction(transaction);
          } else {
            // Handle addition
            await _firestoreService.addTransaction(transaction);
          }
          
          successfullysynced.add(transaction);
        } catch (e) {
          await _localStorageService.logError('Failed to sync transaction ${transaction.id}: $e', userId: userId);
          // Continue with other transactions
        }
      }

      // Remove successfully synced transactions from pending list
      if (successfullysynced.isNotEmpty) {
        final remainingPending = pendingTransactions
            .where((t) => !successfullysynced.contains(t))
            .toList();
        
        if (remainingPending.isEmpty) {
          await _localStorageService.clearPendingTransactions(userId);
        } else {
          // Save remaining pending transactions
          await _localStorageService.clearPendingTransactions(userId);
          for (final transaction in remainingPending) {
            await _localStorageService.savePendingTransaction(userId, transaction);
          }
        }
      }

      // Update last sync time
      await _localStorageService.saveLastSyncTime(userId, DateTime.now());
      
    } catch (e) {
      await _localStorageService.logError('Failed to sync pending transactions: $e', userId: userId);
      throw SyncException('Không thể đồng bộ dữ liệu: ${e.toString()}');
    }
  }

  /// Get sync status
  Future<SyncStatus> getSyncStatus(String userId) async {
    try {
      final isConnected = await _localStorageService.isConnected();
      final pendingTransactions = await _localStorageService.getPendingTransactions(userId);
      final lastSyncTime = await _localStorageService.getLastSyncTime(userId);
      
      return SyncStatus(
        isConnected: isConnected,
        pendingTransactionsCount: pendingTransactions.length,
        lastSyncTime: lastSyncTime,
        hasPendingChanges: pendingTransactions.isNotEmpty,
      );
    } catch (e) {
      await _localStorageService.logError('Failed to get sync status: $e', userId: userId);
      return SyncStatus(
        isConnected: false,
        pendingTransactionsCount: 0,
        lastSyncTime: null,
        hasPendingChanges: false,
      );
    }
  }

  void _startConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (results.isNotEmpty && results.first != ConnectivityResult.none) {
          // Connection restored, trigger sync for all users
          _triggerSyncForAllUsers();
        }
      },
    );
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _triggerSyncForAllUsers();
    });
  }

  Future<void> _triggerSyncForAllUsers() async {
    // This is a simplified version - in a real app, you'd need to track active users
    // For now, we'll need the userId to be passed when calling sync methods
  }

  Future<void> _updateTransactionInCache(String userId, Transaction transaction) async {
    final cachedTransactions = await _localStorageService.getCachedTransactions(userId) ?? [];
    final index = cachedTransactions.indexWhere((t) => t.id == transaction.id);
    
    if (index != -1) {
      cachedTransactions[index] = transaction;
      await _localStorageService.cacheTransactions(userId, cachedTransactions);
    }
  }

  Future<void> _removeTransactionFromCache(String userId, String transactionId) async {
    final cachedTransactions = await _localStorageService.getCachedTransactions(userId) ?? [];
    cachedTransactions.removeWhere((t) => t.id == transactionId);
    await _localStorageService.cacheTransactions(userId, cachedTransactions);
  }
}

class SyncStatus {
  final bool isConnected;
  final int pendingTransactionsCount;
  final DateTime? lastSyncTime;
  final bool hasPendingChanges;

  SyncStatus({
    required this.isConnected,
    required this.pendingTransactionsCount,
    required this.lastSyncTime,
    required this.hasPendingChanges,
  });
}

class SyncException extends AppException {
  const SyncException(String message) : super(message);
}