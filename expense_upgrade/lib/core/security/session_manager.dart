import 'dart:async';
import 'package:flutter/foundation.dart';
import '../errors/exceptions.dart';
import '../../data/services/local_storage_service.dart';

class SessionManager {
  static const Duration _sessionTimeout = Duration(minutes: 30);
  static const Duration _warningThreshold = Duration(minutes: 25);
  static const String _lastActivityKey = 'last_activity';
  static const String _sessionTokenKey = 'session_token';
  
  final LocalStorageService _localStorageService;
  Timer? _sessionTimer;
  Timer? _warningTimer;
  DateTime? _lastActivity;
  String? _currentSessionToken;
  
  // Callbacks
  VoidCallback? onSessionExpired;
  VoidCallback? onSessionWarning;
  
  SessionManager({
    required LocalStorageService localStorageService,
  }) : _localStorageService = localStorageService;

  /// Initialize session management
  Future<void> initialize() async {
    try {
      await _loadLastActivity();
      await _loadSessionToken();
      _startSessionMonitoring();
    } catch (e) {
      throw SessionException('Không thể khởi tạo session: ${e.toString()}');
    }
  }

  /// Start a new session
  Future<void> startSession(String userId) async {
    try {
      _lastActivity = DateTime.now();
      _currentSessionToken = _generateSessionToken();
      
      await _saveLastActivity();
      await _saveSessionToken();
      
      _startSessionMonitoring();
    } catch (e) {
      throw SessionException('Không thể bắt đầu session: ${e.toString()}');
    }
  }

  /// End current session
  Future<void> endSession() async {
    try {
      _stopSessionMonitoring();
      
      await _localStorageService.getUserPreference(_lastActivityKey);
      await _localStorageService.getUserPreference(_sessionTokenKey);
      
      _lastActivity = null;
      _currentSessionToken = null;
    } catch (e) {
      throw SessionException('Không thể kết thúc session: ${e.toString()}');
    }
  }

  /// Update activity timestamp
  Future<void> updateActivity() async {
    try {
      _lastActivity = DateTime.now();
      await _saveLastActivity();
      
      // Reset timers
      _stopSessionMonitoring();
      _startSessionMonitoring();
    } catch (e) {
      // Log error but don't throw to avoid disrupting user experience
      debugPrint('Failed to update activity: $e');
    }
  }

  /// Check if session is valid
  bool isSessionValid() {
    if (_lastActivity == null || _currentSessionToken == null) {
      return false;
    }
    
    final now = DateTime.now();
    final timeSinceLastActivity = now.difference(_lastActivity!);
    
    return timeSinceLastActivity < _sessionTimeout;
  }

  /// Get remaining session time
  Duration? getRemainingTime() {
    if (_lastActivity == null) return null;
    
    final now = DateTime.now();
    final timeSinceLastActivity = now.difference(_lastActivity!);
    final remaining = _sessionTimeout - timeSinceLastActivity;
    
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Extend session (for critical operations)
  Future<void> extendSession() async {
    try {
      await updateActivity();
    } catch (e) {
      throw SessionException('Không thể gia hạn session: ${e.toString()}');
    }
  }

  /// Get current session token
  String? get sessionToken => _currentSessionToken;

  /// Validate session token
  bool validateSessionToken(String token) {
    return _currentSessionToken == token;
  }

  void _startSessionMonitoring() {
    if (_lastActivity == null) return;
    
    final now = DateTime.now();
    final timeSinceLastActivity = now.difference(_lastActivity!);
    
    // Calculate remaining time until warning
    final timeUntilWarning = _warningThreshold - timeSinceLastActivity;
    if (timeUntilWarning.isNegative) {
      // Should show warning immediately
      _showSessionWarning();
    } else {
      // Set timer for warning
      _warningTimer = Timer(timeUntilWarning, _showSessionWarning);
    }
    
    // Calculate remaining time until expiration
    final timeUntilExpiration = _sessionTimeout - timeSinceLastActivity;
    if (timeUntilExpiration.isNegative) {
      // Session already expired
      _expireSession();
    } else {
      // Set timer for expiration
      _sessionTimer = Timer(timeUntilExpiration, _expireSession);
    }
  }

  void _stopSessionMonitoring() {
    _sessionTimer?.cancel();
    _warningTimer?.cancel();
    _sessionTimer = null;
    _warningTimer = null;
  }

  void _showSessionWarning() {
    onSessionWarning?.call();
  }

  void _expireSession() {
    _stopSessionMonitoring();
    onSessionExpired?.call();
  }

  Future<void> _loadLastActivity() async {
    try {
      final activityString = await _localStorageService.getUserPreference(_lastActivityKey);
      if (activityString != null) {
        _lastActivity = DateTime.parse(activityString);
      }
    } catch (e) {
      _lastActivity = null;
    }
  }

  Future<void> _saveLastActivity() async {
    if (_lastActivity != null) {
      await _localStorageService.saveUserPreference(
        _lastActivityKey,
        _lastActivity!.toIso8601String(),
      );
    }
  }

  Future<void> _loadSessionToken() async {
    try {
      _currentSessionToken = await _localStorageService.getUserPreference(_sessionTokenKey);
    } catch (e) {
      _currentSessionToken = null;
    }
  }

  Future<void> _saveSessionToken() async {
    if (_currentSessionToken != null) {
      await _localStorageService.saveUserPreference(
        _sessionTokenKey,
        _currentSessionToken!,
      );
    }
  }

  String _generateSessionToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return '$timestamp-$random';
  }

  /// Dispose resources
  void dispose() {
    _stopSessionMonitoring();
  }
}

class SessionException extends AppException {
  const SessionException(String message) : super(message);
}