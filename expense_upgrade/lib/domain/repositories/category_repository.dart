import '../entities/expense_category.dart';

abstract class CategoryRepository {
  Future<List<ExpenseCategory>> getCategories(String userId);
  Future<void> addCategory(ExpenseCategory category, String userId);
  Future<void> updateCategory(ExpenseCategory category, String userId);
  Future<void> deleteCategory(String categoryId, String userId);
  Future<List<ExpenseCategory>> getDefaultCategories();
}