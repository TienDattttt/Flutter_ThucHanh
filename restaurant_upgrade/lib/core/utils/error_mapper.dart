import 'package:firebase_auth/firebase_auth.dart';
import '../error/failures.dart';
import '../error/exceptions.dart';

class ErrorMapper {
  /// Map Firebase Auth exceptions to failures
  static Failure mapFirebaseAuthException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'user-not-found':
        return const AuthFailure(
          message: 'Không tìm thấy tài khoản với email này',
          code: 'user-not-found',
        );
      case 'wrong-password':
        return const AuthFailure(
          message: 'Mật khẩu không chính xác',
          code: 'wrong-password',
        );
      case 'email-already-in-use':
        return const AuthFailure(
          message: 'Email này đã được sử dụng',
          code: 'email-already-in-use',
        );
      case 'weak-password':
        return const AuthFailure(
          message: 'Mật khẩu quá yếu',
          code: 'weak-password',
        );
      case 'invalid-email':
        return const AuthFailure(
          message: 'Email không hợp lệ',
          code: 'invalid-email',
        );
      case 'user-disabled':
        return const AuthFailure(
          message: 'Tài khoản đã bị vô hiệu hóa',
          code: 'user-disabled',
        );
      case 'too-many-requests':
        return const AuthFailure(
          message: 'Quá nhiều yêu cầu. Vui lòng thử lại sau',
          code: 'too-many-requests',
        );
      case 'network-request-failed':
        return const NetworkFailure(
          message: 'Lỗi kết nối mạng',
          code: 'network-request-failed',
        );
      default:
        return AuthFailure(
          message: exception.message ?? 'Lỗi xác thực không xác định',
          code: exception.code,
        );
    }
  }

  /// Map Firestore exceptions to failures
  static Failure mapFirestoreException(FirebaseException exception) {
    switch (exception.code) {
      case 'permission-denied':
        return const ServerFailure(
          message: 'Không có quyền truy cập',
          code: 'permission-denied',
        );
      case 'not-found':
        return const ServerFailure(
          message: 'Không tìm thấy dữ liệu',
          code: 'not-found',
        );
      case 'already-exists':
        return const ServerFailure(
          message: 'Dữ liệu đã tồn tại',
          code: 'already-exists',
        );
      case 'resource-exhausted':
        return const ServerFailure(
          message: 'Vượt quá giới hạn sử dụng',
          code: 'resource-exhausted',
        );
      case 'failed-precondition':
        return const ServerFailure(
          message: 'Điều kiện tiên quyết không được đáp ứng',
          code: 'failed-precondition',
        );
      case 'aborted':
        return const ServerFailure(
          message: 'Thao tác bị hủy bỏ',
          code: 'aborted',
        );
      case 'out-of-range':
        return const ServerFailure(
          message: 'Giá trị nằm ngoài phạm vi cho phép',
          code: 'out-of-range',
        );
      case 'unimplemented':
        return const ServerFailure(
          message: 'Tính năng chưa được triển khai',
          code: 'unimplemented',
        );
      case 'internal':
        return const ServerFailure(
          message: 'Lỗi nội bộ của server',
          code: 'internal',
        );
      case 'unavailable':
        return const NetworkFailure(
          message: 'Dịch vụ không khả dụng',
          code: 'unavailable',
        );
      case 'deadline-exceeded':
        return const NetworkFailure(
          message: 'Hết thời gian chờ',
          code: 'deadline-exceeded',
        );
      default:
        return ServerFailure(
          message: exception.message ?? 'Lỗi server không xác định',
          code: exception.code,
        );
    }
  }

  /// Map Firebase Storage exceptions to failures
  static Failure mapFirebaseStorageException(FirebaseException exception) {
    switch (exception.code) {
      case 'object-not-found':
        return const StorageFailure(
          message: 'Không tìm thấy file',
          code: 'object-not-found',
        );
      case 'bucket-not-found':
        return const StorageFailure(
          message: 'Không tìm thấy bucket lưu trữ',
          code: 'bucket-not-found',
        );
      case 'project-not-found':
        return const StorageFailure(
          message: 'Không tìm thấy project',
          code: 'project-not-found',
        );
      case 'quota-exceeded':
        return const StorageFailure(
          message: 'Vượt quá dung lượng cho phép',
          code: 'quota-exceeded',
        );
      case 'unauthenticated':
        return const AuthFailure(
          message: 'Chưa xác thực',
          code: 'unauthenticated',
        );
      case 'unauthorized':
        return const AuthFailure(
          message: 'Không có quyền truy cập',
          code: 'unauthorized',
        );
      case 'retry-limit-exceeded':
        return const NetworkFailure(
          message: 'Vượt quá số lần thử lại',
          code: 'retry-limit-exceeded',
        );
      case 'invalid-checksum':
        return const StorageFailure(
          message: 'File bị lỗi trong quá trình tải lên',
          code: 'invalid-checksum',
        );
      case 'canceled':
        return const StorageFailure(
          message: 'Thao tác bị hủy bỏ',
          code: 'canceled',
        );
      default:
        return StorageFailure(
          message: exception.message ?? 'Lỗi lưu trữ không xác định',
          code: exception.code,
        );
    }
  }

  /// Map generic exceptions to failures
  static Failure mapGenericException(Exception exception) {
    if (exception is FirebaseAuthException) {
      return mapFirebaseAuthException(exception);
    } else if (exception is FirebaseException) {
      return mapFirestoreException(exception);
    } else if (exception is ServerException) {
      return ServerFailure(
        message: exception.message,
        code: exception.code,
      );
    } else if (exception is NetworkException) {
      return NetworkFailure(
        message: exception.message,
        code: exception.code,
      );
    } else if (exception is CacheException) {
      return CacheFailure(
        message: exception.message,
        code: exception.code,
      );
    } else if (exception is AuthException) {
      return AuthFailure(
        message: exception.message,
        code: exception.code,
      );
    } else if (exception is StorageException) {
      return StorageFailure(
        message: exception.message,
        code: exception.code,
      );
    } else if (exception is ValidationException) {
      return ValidationFailure(
        message: exception.message,
        code: exception.code,
      );
    } else {
      return ServerFailure(
        message: exception.toString(),
        code: 'unknown',
      );
    }
  }
}