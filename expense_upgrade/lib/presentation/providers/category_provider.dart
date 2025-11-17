import 'package:flutter/foundation.dart';
import '../../domain/entities/expense_category.dart';
import '../../domain/usecases/category_usecase.dart';
import '../../core/errors/exceptions.dart';
import 'auth_provider.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryUseCase _categoryUseCase;
  final AuthProvider _authProvider;
  
  CategoryProvider({
    required CategoryUseCase categoryUseCase,
    required AuthProvider authProvider,
  }) : _categoryUseCase = categoryUseCase,
       _authProvider = authProvider;
  
  List<ExpenseCategory> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<ExpenseCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  String? get _currentUserId => _authProvider.user?.id;
  
  Future<void> loadCategories() async {
    if (_currentUserId == null) return;
    
    try {
      _setLoading(true);
      _categories = await _categoryUseCase.getCategories(_currentUserId!);
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> addCategory(ExpenseCategory category) async {
    if (_currentUserId == null) {
      throw const AuthException('Người dùng chưa đăng nhập');
    }
    
    try {
      _setLoading(true);
      await _categoryUseCase.addCategory(category, _currentUserId!);
      await loadCategories(); // Reload to get updated list
      _clearError();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> updateCategory(ExpenseCategory category) async {
    if (_currentUserId == null) {
      throw const AuthException('Người dùng chưa đăng nhập');
    }
    
    try {
      _setLoading(true);
      await _categoryUseCase.updateCategory(category, _currentUserId!);
      await loadCategories(); // Reload to get updated list
      _clearError();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> deleteCategory(String categoryId) async {
    if (_currentUserId == null) {
      throw const AuthException('Người dùng chưa đăng nhập');
    }
    
    try {
      _setLoading(true);
      await _categoryUseCase.deleteCategory(categoryId, _currentUserId!);
      await loadCategories(); // Reload to get updated list
      _clearError();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  ExpenseCategory? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
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
}