import '../../domain/entities/expense_category.dart';
import '../../domain/repositories/category_repository.dart';
import '../services/category_service.dart';
import '../services/local_storage_service.dart';
import '../../core/errors/exceptions.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryService _categoryService;
  final LocalStorageService _localStorageService;
  
  CategoryRepositoryImpl({
    required CategoryService categoryService,
    required LocalStorageService localStorageService,
  }) : _categoryService = categoryService,
       _localStorageService = localStorageService;
  
  @override
  Future<List<ExpenseCategory>> getCategories(String userId) async {
    try {
      final isConnected = await _localStorageService.isConnected();
      
      if (isConnected) {
        // Get from Firestore and cache the result
        final categories = await _categoryService.getCategories(userId);
        
        // Update cache with fresh data
        await _localStorageService.cacheCategories(userId, categories);
        
        return categories;
      } else {
        // Get from cache when offline
        final cachedCategories = await _localStorageService.getCachedCategories(userId);
        if (cachedCategories == null) {
          // Return default categories if no cache available
          return await _categoryService.getDefaultCategories();
        }
        
        return cachedCategories;
      }
    } catch (e) {
      throw FirestoreException('Không thể lấy danh sách danh mục: ${e.toString()}');
    }
  }
  
  @override
  Future<void> addCategory(ExpenseCategory category, String userId) async {
    try {
      final isConnected = await _localStorageService.isConnected();
      
      if (isConnected) {
        // Add to Firestore
        await _categoryService.addCategory(category, userId);
        
        // Update cache
        final cachedCategories = await _localStorageService.getCachedCategories(userId) ?? [];
        cachedCategories.add(category);
        await _localStorageService.cacheCategories(userId, cachedCategories);
      } else {
        // For offline mode, we'll just update the cache
        // In a more sophisticated implementation, you might want to queue this operation
        final cachedCategories = await _localStorageService.getCachedCategories(userId) ?? [];
        cachedCategories.add(category);
        await _localStorageService.cacheCategories(userId, cachedCategories);
        
        // Log for potential future sync
        await _localStorageService.logError(
          'Category added offline: ${category.name}',
          userId: userId,
        );
      }
    } catch (e) {
      throw FirestoreException('Không thể thêm danh mục: ${e.toString()}');
    }
  }
  
  @override
  Future<void> updateCategory(ExpenseCategory category, String userId) async {
    try {
      final isConnected = await _localStorageService.isConnected();
      
      if (isConnected) {
        // Update in Firestore
        await _categoryService.updateCategory(category, userId);
        
        // Update cache
        await _updateCategoryInCache(userId, category);
      } else {
        // For offline mode, just update the cache
        await _updateCategoryInCache(userId, category);
        
        // Log for potential future sync
        await _localStorageService.logError(
          'Category updated offline: ${category.name}',
          userId: userId,
        );
      }
    } catch (e) {
      throw FirestoreException('Không thể cập nhật danh mục: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteCategory(String categoryId, String userId) async {
    try {
      final isConnected = await _localStorageService.isConnected();
      
      if (isConnected) {
        // Delete from Firestore
        await _categoryService.deleteCategory(categoryId, userId);
        
        // Remove from cache
        await _removeCategoryFromCache(userId, categoryId);
      } else {
        // For offline mode, just remove from cache
        await _removeCategoryFromCache(userId, categoryId);
        
        // Log for potential future sync
        await _localStorageService.logError(
          'Category deleted offline: $categoryId',
          userId: userId,
        );
      }
    } catch (e) {
      throw FirestoreException('Không thể xóa danh mục: ${e.toString()}');
    }
  }
  
  @override
  Future<List<ExpenseCategory>> getDefaultCategories() async {
    try {
      return await _categoryService.getDefaultCategories();
    } catch (e) {
      throw FirestoreException('Không thể lấy danh mục mặc định: ${e.toString()}');
    }
  }
  
  /// Get cached categories for offline access
  Future<List<ExpenseCategory>?> getCachedCategories(String userId) async {
    try {
      return await _localStorageService.getCachedCategories(userId);
    } catch (e) {
      throw CacheException('Không thể lấy danh mục từ cache: ${e.toString()}');
    }
  }
  
  /// Clear category cache
  Future<void> clearCategoryCache(String userId) async {
    try {
      // This would need to be implemented in LocalStorageService
      // For now, we'll clear all user cache
      await _localStorageService.clearUserCache(userId);
    } catch (e) {
      throw CacheException('Không thể xóa cache danh mục: ${e.toString()}');
    }
  }
  
  Future<void> _updateCategoryInCache(String userId, ExpenseCategory category) async {
    final cachedCategories = await _localStorageService.getCachedCategories(userId) ?? [];
    final index = cachedCategories.indexWhere((c) => c.id == category.id);
    
    if (index != -1) {
      cachedCategories[index] = category;
      await _localStorageService.cacheCategories(userId, cachedCategories);
    }
  }
  
  Future<void> _removeCategoryFromCache(String userId, String categoryId) async {
    final cachedCategories = await _localStorageService.getCachedCategories(userId) ?? [];
    cachedCategories.removeWhere((c) => c.id == categoryId);
    await _localStorageService.cacheCategories(userId, cachedCategories);
  }
}