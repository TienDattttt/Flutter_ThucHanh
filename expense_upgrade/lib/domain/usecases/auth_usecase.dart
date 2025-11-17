import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../core/utils/validators.dart';
import '../../core/errors/exceptions.dart';

class AuthUseCase {
  final AuthRepository _authRepository;
  
  AuthUseCase(this._authRepository);
  
  Future<User?> signIn(String email, String password) async {
    // Validate input
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      throw ValidationException(emailError);
    }
    
    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      throw ValidationException(passwordError);
    }
    
    return await _authRepository.signIn(email.trim(), password);
  }
  
  Future<User?> signUp(String email, String password, String displayName) async {
    // Validate input
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      throw ValidationException(emailError);
    }
    
    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      throw ValidationException(passwordError);
    }
    
    final displayNameError = Validators.validateDisplayName(displayName);
    if (displayNameError != null) {
      throw ValidationException(displayNameError);
    }
    
    return await _authRepository.signUp(
      email.trim(), 
      password, 
      displayName.trim(),
    );
  }
  
  Future<void> signOut() async {
    return await _authRepository.signOut();
  }
  
  Stream<User?> get authStateChanges => _authRepository.authStateChanges;
  
  User? get currentUser => _authRepository.currentUser;
}