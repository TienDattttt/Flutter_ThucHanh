class StringUtils {
  /// Check if string is null or empty
  static bool isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }

  /// Check if string is not null and not empty
  static bool isNotNullOrEmpty(String? value) {
    return !isNullOrEmpty(value);
  }

  /// Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (isNullOrEmpty(text)) return '';
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Capitalize first letter only
  static String capitalizeFirst(String text) {
    if (isNullOrEmpty(text)) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Remove extra whitespaces
  static String removeExtraSpaces(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }

  /// Generate initials from name
  static String getInitials(String name, {int maxInitials = 2}) {
    if (isNullOrEmpty(name)) return '';
    
    final words = name.trim().split(' ');
    final initials = words
        .take(maxInitials)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();
    
    return initials;
  }

  /// Format phone number
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length == 10) {
      // Format: 0123 456 789
      return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
    } else if (digits.length == 11) {
      // Format: 0123 456 7890
      return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
    }
    
    return phoneNumber; // Return original if format is not recognized
  }

  /// Mask email for privacy
  static String maskEmail(String email) {
    if (!email.contains('@')) return email;
    
    final parts = email.split('@');
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) {
      return '${username[0]}***@$domain';
    }
    
    final maskedUsername = '${username[0]}${'*' * (username.length - 2)}${username[username.length - 1]}';
    return '$maskedUsername@$domain';
  }

  /// Generate slug from text
  static String generateSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp(r'[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y')
        .replaceAll(RegExp(r'[đ]'), 'd')
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  /// Check if text contains only digits
  static bool isNumeric(String text) {
    return RegExp(r'^[0-9]+$').hasMatch(text);
  }

  /// Check if text is a valid email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Check if text is a valid phone number
  static bool isValidPhoneNumber(String phoneNumber) {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^[0-9]{10,11}$').hasMatch(digits);
  }

  /// Check if text is a valid URL
  static bool isValidUrl(String url) {
    return RegExp(r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$').hasMatch(url);
  }

  /// Remove Vietnamese accents
  static String removeVietnameseAccents(String text) {
    return text
        .replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp(r'[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]'), 'A')
        .replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp(r'[ÈÉẸẺẼÊỀẾỆỂỄ]'), 'E')
        .replaceAll(RegExp(r'[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp(r'[ÌÍỊỈĨ]'), 'I')
        .replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp(r'[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]'), 'O')
        .replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp(r'[ÙÚỤỦŨƯỪỨỰỬỮ]'), 'U')
        .replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y')
        .replaceAll(RegExp(r'[ỲÝỴỶỸ]'), 'Y')
        .replaceAll(RegExp(r'[đ]'), 'd')
        .replaceAll(RegExp(r'[Đ]'), 'D');
  }

  /// Format number with thousand separators
  static String formatNumber(num number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }

  /// Generate random string
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(length, (index) => chars[(random + index) % chars.length]).join();
  }

  /// Check if string contains search query (case insensitive, accent insensitive)
  static bool containsIgnoreCase(String text, String query) {
    final normalizedText = removeVietnameseAccents(text.toLowerCase());
    final normalizedQuery = removeVietnameseAccents(query.toLowerCase());
    return normalizedText.contains(normalizedQuery);
  }
}