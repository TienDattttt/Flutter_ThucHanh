import '../constants/app_constants.dart';
import 'string_utils.dart';

class Validators {
  static String? validateEmail(String? email) {
    if (StringUtils.isNullOrEmpty(email)) {
      return 'Email không được để trống';
    }
    
    if (!StringUtils.isValidEmail(email!)) {
      return 'Email không hợp lệ';
    }
    
    return null;
  }

  static String? validatePassword(String? password) {
    if (StringUtils.isNullOrEmpty(password)) {
      return 'Mật khẩu không được để trống';
    }
    
    if (password!.length < AppConstants.minPasswordLength) {
      return 'Mật khẩu phải có ít nhất ${AppConstants.minPasswordLength} ký tự';
    }
    
    if (password.length > AppConstants.maxPasswordLength) {
      return 'Mật khẩu không được vượt quá ${AppConstants.maxPasswordLength} ký tự';
    }
    
    return null;
  }

  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (StringUtils.isNullOrEmpty(confirmPassword)) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    
    if (password != confirmPassword) {
      return 'Mật khẩu xác nhận không khớp';
    }
    
    return null;
  }

  static String? validateDisplayName(String? displayName) {
    if (StringUtils.isNullOrEmpty(displayName)) {
      return 'Tên hiển thị không được để trống';
    }
    
    final trimmed = displayName!.trim();
    
    if (trimmed.length < AppConstants.minDisplayNameLength) {
      return 'Tên hiển thị phải có ít nhất ${AppConstants.minDisplayNameLength} ký tự';
    }
    
    if (trimmed.length > AppConstants.maxDisplayNameLength) {
      return 'Tên hiển thị không được vượt quá ${AppConstants.maxDisplayNameLength} ký tự';
    }
    
    return null;
  }

  static String? validateReviewComment(String? comment) {
    if (StringUtils.isNullOrEmpty(comment)) {
      return 'Nội dung đánh giá không được để trống';
    }
    
    final trimmed = comment!.trim();
    
    if (trimmed.length < AppConstants.minReviewLength) {
      return 'Nội dung đánh giá phải có ít nhất ${AppConstants.minReviewLength} ký tự';
    }
    
    if (trimmed.length > AppConstants.maxReviewLength) {
      return 'Nội dung đánh giá không được vượt quá ${AppConstants.maxReviewLength} ký tự';
    }
    
    return null;
  }

  static String? validateRating(int? rating) {
    if (rating == null) {
      return 'Vui lòng chọn số sao đánh giá';
    }
    
    if (rating < AppConstants.minRating || rating > AppConstants.maxRating) {
      return 'Đánh giá phải từ ${AppConstants.minRating} đến ${AppConstants.maxRating} sao';
    }
    
    return null;
  }

  static String? validateRestaurantName(String? name) {
    if (StringUtils.isNullOrEmpty(name)) {
      return 'Tên nhà hàng không được để trống';
    }
    
    final trimmed = name!.trim();
    
    if (trimmed.length < AppConstants.minRestaurantNameLength) {
      return 'Tên nhà hàng phải có ít nhất ${AppConstants.minRestaurantNameLength} ký tự';
    }
    
    if (trimmed.length > AppConstants.maxRestaurantNameLength) {
      return 'Tên nhà hàng không được vượt quá ${AppConstants.maxRestaurantNameLength} ký tự';
    }
    
    return null;
  }

  static String? validateAddress(String? address) {
    if (StringUtils.isNullOrEmpty(address)) {
      return 'Địa chỉ không được để trống';
    }
    
    final trimmed = address!.trim();
    
    if (trimmed.length < AppConstants.minAddressLength) {
      return 'Địa chỉ phải có ít nhất ${AppConstants.minAddressLength} ký tự';
    }
    
    if (trimmed.length > AppConstants.maxAddressLength) {
      return 'Địa chỉ không được vượt quá ${AppConstants.maxAddressLength} ký tự';
    }
    
    return null;
  }

  static String? validatePhoneNumber(String? phoneNumber) {
    if (StringUtils.isNullOrEmpty(phoneNumber)) {
      return null; // Phone number is optional
    }
    
    if (!StringUtils.isValidPhoneNumber(phoneNumber!)) {
      return 'Số điện thoại không hợp lệ';
    }
    
    return null;
  }

  static String? validateWebsite(String? website) {
    if (StringUtils.isNullOrEmpty(website)) {
      return null; // Website is optional
    }
    
    if (!StringUtils.isValidUrl(website!)) {
      return 'Website không hợp lệ';
    }
    
    return null;
  }

  static String? validateLatitude(double? latitude) {
    if (latitude == null) {
      return 'Vĩ độ không được để trống';
    }
    
    if (latitude < -90 || latitude > 90) {
      return 'Vĩ độ phải từ -90 đến 90';
    }
    
    return null;
  }

  static String? validateLongitude(double? longitude) {
    if (longitude == null) {
      return 'Kinh độ không được để trống';
    }
    
    if (longitude < -180 || longitude > 180) {
      return 'Kinh độ phải từ -180 đến 180';
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (StringUtils.isNullOrEmpty(value)) {
      return '$fieldName không được để trống';
    }
    
    return null;
  }

  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (StringUtils.isNullOrEmpty(value)) {
      return null; // Let validateRequired handle empty values
    }
    
    if (value!.trim().length < minLength) {
      return '$fieldName phải có ít nhất $minLength ký tự';
    }
    
    return null;
  }

  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (StringUtils.isNullOrEmpty(value)) {
      return null; // Let validateRequired handle empty values
    }
    
    if (value!.length > maxLength) {
      return '$fieldName không được vượt quá $maxLength ký tự';
    }
    
    return null;
  }

  static String? validateRange(int? value, int min, int max, String fieldName) {
    if (value == null) {
      return '$fieldName không được để trống';
    }
    
    if (value < min || value > max) {
      return '$fieldName phải từ $min đến $max';
    }
    
    return null;
  }

  /// Combine multiple validators
  static String? validateMultiple(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}