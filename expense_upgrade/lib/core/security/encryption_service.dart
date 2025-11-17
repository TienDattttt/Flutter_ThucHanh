import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import '../errors/exceptions.dart';

class EncryptionService {
  static const String _keyPrefix = 'expense_app_';
  static const String _fixedKeyString = 'expense_tracker_2024_secure_key_32b';
  static const String _fixedIVString = 'expense_iv_16byte';
  
  late final Encrypter _encrypter;
  late final IV _iv;
  
  EncryptionService() {
    _initializeEncryption();
  }

  void _initializeEncryption() {
    try {
      // Use fixed key and IV for consistent encryption/decryption
      // In production, these should be stored securely or derived from user credentials
      final keyBytes = utf8.encode(_fixedKeyString);
      final key = Key(Uint8List.fromList(keyBytes.take(32).toList()));
      
      final ivBytes = utf8.encode(_fixedIVString);
      _iv = IV(Uint8List.fromList(ivBytes.take(16).toList()));
      
      _encrypter = Encrypter(AES(key));
    } catch (e) {
      throw EncryptionException('Không thể khởi tạo encryption service: ${e.toString()}');
    }
  }

  /// Encrypt sensitive data before storing
  String encryptData(String data) {
    try {
      if (data.isEmpty) return data;
      final encrypted = _encrypter.encrypt(data, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      throw EncryptionException('Không thể mã hóa dữ liệu: ${e.toString()}');
    }
  }

  /// Decrypt sensitive data after retrieving
  String decryptData(String encryptedData) {
    try {
      if (encryptedData.isEmpty) return encryptedData;
      final encrypted = Encrypted.fromBase64(encryptedData);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      // If decryption fails, return original data (for backward compatibility)
      return encryptedData;
    }
  }

  /// Hash sensitive data for comparison (one-way)
  String hashData(String data) {
    try {
      final bytes = utf8.encode(data);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      throw EncryptionException('Không thể hash dữ liệu: ${e.toString()}');
    }
  }

  /// Generate secure random token
  String generateSecureToken({int length = 32}) {
    try {
      final random = Random.secure();
      final bytes = Uint8List(length);
      for (int i = 0; i < length; i++) {
        bytes[i] = random.nextInt(256);
      }
      return base64Url.encode(bytes);
    } catch (e) {
      throw EncryptionException('Không thể tạo token: ${e.toString()}');
    }
  }

  /// Validate data integrity using HMAC
  String generateHMAC(String data, String secret) {
    try {
      final key = utf8.encode(secret);
      final bytes = utf8.encode(data);
      final hmacSha256 = Hmac(sha256, key);
      final digest = hmacSha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      throw EncryptionException('Không thể tạo HMAC: ${e.toString()}');
    }
  }

  /// Verify data integrity using HMAC
  bool verifyHMAC(String data, String secret, String expectedHmac) {
    try {
      final calculatedHmac = generateHMAC(data, secret);
      return calculatedHmac == expectedHmac;
    } catch (e) {
      return false;
    }
  }

  /// Encrypt transaction data specifically
  Map<String, dynamic> encryptTransactionData(Map<String, dynamic> transactionData) {
    try {
      final sensitiveFields = ['description'];
      final encryptedData = Map<String, dynamic>.from(transactionData);
      
      for (final field in sensitiveFields) {
        if (encryptedData.containsKey(field) && encryptedData[field] != null) {
          final value = encryptedData[field].toString();
          if (value.isNotEmpty) {
            encryptedData[field] = encryptData(value);
          }
        }
      }
      
      return encryptedData;
    } catch (e) {
      // If encryption fails, return original data
      return transactionData;
    }
  }

  /// Decrypt transaction data specifically
  Map<String, dynamic> decryptTransactionData(Map<String, dynamic> encryptedData) {
    try {
      final decryptedData = Map<String, dynamic>.from(encryptedData);
      final sensitiveFields = ['description'];
      
      for (final field in sensitiveFields) {
        if (decryptedData.containsKey(field) && decryptedData[field] != null) {
          final value = decryptedData[field].toString();
          if (value.isNotEmpty) {
            decryptedData[field] = decryptData(value);
          }
        }
      }
      
      return decryptedData;
    } catch (e) {
      // If decryption fails, return original data
      return encryptedData;
    }
  }

  /// Sanitize input to prevent injection attacks
  String sanitizeInput(String input) {
    if (input.isEmpty) return input;
    
    // Remove potentially dangerous characters but keep Vietnamese characters
    return input
        .replaceAll(RegExp(r'[<>"\\]'), '')
        .replaceAll(RegExp(r"'"), '')
        .replaceAll(RegExp(r'script', caseSensitive: false), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'[^\w\s@.-àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđĐ]'), '')
        .trim();
  }

  /// Validate email format
  bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  /// Validate password strength
  PasswordStrength validatePasswordStrength(String password) {
    if (password.isEmpty || password.length < 6) {
      return PasswordStrength.weak;
    }
    
    if (password.length < 8) {
      return PasswordStrength.medium;
    }
    
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    int score = 0;
    if (hasUppercase) score++;
    if (hasLowercase) score++;
    if (hasDigits) score++;
    if (hasSpecialCharacters) score++;
    if (password.length >= 12) score++;
    
    if (score >= 4) {
      return PasswordStrength.strong;
    } else if (score >= 2) {
      return PasswordStrength.medium;
    } else {
      return PasswordStrength.weak;
    }
  }

  /// Validate display name
  bool isValidDisplayName(String displayName) {
    if (displayName.isEmpty) return false;
    
    // Allow Vietnamese characters and basic punctuation
    final nameRegex = RegExp(r'^[a-zA-ZàáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđĐ\s.,-]{2,50}$');
    return nameRegex.hasMatch(displayName.trim());
  }

  /// Generate session token
  String generateSessionToken(String userId) {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final data = '$userId:$timestamp:${generateSecureToken(length: 16)}';
      return base64Url.encode(utf8.encode(data));
    } catch (e) {
      throw EncryptionException('Không thể tạo session token: ${e.toString()}');
    }
  }

  /// Validate session token
  bool isValidSessionToken(String token, String userId) {
    try {
      final decoded = utf8.decode(base64Url.decode(token));
      final parts = decoded.split(':');
      
      if (parts.length != 3) return false;
      if (parts[0] != userId) return false;
      
      final timestamp = int.tryParse(parts[1]);
      if (timestamp == null) return false;
      
      // Check if token is not older than 24 hours
      final tokenTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(tokenTime);
      
      return difference.inHours < 24;
    } catch (e) {
      return false;
    }
  }
}

enum PasswordStrength {
  weak,
  medium,
  strong,
}

class EncryptionException extends AppException {
  const EncryptionException(String message) : super(message);
}