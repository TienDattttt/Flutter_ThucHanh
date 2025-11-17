import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense_category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../core/errors/exceptions.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/default_categories.dart';
import '../models/expense_category_model.dart';

class CategoryService implements CategoryRepository {
  final FirebaseFirestore _firestore;
  
  CategoryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  @override
  Future<List<ExpenseCategory>> getCategories(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.categoriesCollection)
          .get();
      
      if (snapshot.docs.isEmpty) {
        // Nếu user chưa có categories, tạo default categories
        await _initializeDefaultCategories(userId);
        return DefaultCategories.categories;
      }
      
      return snapshot.docs
          .map((doc) => ExpenseCategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirestoreException('Không thể lấy danh sách danh mục: ${e.toString()}');
    }
  }
  
  @override
  Future<void> addCategory(ExpenseCategory category, String userId) async {
    try {
      final categoryModel = ExpenseCategoryModel.fromEntity(category);
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.categoriesCollection)
          .doc(category.id)
          .set(categoryModel.toFirestore());
    } catch (e) {
      throw FirestoreException('Không thể thêm danh mục: ${e.toString()}');
    }
  }
  
  @override
  Future<void> updateCategory(ExpenseCategory category, String userId) async {
    try {
      final categoryModel = ExpenseCategoryModel.fromEntity(category);
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.categoriesCollection)
          .doc(category.id)
          .update(categoryModel.toFirestore());
    } catch (e) {
      throw FirestoreException('Không thể cập nhật danh mục: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteCategory(String categoryId, String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .delete();
    } catch (e) {
      throw FirestoreException('Không thể xóa danh mục: ${e.toString()}');
    }
  }
  
  @override
  Future<List<ExpenseCategory>> getDefaultCategories() async {
    return DefaultCategories.categories;
  }
  
  Future<void> _initializeDefaultCategories(String userId) async {
    try {
      final batch = _firestore.batch();
      
      for (final category in DefaultCategories.categories) {
        final categoryModel = ExpenseCategoryModel.fromEntity(category);
        final docRef = _firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .collection(AppConstants.categoriesCollection)
            .doc(category.id);
        
        batch.set(docRef, categoryModel.toFirestore());
      }
      
      await batch.commit();
    } catch (e) {
      throw FirestoreException('Không thể khởi tạo danh mục mặc định: ${e.toString()}');
    }
  }
}