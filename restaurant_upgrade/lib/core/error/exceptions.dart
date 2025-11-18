class ServerException implements Exception {
  final String message;
  final String code;

  const ServerException({
    required this.message,
    required this.code,
  });
}

class NetworkException implements Exception {
  final String message;
  final String code;

  const NetworkException({
    required this.message,
    required this.code,
  });
}

class CacheException implements Exception {
  final String message;
  final String code;

  const CacheException({
    required this.message,
    required this.code,
  });
}

class AuthException implements Exception {
  final String message;
  final String code;

  const AuthException({
    required this.message,
    required this.code,
  });
}

class StorageException implements Exception {
  final String message;
  final String code;

  const StorageException({
    required this.message,
    required this.code,
  });
}

class ValidationException implements Exception {
  final String message;
  final String code;

  const ValidationException({
    required this.message,
    required this.code,
  });
}