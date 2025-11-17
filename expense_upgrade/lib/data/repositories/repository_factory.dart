import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/category_repository.dart';

import '../services/firestore_service.dart';
import '../services/category_service.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';

import '../datasources/transaction_remote_datasource.dart';
import '../datasources/transaction_local_datasource.dart';

import 'transaction_repository_impl.dart';
import 'category_repository_impl.dart';

/// Factory class to create and manage repository instances
/// Implements singleton pattern to ensure consistent dependencies
class RepositoryFactory {
  static RepositoryFactory? _instance;
  
  // Core services
  late final FirebaseFirestore _firestore;
  late final FlutterSecureStorage _secureStorage;
  late final Connectivity _connectivity;
  
  // Data sources
  late final TransactionRemoteDataSource _transactionRemoteDataSource;
  late final TransactionLocalDataSource _transactionLocalDataSource;
  
  // Services
  late final FirestoreService _firestoreService;
  late final CategoryService _categoryService;
  late final LocalStorageService _localStorageService;
  late final SyncService _syncService;
  
  // Repositories
  TransactionRepository? _transactionRepository;
  CategoryRepository? _categoryRepository;
  
  RepositoryFactory._internal() {
    _initializeServices();
  }
  
  static RepositoryFactory get instance {
    _instance ??= RepositoryFactory._internal();
    return _instance!;
  }
  
  void _initializeServices() {
    // Initialize core services
    _firestore = FirebaseFirestore.instance;
    _secureStorage = const FlutterSecureStorage();
    _connectivity = Connectivity();
    
    // Initialize data sources
    _transactionRemoteDataSource = FirestoreTransactionDataSource(firestore: _firestore);
    _transactionLocalDataSource = SecureStorageTransactionDataSource(secureStorage: _secureStorage);
    
    // Initialize services
    _firestoreService = FirestoreService(firestore: _firestore);
    _categoryService = CategoryService(firestore: _firestore);
    _localStorageService = LocalStorageService(
      secureStorage: _secureStorage,
      connectivity: _connectivity,
    );
    
    _syncService = SyncService(
      localStorageService: _localStorageService,
      firestoreService: _firestoreService,
      connectivity: _connectivity,
    );
    
    // Initialize sync service
    _syncService.initialize();
  }
  
  /// Get transaction repository instance
  TransactionRepository get transactionRepository {
    _transactionRepository ??= TransactionRepositoryImpl(
      firestoreService: _firestoreService,
      localStorageService: _localStorageService,
      syncService: _syncService,
    );
    return _transactionRepository!;
  }
  
  /// Get category repository instance
  CategoryRepository get categoryRepository {
    _categoryRepository ??= CategoryRepositoryImpl(
      categoryService: _categoryService,
      localStorageService: _localStorageService,
    );
    return _categoryRepository!;
  }
  
  /// Get sync service instance
  SyncService get syncService => _syncService;
  
  /// Get local storage service instance
  LocalStorageService get localStorageService => _localStorageService;
  
  /// Get transaction remote data source
  TransactionRemoteDataSource get transactionRemoteDataSource => _transactionRemoteDataSource;
  
  /// Get transaction local data source
  TransactionLocalDataSource get transactionLocalDataSource => _transactionLocalDataSource;
  
  /// Dispose all resources
  void dispose() {
    _syncService.dispose();
    _transactionRepository = null;
    _categoryRepository = null;
  }
  
  /// Reset factory (useful for testing)
  static void reset() {
    _instance?.dispose();
    _instance = null;
  }
  
  /// Create factory with custom dependencies (useful for testing)
  static RepositoryFactory createWithDependencies({
    FirebaseFirestore? firestore,
    FlutterSecureStorage? secureStorage,
    Connectivity? connectivity,
  }) {
    final factory = RepositoryFactory._internal();
    
    if (firestore != null) factory._firestore = firestore;
    if (secureStorage != null) factory._secureStorage = secureStorage;
    if (connectivity != null) factory._connectivity = connectivity;
    
    factory._initializeServices();
    return factory;
  }
}

/// Extension to provide easy access to repositories
extension RepositoryFactoryExtension on RepositoryFactory {
  /// Initialize all repositories and services
  Future<void> initializeAll() async {
    // Pre-initialize all repositories
    transactionRepository;
    categoryRepository;
    
    // Any additional initialization logic can go here
  }
  
  /// Check if all services are properly initialized
  bool get isInitialized {
    return _transactionRepository != null && _categoryRepository != null;
  }
  
  /// Get health status of all services
  Future<Map<String, bool>> getHealthStatus() async {
    final status = <String, bool>{};
    
    try {
      // Check Firestore connection
      await _firestore.enableNetwork();
      status['firestore'] = true;
    } catch (e) {
      status['firestore'] = false;
    }
    
    try {
      // Check local storage
      await _secureStorage.containsKey(key: 'health_check');
      status['localStorage'] = true;
    } catch (e) {
      status['localStorage'] = false;
    }
    
    try {
      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      status['connectivity'] = connectivityResult != ConnectivityResult.none;
    } catch (e) {
      status['connectivity'] = false;
    }
    
    return status;
  }
}