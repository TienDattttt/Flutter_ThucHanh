import '../entities/expense_category.dart';
import '../../core/errors/exceptions.dart';

class CategoryValidator {
  static void validateCategory(ExpenseCategory category) {
    _validateName(category.name);
    _validateIcon(category.icon);
    _validateId(category.id);
  }
  
  static void _validateName(String name) {
    if (name.isEmpty) {
      throw const ValidationException('Tên danh mục không được để trống');
    }
    
    if (name.length < 2) {
      throw const ValidationException('Tên danh mục phải có ít nhất 2 ký tự');
    }
    
    if (name.length > 30) {
      throw const ValidationException('Tên danh mục không được vượt quá 30 ký tự');
    }
  }
  
  static void _validateIcon(String icon) {
    if (icon.isEmpty) {
      throw const ValidationException('Icon danh mục không được để trống');
    }
  }
  
  static void _validateId(String id) {
    if (id.isEmpty) {
      throw const ValidationException('Category ID không được để trống');
    }
  }
}