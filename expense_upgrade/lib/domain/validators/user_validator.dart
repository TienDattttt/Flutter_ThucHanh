import '../entities/user.dart';
import '../../core/errors/exceptions.dart';

class UserValidator {
  static void validateUser(User user) {
    _validateEmail(user.email);
    _validateDisplayName(user.displayName);
    _validateId(user.id);
  }
  
  static void _validateEmail(String email) {
    if (email.isEmpty) {
      throw const ValidationException('Email không được để trống');
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      throw const ValidationException('Email không hợp lệ');
    }
  }
  
  static void _validateDisplayName(String displayName) {
    if (displayName.isEmpty) {
      throw const ValidationException('Tên hiển thị không được để trống');
    }
    
    if (displayName.length < 2) {
      throw const ValidationException('Tên hiển thị phải có ít nhất 2 ký tự');
    }
    
    if (displayName.length > 50) {
      throw const ValidationException('Tên hiển thị không được vượt quá 50 ký tự');
    }
  }
  
  static void _validateId(String id) {
    if (id.isEmpty) {
      throw const ValidationException('User ID không được để trống');
    }
  }
}