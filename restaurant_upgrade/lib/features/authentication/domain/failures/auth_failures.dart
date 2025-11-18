import '../../../../core/error/failures.dart';

/// Specific authentication failures
class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure()
      : super(
          message: 'Không tìm thấy tài khoản với email này',
          code: 'user-not-found',
        );
}

class WrongPasswordFailure extends AuthFailure {
  const WrongPasswordFailure()
      : super(
          message: 'Mật khẩu không chính xác',
          code: 'wrong-password',
        );
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure()
      : super(
          message: 'Email này đã được sử dụng',
          code: 'email-already-in-use',
        );
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure()
      : super(
          message: 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn',
          code: 'weak-password',
        );
}

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure()
      : super(
          message: 'Email không hợp lệ',
          code: 'invalid-email',
        );
}

class UserDisabledFailure extends AuthFailure {
  const UserDisabledFailure()
      : super(
          message: 'Tài khoản đã bị vô hiệu hóa',
          code: 'user-disabled',
        );
}

class TooManyRequestsFailure extends AuthFailure {
  const TooManyRequestsFailure()
      : super(
          message: 'Quá nhiều yêu cầu. Vui lòng thử lại sau',
          code: 'too-many-requests',
        );
}

class EmailNotVerifiedFailure extends AuthFailure {
  const EmailNotVerifiedFailure()
      : super(
          message: 'Email chưa được xác thực. Vui lòng kiểm tra hộp thư của bạn',
          code: 'email-not-verified',
        );
}

class InvalidCredentialFailure extends AuthFailure {
  const InvalidCredentialFailure()
      : super(
          message: 'Thông tin đăng nhập không hợp lệ',
          code: 'invalid-credential',
        );
}

class AccountExistsWithDifferentCredentialFailure extends AuthFailure {
  const AccountExistsWithDifferentCredentialFailure()
      : super(
          message: 'Tài khoản đã tồn tại với phương thức đăng nhập khác',
          code: 'account-exists-with-different-credential',
        );
}

class OperationNotAllowedFailure extends AuthFailure {
  const OperationNotAllowedFailure()
      : super(
          message: 'Phương thức đăng nhập này không được phép',
          code: 'operation-not-allowed',
        );
}

class RequiresRecentLoginFailure extends AuthFailure {
  const RequiresRecentLoginFailure()
      : super(
          message: 'Thao tác này yêu cầu đăng nhập lại gần đây',
          code: 'requires-recent-login',
        );
}

class ProviderAlreadyLinkedFailure extends AuthFailure {
  const ProviderAlreadyLinkedFailure()
      : super(
          message: 'Tài khoản đã được liên kết với nhà cung cấp này',
          code: 'provider-already-linked',
        );
}

class NoSuchProviderFailure extends AuthFailure {
  const NoSuchProviderFailure()
      : super(
          message: 'Không tìm thấy nhà cung cấp đăng nhập',
          code: 'no-such-provider',
        );
}

class InvalidVerificationCodeFailure extends AuthFailure {
  const InvalidVerificationCodeFailure()
      : super(
          message: 'Mã xác thực không hợp lệ',
          code: 'invalid-verification-code',
        );
}

class InvalidVerificationIdFailure extends AuthFailure {
  const InvalidVerificationIdFailure()
      : super(
          message: 'ID xác thực không hợp lệ',
          code: 'invalid-verification-id',
        );
}

class SessionExpiredFailure extends AuthFailure {
  const SessionExpiredFailure()
      : super(
          message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại',
          code: 'session-expired',
        );
}

class UserTokenExpiredFailure extends AuthFailure {
  const UserTokenExpiredFailure()
      : super(
          message: 'Token người dùng đã hết hạn',
          code: 'user-token-expired',
        );
}

class CustomTokenMismatchFailure extends AuthFailure {
  const CustomTokenMismatchFailure()
      : super(
          message: 'Custom token không khớp',
          code: 'custom-token-mismatch',
        );
}

class InvalidCustomTokenFailure extends AuthFailure {
  const InvalidCustomTokenFailure()
      : super(
          message: 'Custom token không hợp lệ',
          code: 'invalid-custom-token',
        );
}

class MissingAndroidPkgNameFailure extends AuthFailure {
  const MissingAndroidPkgNameFailure()
      : super(
          message: 'Thiếu tên package Android',
          code: 'missing-android-pkg-name',
        );
}

class MissingContinueUriFailure extends AuthFailure {
  const MissingContinueUriFailure()
      : super(
          message: 'Thiếu continue URI',
          code: 'missing-continue-uri',
        );
}

class MissingIosBundleIdFailure extends AuthFailure {
  const MissingIosBundleIdFailure()
      : super(
          message: 'Thiếu iOS bundle ID',
          code: 'missing-ios-bundle-id',
        );
}

class InvalidContinueUriFailure extends AuthFailure {
  const InvalidContinueUriFailure()
      : super(
          message: 'Continue URI không hợp lệ',
          code: 'invalid-continue-uri',
        );
}

class UnauthorizedContinueUriFailure extends AuthFailure {
  const UnauthorizedContinueUriFailure()
      : super(
          message: 'Continue URI không được phép',
          code: 'unauthorized-continue-uri',
        );
}