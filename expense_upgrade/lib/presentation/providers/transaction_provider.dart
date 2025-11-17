import 'package:flutter/foundation.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/transaction_usecase.dart';
import '../../core/errors/exceptions.dart';
import '../../data/services/sync_service.dart';
import '../../data/services/local_storage_service.dart';
import 'auth_provider.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionUseCase _transactionUseCase;
  final AuthProvider _authProvider;
  final SyncService _syncService;
  final LocalStorageService _localStorageService;
  
  TransactionProvider({
    required TransactionUseCase transactionUseCase,
    required AuthProvider authProvider,
    required SyncService syncService,
    required LocalStorageService localStorageService,
  }) : _transactionUseCase = transactionUseCase,
       _authProvider = authProvider,
       _syncService = syncService,
       _localStorageService = localStorageService;
  
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  bool _isInitialized = false;
  String? _errorMessage;
  Stream<List<Transaction>>? _transactionsStream;
  
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  bool get hasData => _isInitialized;
  String? get errorMessage => _errorMessage;
  Stream<List<Transaction>> get transactionsStream => 
      _transactionsStream ?? Stream.value([]);
  
  String? get _currentUserId => _authProvider.user?.id;
  
  Future<void> loadTransactions(String userId) async {
    try {
      // Only set loading if we don't have data yet
      if (_transactions.isEmpty) {
        _setLoading(true);
      }
      _hasMoreData = true;
      
      // Don't clear existing data to avoid flickering
      if (_transactionsStream == null) {
        _transactionsStream = _transactionUseCase.getTransactions(userId);
        _isInitialized = true;
        
        _transactionsStream!.listen(
          (transactions) {
            _transactions = transactions;
            _setLoading(false);
            notifyListeners();
          },
          onError: (error) {
            _setError(error.toString());
          },
        );
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadMoreTransactions(String userId, {int pageSize = 20}) async {
    if (_isLoadingMore || !_hasMoreData) return;
    
    try {
      _isLoadingMore = true;
      notifyListeners();
      
      final moreTransactions = await _transactionUseCase.getTransactionsPaginated(
        userId,
        limit: pageSize,
        startAfter: _transactions.isNotEmpty ? _transactions.last : null,
      );
      
      if (moreTransactions.length < pageSize) {
        _hasMoreData = false;
      }
      
      _transactions.addAll(moreTransactions);
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  
  Future<void> addTransaction(Transaction transaction) async {
    if (_currentUserId == null) {
      throw const AuthException('Người dùng chưa đăng nhập');
    }
    
    try {
      _setLoading(true);
      
      final newTransaction = transaction.copyWith(
        userId: _currentUserId!,
        createdAt: DateTime.now(),
      );
      
      // Use sync service for offline support
      await _syncService.addTransactionWithSync(_currentUserId!, newTransaction);
      _clearError();
    } catch (e) {
      await _localStorageService.logError('Add transaction failed: $e', userId: _currentUserId);
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> updateTransaction(Transaction transaction) async {
    if (_currentUserId == null) {
      throw const AuthException('Người dùng chưa đăng nhập');
    }
    
    try {
      _setLoading(true);
      
      final updatedTransaction = transaction.copyWith(
        userId: _currentUserId!,
      );
      
      // Use sync service for offline support
      await _syncService.updateTransactionWithSync(_currentUserId!, updatedTransaction);
      _clearError();
    } catch (e) {
      await _localStorageService.logError('Update transaction failed: $e', userId: _currentUserId);
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> deleteTransaction(String transactionId) async {
    if (_currentUserId == null) {
      throw const AuthException('Người dùng chưa đăng nhập');
    }
    
    try {
      _setLoading(true);
      
      // Use sync service for offline support
      await _syncService.deleteTransactionWithSync(_currentUserId!, transactionId);
      _clearError();
    } catch (e) {
      await _localStorageService.logError('Delete transaction failed: $e', userId: _currentUserId);
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    if (_currentUserId == null) {
      throw const AuthException('Người dùng chưa đăng nhập');
    }
    
    try {
      return await _transactionUseCase.getTransactionsByDateRange(
        _currentUserId!,
        start,
        end,
      );
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    _errorMessage = null;
    notifyListeners();
  }
  
  void _setError(String message) {
    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sync methods
  Future<void> syncPendingTransactions() async {
    if (_currentUserId == null) return;
    
    try {
      await _syncService.syncPendingTransactions(_currentUserId!);
      _clearError();
    } catch (e) {
      await _localStorageService.logError('Sync failed: $e', userId: _currentUserId);
      _setError('Đồng bộ thất bại: ${e.toString()}');
    }
  }

  Future<SyncStatus> getSyncStatus() async {
    if (_currentUserId == null) {
      return SyncStatus(
        isConnected: false,
        pendingTransactionsCount: 0,
        lastSyncTime: null,
        hasPendingChanges: false,
      );
    }
    
    return await _syncService.getSyncStatus(_currentUserId!);
  }

  // Load transactions with offline fallback
  Future<void> loadTransactionsWithFallback(String userId) async {
    try {
      _setLoading(true);
      
      final isConnected = await _localStorageService.isConnected();
      
      if (isConnected) {
        // Try to load from network first
        try {
          _transactionsStream = _transactionUseCase.getTransactions(userId);
          _transactionsStream!.listen(
            (transactions) {
              _transactions = transactions;
              // Cache the transactions
              _localStorageService.cacheTransactions(userId, transactions);
              _setLoading(false);
            },
            onError: (error) {
              _loadFromCache(userId);
            },
          );
        } catch (e) {
          // Fallback to cache
          await _loadFromCache(userId);
        }
      } else {
        // Load from cache when offline
        await _loadFromCache(userId);
      }
    } catch (e) {
      await _localStorageService.logError('Load transactions failed: $e', userId: userId);
      _setError(e.toString());
    }
  }

  Future<void> _loadFromCache(String userId) async {
    try {
      final cachedTransactions = await _localStorageService.getCachedTransactions(userId);
      if (cachedTransactions != null) {
        _transactions = cachedTransactions;
        _setLoading(false);
      } else {
        _setError('Không có dữ liệu offline');
      }
    } catch (e) {
      _setError('Không thể tải dữ liệu offline: ${e.toString()}');
    }
  }
}