import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isInitialized = false;

  /// Initialize Firestore with performance optimizations
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure cache settings
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      _isInitialized = true;
      print('Firestore initialized with offline persistence');
    } catch (e) {
      print('Error initializing Firestore: $e');
      // Continue without offline persistence if it fails
      _isInitialized = true;
    }
  }

  /// Get Firestore instance
  FirebaseFirestore get instance => _firestore;

  /// Create optimized query for restaurants
  Query<Map<String, dynamic>> getRestaurantsQuery({
    String? category,
    double? minRating,
    String? searchQuery,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(AppConstants.restaurantsCollection)
        .where('isActive', isEqualTo: true);

    // Apply category filter
    if (category != null && category.isNotEmpty) {
      query = query.where('categories', arrayContains: category);
    }

    // Apply minimum rating filter
    if (minRating != null && minRating > 0) {
      query = query.where('averageRating', isGreaterThanOrEqualTo: minRating);
    }

    // Apply ordering
    if (searchQuery == null || searchQuery.isEmpty) {
      query = query.orderBy('averageRating', descending: true);
    } else {
      query = query.orderBy('name');
    }

    // Apply limit
    if (limit != null && limit > 0) {
      query = query.limit(limit);
    }

    return query;
  }

  /// Create optimized query for reviews
  Query<Map<String, dynamic>> getReviewsQuery({
    required String restaurantId,
    String? orderBy,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(AppConstants.reviewsCollection)
        .where('restaurantId', isEqualTo: restaurantId);

    // Apply ordering
    switch (orderBy) {
      case AppConstants.orderByNewest:
        query = query.orderBy('createdAt', descending: true);
        break;
      case AppConstants.orderByOldest:
        query = query.orderBy('createdAt', descending: false);
        break;
      case AppConstants.orderByRatingDesc:
        query = query.orderBy('rating', descending: true);
        break;
      case AppConstants.orderByRatingAsc:
        query = query.orderBy('rating', descending: false);
        break;
      case AppConstants.orderByHelpful:
        query = query.orderBy('helpfulCount', descending: true);
        break;
      default:
        query = query.orderBy('createdAt', descending: true);
    }

    // Apply limit
    if (limit != null && limit > 0) {
      query = query.limit(limit);
    }

    return query;
  }

  /// Create optimized query for user notifications
  Query<Map<String, dynamic>> getUserNotificationsQuery({
    required String userId,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    // Apply limit
    if (limit != null && limit > 0) {
      query = query.limit(limit);
    }

    return query;
  }

  /// Batch write operations for better performance
  WriteBatch createBatch() {
    return _firestore.batch();
  }

  /// Execute batch operations
  Future<void> commitBatch(WriteBatch batch) async {
    await batch.commit();
  }

  /// Clear offline cache
  Future<void> clearPersistence() async {
    try {
      await _firestore.clearPersistence();
      print('Firestore cache cleared');
    } catch (e) {
      print('Error clearing Firestore cache: $e');
    }
  }

  /// Disable network (for testing offline functionality)
  Future<void> disableNetwork() async {
    try {
      await _firestore.disableNetwork();
      print('Firestore network disabled');
    } catch (e) {
      print('Error disabling Firestore network: $e');
    }
  }

  /// Enable network
  Future<void> enableNetwork() async {
    try {
      await _firestore.enableNetwork();
      print('Firestore network enabled');
    } catch (e) {
      print('Error enabling Firestore network: $e');
    }
  }

  /// Get cache size
  Future<int> getCacheSize() async {
    try {
      // This is an approximation since Firestore doesn't provide direct cache size API
      return 0; // Placeholder
    } catch (e) {
      print('Error getting cache size: $e');
      return 0;
    }
  }

  /// Preload critical data
  Future<void> preloadCriticalData() async {
    try {
      // Preload restaurant categories
      await _firestore
          .collection(AppConstants.categoriesCollection)
          .get(const GetOptions(source: Source.cache));

      // Preload top restaurants
      await _firestore
          .collection(AppConstants.restaurantsCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('averageRating', descending: true)
          .limit(10)
          .get(const GetOptions(source: Source.cache));

      print('Critical data preloaded');
    } catch (e) {
      print('Error preloading critical data: $e');
    }
  }

  /// Setup compound indexes (for documentation purposes)
  /// These need to be created in Firebase Console or via Firebase CLI
  static const List<Map<String, dynamic>> requiredIndexes = [
    {
      'collection': 'restaurants',
      'fields': [
        {'field': 'isActive', 'order': 'ASCENDING'},
        {'field': 'categories', 'arrayConfig': 'CONTAINS'},
        {'field': 'averageRating', 'order': 'DESCENDING'},
      ],
    },
    {
      'collection': 'restaurants',
      'fields': [
        {'field': 'isActive', 'order': 'ASCENDING'},
        {'field': 'averageRating', 'order': 'DESCENDING'},
      ],
    },
    {
      'collection': 'restaurants',
      'fields': [
        {'field': 'isActive', 'order': 'ASCENDING'},
        {'field': 'name', 'order': 'ASCENDING'},
      ],
    },
    {
      'collection': 'reviews',
      'fields': [
        {'field': 'restaurantId', 'order': 'ASCENDING'},
        {'field': 'createdAt', 'order': 'DESCENDING'},
      ],
    },
    {
      'collection': 'reviews',
      'fields': [
        {'field': 'restaurantId', 'order': 'ASCENDING'},
        {'field': 'rating', 'order': 'DESCENDING'},
      ],
    },
    {
      'collection': 'reviews',
      'fields': [
        {'field': 'restaurantId', 'order': 'ASCENDING'},
        {'field': 'helpfulCount', 'order': 'DESCENDING'},
      ],
    },
    {
      'collection': 'notifications',
      'fields': [
        {'field': 'userId', 'order': 'ASCENDING'},
        {'field': 'createdAt', 'order': 'DESCENDING'},
      ],
    },
    {
      'collection': 'notifications',
      'fields': [
        {'field': 'userId', 'order': 'ASCENDING'},
        {'field': 'isRead', 'order': 'ASCENDING'},
      ],
    },
  ];
}