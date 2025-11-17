import '../constants/app_constants.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    
    return null;
  }
  
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số tiền không được để trống';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Số tiền không hợp lệ';
    }
    
    if (amount < AppConstants.minTransactionAmount) {
      return 'Số tiền phải lớn hơn ${AppConstants.minTransactionAmount}';
    }
    
    if (amount > AppConstants.maxTransactionAmount) {
      return 'Số tiền không được vượt quá ${AppConstants.maxTransactionAmount}';
    }
    
    return null;
  }
  
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mô tả không được để trống';
    }
    
    if (value.length > AppConstants.maxDescriptionLength) {
      return 'Mô tả không được vượt quá ${AppConstants.maxDescriptionLength} ký tự';
    }
    
    return null;
  }
  
  static String? validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tên hiển thị không được để trống';
    }
    
    if (value.length < 2) {
      return 'Tên hiển thị phải có ít nhất 2 ký tự';
    }
    
    return null;
  }
}