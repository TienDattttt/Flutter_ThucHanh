import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String code;

  const Failure({
    required this.message,
    required this.code,
  });

  @override
  List<Object> get props => [message, code];
}

// Authentication Failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    required super.code,
  });
}

// Network Failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    required super.code,
  });
}

// Server Failures
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    required super.code,
  });
}

// Storage Failures
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    required super.code,
  });
}

// Cache Failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    required super.code,
  });
}

// Validation Failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    required super.code,
  });
}