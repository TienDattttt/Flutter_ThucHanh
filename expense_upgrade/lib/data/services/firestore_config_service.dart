import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/exceptions.dart';
import '../../core/constants/app_constants.dart';

/// Service to handle Firestore configuration and initialization
class FirestoreConfigService {
  final FirebaseFirestore _firestore;
  
  FirestoreConfigService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  /// Initialize Firestore with optimal settings
  Future<void> initialize() async {
    try {
      // Enable offline persistence
      await _firestore.enablePersistence();
      
      // Configure cache size (100MB)
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: 100 * 1024 * 1024, // 100MB
      );
      
      // Enable network (in case it was disabled)
      await _firestore.enableNetwork();
      
    } catch (e) {
      // Persistence might already be enabled, which is fine
      if (!e.toString().contains('already enabled')) {
        throw FirestoreException('Không thể khởi tạo Firestore: ${e.toString()}');
      }
    }
  }
  
  /// Create user document with initial data
  Future<void> initializeUserDocument(String userId, Map<String, dynamic> userData) async {
    try {
      final userDocRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId);
      
      // Check if user document already exists
      final userDoc = await userDocRef.get();
      
      if (!userDoc.exists) {
        // Create user document with initial data
        await userDocRef.set({
          ...userData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Initialize default categories for the user
        await _initializeDefaultCategories(userId);
      }
    } catch (e) {
      throw FirestoreException('Không thể khởi tạo tài liệu người dùng: ${e.toString()}');
    }
  }
  
  /// Initialize default categories for a new user
  Future<void> _initializeDefaultCategories(String userId) async {
    try {
      final batch = _firestore.batch();
      
      final defaultCategories = [
        {
          'name': 'Ăn uống',
          'icon': 'restaurant',
          'color': '#FF5722',
          'isDefault': true,
        },
        {
          'name': 'Di chuyển',
          'icon': 'directions_car',
          'color': '#2196F3',
          'isDefault': true,
        },
        {
          'name': 'Mua sắm',
          'icon': 'shopping_cart',
          'color': '#4CAF50',
          'isDefault': true,
        },
        {
          'name': 'Giải trí',
          'icon': 'movie',
          'color': '#9C27B0',
          'isDefault': true,
        },
        {
          'name': 'Y tế',
          'icon': 'local_hospital',
          'color': '#F44336',
          'isDefault': true,
        },
        {
          'name': 'Giáo dục',
          'icon': 'school',
          'color': '#FF9800',
          'isDefault': true,
        },
        {
          'name': 'Khác',
          'icon': 'category',
          'color': '#607D8B',
          'isDefault': true,
        },
      ];
      
      for (final category in defaultCategories) {
        final categoryRef = _firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .collection(AppConstants.categoriesCollection)
            .doc();
        
        batch.set(categoryRef, {
          ...category,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw FirestoreException('Không thể khởi tạo danh mục mặc định: ${e.toString()}');
    }
  }
  
  /// Validate Firestore security rules (for development/testing)
  Future<bool> validateSecurityRules(String userId) async {
    try {
      // Test read access to user's own data
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      
      // Test write access to user's own data
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('test')
          .add({'test': true, 'timestamp': FieldValue.serverTimestamp()});
      
      // Clean up test document
      final testDocs = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('test')
          .get();
      
      for (final doc in testDocs.docs) {
        await doc.reference.delete();
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Get Firestore connection status
  Future<FirestoreConnectionStatus> getConnectionStatus() async {
    try {
      // Try to perform a simple read operation
      await _firestore
          .collection('system')
          .doc('health')
          .get(const GetOptions(source: Source.server));
      
      return FirestoreConnectionStatus.connected;
    } catch (e) {
      if (e.toString().contains('offline') || e.toString().contains('network')) {
        return FirestoreConnectionStatus.offline;
      }
      return FirestoreConnectionStatus.error;
    }
  }
  
  /// Enable offline mode
  Future<void> enableOfflineMode() async {
    try {
      await _firestore.disableNetwork();
    } catch (e) {
      throw FirestoreException('Không thể bật chế độ offline: ${e.toString()}');
    }
  }
  
  /// Enable online mode
  Future<void> enableOnlineMode() async {
    try {
      await _firestore.enableNetwork();
    } catch (e) {
      throw FirestoreException('Không thể bật chế độ online: ${e.toString()}');
    }
  }
  
  /// Clear offline cache
  Future<void> clearOfflineCache() async {
    try {
      await _firestore.clearPersistence();
    } catch (e) {
      throw FirestoreException('Không thể xóa cache offline: ${e.toString()}');
    }
  }
  
  /// Get cache size information
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      // This is a simplified version - actual implementation would need
      // platform-specific code to get accurate cache size
      return {
        'maxCacheSize': 100 * 1024 * 1024, // 100MB
        'estimatedCacheSize': 0, // Would need platform-specific implementation
        'persistenceEnabled': true,
      };
    } catch (e) {
      return {
        'maxCacheSize': 0,
        'estimatedCacheSize': 0,
        'persistenceEnabled': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Optimize Firestore queries for better performance
  void optimizeQueries() {
    // Enable query result caching
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 100 * 1024 * 1024,
    );
  }
  
  /// Create composite indexes programmatically (for development)
  /// Note: In production, indexes should be created via Firebase Console or CLI
  Future<void> createRequiredIndexes() async {
    // This is informational - actual indexes need to be created via Firebase Console
    final requiredIndexes = [
      {
        'collection': 'users/{userId}/transactions',
        'fields': [
          {'field': 'userId', 'order': 'ASCENDING'},
          {'field': 'date', 'order': 'DESCENDING'},
        ],
      },
      {
        'collection': 'users/{userId}/transactions',
        'fields': [
          {'field': 'userId', 'order': 'ASCENDING'},
          {'field': 'category', 'order': 'ASCENDING'},
          {'field': 'date', 'order': 'DESCENDING'},
        ],
      },
      {
        'collection': 'users/{userId}/transactions',
        'fields': [
          {'field': 'date', 'order': 'DESCENDING'},
          {'field': '__name__', 'order': 'DESCENDING'},
        ],
      },
    ];
    
    // Log required indexes for manual creation
    print('Required Firestore indexes:');
    for (final index in requiredIndexes) {
      print('Collection: ${index['collection']}');
      print('Fields: ${index['fields']}');
      print('---');
    }
  }
}

enum FirestoreConnectionStatus {
  connected,
  offline,
  error,
}