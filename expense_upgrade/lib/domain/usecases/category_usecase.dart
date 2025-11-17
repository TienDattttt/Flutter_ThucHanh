import '../entities/expense_category.dart';
import '../repositories/category_repository.dart';
import '../validators/category_validator.dart';
import '../../core/errors/exceptions.dart';

class CategoryUseCase {
  final CategoryRepository _categoryRepository;
  
  CategoryUseCase(this._categoryRepository);
  
  Future<List<ExpenseCategory>> getCategories(String userId) async {
    if (userId.isEmpty) {
      throw const ValidationException('User ID không được để trống');
    }
    
    return await _categoryRepository.getCategories(userId);
  }
  
  Future<void> addCategory(ExpenseCategory category, String userId) async {
    if (userId.isEmpty) {
      throw const ValidationException('User ID không được để trống');
    }
    
    CategoryValidator.validateCategory(category);
    return await _categoryRepository.addCategory(category, userId);
  }
  
  Future<void> updateCategory(ExpenseCategory category, String userId) async {
    if (userId.isEmpty) {
      throw const ValidationException('User ID không được để trống');
    }
    
    CategoryValidator.validateCategory(category);
    return await _categoryRepository.updateCategory(category, userId);
  }
  
  Future<void> deleteCategory(String categoryId, String userId) async {
    if (categoryId.isEmpty) {
      throw const ValidationException('Category ID không được để trống');
    }
    
    if (userId.isEmpty) {
      throw const ValidationException('User ID không được để trống');
    }
    
    return await _categoryRepository.deleteCategory(categoryId, userId);
  }
  
  Future<List<ExpenseCategory>> getDefaultCategories() async {
    return await _categoryRepository.getDefaultCategories();
  }
}