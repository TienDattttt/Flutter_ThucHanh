import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/errors/exceptions.dart';
import '../../core/security/session_manager.dart';
import '../../core/security/encryption_service.dart';
import '../../data/services/local_storage_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  sessionExpired,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FlutterSecureStorage _secureStorage;
  final SessionManager _sessionManager;
  final EncryptionService _encryptionService;
  final LocalStorageService _localStorageService;
  
  AuthProvider({
    required AuthRepository authRepository,
    required SessionManager sessionManager,
    required EncryptionService encryptionService,
    required LocalStorageService localStorageService,
    FlutterSecureStorage? secureStorage,
  }) : _authRepository = authRepository,
        _sessionManager = sessionManager,
        _encryptionService = encryptionService,
        _localStorageService = localStorageService,
        _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _init();
  }
  
  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;
  bool get isLoading => _state == AuthState.loading;
  
  void _init() {
    // Initialize session manager
    _sessionManager.onSessionExpired = _handleSessionExpired;
    _sessionManager.onSessionWarning = _handleSessionWarning;
    _sessionManager.initialize();
    
    _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        _user = user;
        _state = AuthState.authenticated;
        _sessionManager.startSession(user.id);
      } else {
        _user = null;
        _state = AuthState.unauthenticated;
        _sessionManager.endSession();
        _clearCachedData();
      }
      notifyListeners();
    });
  }
  
  Future<void> signIn(String email, String password) async {
    try {
      _setState(AuthState.loading);
      
      // Validate input
      if (!_encryptionService.isValidEmail(email)) {
        throw const AuthException('Email không hợp lệ');
      }
      
      // Sanitize input
      final sanitizedEmail = _encryptionService.sanitizeInput(email);
      
      final user = await _authRepository.signIn(sanitizedEmail, password);
      if (user != null) {
        _user = user;
        await _sessionManager.startSession(user.id);
        _setState(AuthState.authenticated);
        
        // Log successful login
        await _localStorageService.logError('Successful login', userId: user.id);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } on AuthException catch (e) {
      await _localStorageService.logError('Login failed: ${e.message}');
      _setError(e.message);
    } catch (e) {
      await _localStorageService.logError('Login error: $e');
      _setError('Đã xảy ra lỗi không xác định');
    }
  }
  
  Future<void> signUp(String email, String password, String displayName) async {
    try {
      _setState(AuthState.loading);
      
      print('DEBUG: Starting signUp for email: $email');
      
      // Validate input
      if (!_encryptionService.isValidEmail(email)) {
        throw const AuthException('Email không hợp lệ');
      }
      
      final passwordStrength = _encryptionService.validatePasswordStrength(password);
      if (passwordStrength == PasswordStrength.weak) {
        throw const AuthException('Mật khẩu quá yếu. Vui lòng sử dụng ít nhất 8 ký tự với chữ hoa, chữ thường và số.');
      }
      
      // Sanitize input
      final sanitizedEmail = _encryptionService.sanitizeInput(email);
      final sanitizedDisplayName = _encryptionService.sanitizeInput(displayName);
      
      print('DEBUG: Calling authRepository.signUp');
      final user = await _authRepository.signUp(sanitizedEmail, password, sanitizedDisplayName);
      print('DEBUG: signUp returned user: ${user?.id}');
      
      if (user != null) {
        _user = user;
        print('DEBUG: Starting session for user: ${user.id}');
        await _sessionManager.startSession(user.id);
        _setState(AuthState.authenticated);
        
        // Log successful registration
        await _localStorageService.logError('Successful registration', userId: user.id);
        print('DEBUG: Registration successful');
      } else {
        print('DEBUG: signUp returned null user');
        _setState(AuthState.unauthenticated);
      }
    } on AuthException catch (e) {
      print('DEBUG: AuthException caught: ${e.message}');
      await _localStorageService.logError('Registration failed: ${e.message}');
      _setError(e.message);
    } catch (e, stackTrace) {
      print('DEBUG: General exception caught: $e');
      print('DEBUG: Stack trace: $stackTrace');
      await _localStorageService.logError('Registration error: $e');
      _setError('Đã xảy ra lỗi không xác định: ${e.toString()}');
    }
  }
  
  Future<void> signOut() async {
    try {
      _setState(AuthState.loading);
      
      final userId = _user?.id;
      
      await _authRepository.signOut();
      await _sessionManager.endSession();
      _user = null;
      _setState(AuthState.unauthenticated);
      await _clearCachedData();
      
      // Log successful logout
      if (userId != null) {
        await _localStorageService.logError('Successful logout', userId: userId);
      }
    } on AuthException catch (e) {
      await _localStorageService.logError('Logout failed: ${e.message}');
      _setError(e.message);
    } catch (e) {
      await _localStorageService.logError('Logout error: $e');
      _setError('Không thể đăng xuất');
    }
  }
  
  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
    }
    notifyListeners();
  }
  
  Future<void> _clearCachedData() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      debugPrint('Error clearing cached data: $e');
    }
  }
  
  void _setState(AuthState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }
  
  void _setError(String message) {
    _state = AuthState.error;
    _errorMessage = message;
    notifyListeners();
  }

  // Session management methods
  void updateActivity() {
    if (_state == AuthState.authenticated) {
      _sessionManager.updateActivity();
    }
  }

  bool get isSessionValid => _sessionManager.isSessionValid();

  Duration? get remainingSessionTime => _sessionManager.getRemainingTime();

  Future<void> extendSession() async {
    if (_state == AuthState.authenticated) {
      await _sessionManager.extendSession();
    }
  }

  void _handleSessionExpired() {
    _state = AuthState.sessionExpired;
    _user = null;
    notifyListeners();
    
    // Auto sign out
    signOut();
  }

  void _handleSessionWarning() {
    // Notify UI about session warning
    // This could trigger a dialog asking user to extend session
    notifyListeners();
  }

  // Security methods
  String? get currentSessionToken => _sessionManager.sessionToken;

  bool validateSessionToken(String token) {
    return _sessionManager.validateSessionToken(token);
  }

  // Getters for backward compatibility
  User? get currentUser => _user;

  @override
  void dispose() {
    _sessionManager.dispose();
    super.dispose();
  }
}