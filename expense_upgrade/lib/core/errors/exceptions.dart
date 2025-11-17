abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);
  
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(String message) : super(message);
}

class AuthException extends AppException {
  const AuthException(String message) : super(message);
}

class ValidationException extends AppException {
  const ValidationException(String message) : super(message);
}

class FirestoreException extends AppException {
  const FirestoreException(String message) : super(message);
}

class CacheException extends AppException {
  const CacheException(String message) : super(message);
}

class SyncException extends AppException {
  const SyncException(String message) : super(message);
}