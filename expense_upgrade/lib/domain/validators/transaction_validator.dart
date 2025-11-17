import '../entities/transaction.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';

class TransactionValidator {
  static void validateTransaction(Transaction transaction) {
    _validateAmount(transaction.amount);
    _validateDescription(transaction.description);
    _validateCategory(transaction.category);
    _validateDate(transaction.date);
    _validateUserId(transaction.userId);
  }
  
  static void _validateAmount(double amount) {
    if (amount <= 0) {
      throw const ValidationException('Số tiền phải lớn hơn 0');
    }
    
    if (amount < AppConstants.minTransactionAmount) {
      throw ValidationException(
        'Số tiền phải lớn hơn ${AppConstants.minTransactionAmount}',
      );
    }
    
    if (amount > AppConstants.maxTransactionAmount) {
      throw ValidationException(
        'Số tiền không được vượt quá ${AppConstants.maxTransactionAmount}',
      );
    }
  }
  
  static void _validateDescription(String description) {
    if (description.isEmpty) {
      throw const ValidationException('Mô tả không được để trống');
    }
    
    if (description.length > AppConstants.maxDescriptionLength) {
      throw ValidationException(
        'Mô tả không được vượt quá ${AppConstants.maxDescriptionLength} ký tự',
      );
    }
  }
  
  static void _validateCategory(String category) {
    if (category.isEmpty) {
      throw const ValidationException('Danh mục không được để trống');
    }
  }
  
  static void _validateDate(DateTime date) {
    final now = DateTime.now();
    final maxFutureDate = now.add(const Duration(days: 1));
    
    if (date.isAfter(maxFutureDate)) {
      throw const ValidationException('Ngày giao dịch không được quá xa trong tương lai');
    }
    
    final minDate = DateTime(2000, 1, 1);
    if (date.isBefore(minDate)) {
      throw const ValidationException('Ngày giao dịch không hợp lệ');
    }
  }
  
  static void _validateUserId(String userId) {
    if (userId.isEmpty) {
      throw const ValidationException('User ID không được để trống');
    }
  }
}