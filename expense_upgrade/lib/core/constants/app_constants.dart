class AppConstants {
  // App info
  static const String appName = 'Quản lý Chi tiêu';
  static const String appVersion = '1.0.0';
  
  // Firestore collections
  static const String usersCollection = 'users';
  static const String transactionsCollection = 'transactions';
  static const String categoriesCollection = 'categories';
  
  // Pagination
  static const int transactionsPageSize = 20;
  
  // Validation
  static const int maxDescriptionLength = 200;
  static const double maxTransactionAmount = 999999999.0;
  static const double minTransactionAmount = 0.01;
}