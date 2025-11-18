class AppConstants {
  // App Information
  static const String appName = 'Restaurant Review System';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Khám phá và đánh giá nhà hàng';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String restaurantsCollection = 'restaurants';
  static const String reviewsCollection = 'reviews';
  static const String notificationsCollection = 'notifications';
  static const String categoriesCollection = 'categories';

  // Storage Paths
  static const String reviewImagesPath = 'review_images';
  static const String restaurantImagesPath = 'restaurant_images';
  static const String userAvatarsPath = 'user_avatars';

  // Cloudinary Configuration
  static const String cloudinaryCloudName = 'dhg7jec6p';
  static const String cloudinaryUploadPreset = 'restaurant_review_preset';
  static const String defaultImageFolder = 'restaurant_review_system';
  static const String restaurantImagesFolder = 'restaurants';
  static const String reviewImagesFolder = 'reviews';
  static const String userProfileImagesFolder = 'profiles';

  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minDisplayNameLength = 2;
  static const int maxDisplayNameLength = 50;
  static const int minReviewLength = 10;
  static const int maxReviewLength = 500;
  static const int minRestaurantNameLength = 2;
  static const int maxRestaurantNameLength = 100;
  static const int minAddressLength = 5;
  static const int maxAddressLength = 200;
  static const int maxImageSizeMB = 5;
  static const int maxImagesPerReview = 5;

  // Rating Constants
  static const int minRating = 1;
  static const int maxRating = 5;
  static const double defaultRating = 0.0;

  // Pagination Constants
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
  static const int restaurantListPageSize = 10;
  static const int reviewListPageSize = 15;
  static const int notificationPageSize = 20;

  // Location Constants
  static const double defaultSearchRadius = 10.0; // km
  static const double maxSearchRadius = 50.0; // km
  static const double defaultLatitude = 10.8231; // Ho Chi Minh City
  static const double defaultLongitude = 106.6297;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;

  // Animation Constants
  static const int defaultAnimationDuration = 300; // milliseconds
  static const int splashScreenDuration = 2000; // milliseconds
  static const int debounceDelay = 500; // milliseconds for search

  // Network Constants
  static const int connectionTimeout = 30000; // milliseconds
  static const int receiveTimeout = 30000; // milliseconds

  // Cache Constants
  static const int imageCacheMaxAge = 7; // days
  static const int dataCacheMaxAge = 1; // days

  // Notification Topics
  static const String allUsersTopicPrefix = 'all_users';
  static const String restaurantTopicPrefix = 'restaurant_';
  static const String userTopicPrefix = 'user_';

  // Error Messages
  static const String networkErrorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
  static const String serverErrorMessage = 'Lỗi server. Vui lòng thử lại sau.';
  static const String unknownErrorMessage = 'Đã xảy ra lỗi không xác định.';
  static const String noDataMessage = 'Không có dữ liệu.';
  static const String loadingMessage = 'Đang tải...';

  // Success Messages
  static const String reviewAddedMessage = 'Đánh giá đã được thêm thành công!';
  static const String reviewUpdatedMessage = 'Đánh giá đã được cập nhật!';
  static const String reviewDeletedMessage = 'Đánh giá đã được xóa!';
  static const String profileUpdatedMessage = 'Hồ sơ đã được cập nhật!';

  // Restaurant Categories
  static const List<String> defaultCategories = [
    'Ăn nhanh',
    'Ăn vặt',
    'Buffet',
    'Cafe',
    'Chay',
    'Hải sản',
    'Lẩu',
    'Món Á',
    'Món Âu',
    'Món Việt',
    'Nướng',
    'Pizza',
    'Quán nhậu',
    'Tráng miệng',
  ];

  // Image Quality Settings
  static const int imageQuality = 85; // JPEG quality (0-100)
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int thumbnailSize = 200;

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';

  // Regular Expressions
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phoneRegex = r'^[0-9]{10,11}$';
  static const String urlRegex = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';

  // Supported Image Formats
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  // Review Order By Options
  static const String orderByNewest = 'newest';
  static const String orderByOldest = 'oldest';
  static const String orderByRatingDesc = 'rating_desc';
  static const String orderByRatingAsc = 'rating_asc';
  static const String orderByHelpful = 'helpful';
}