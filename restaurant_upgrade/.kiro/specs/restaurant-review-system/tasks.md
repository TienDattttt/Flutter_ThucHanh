# Kế hoạch Triển khai - Hệ thống Đánh giá Nhà hàng

- [x] 1. Thiết lập cấu trúc dự án và dependencies





  - Cấu hình Firebase project và services (Authentication, Firestore, Storage, FCM)
  - Thêm các dependencies cần thiết vào pubspec.yaml (firebase_core, firebase_auth, cloud_firestore, firebase_storage, firebase_messaging, flutter_bloc, get_it, dartz, image_picker)
  - Tạo cấu trúc thư mục theo Clean Architecture (lib/core, lib/features, lib/shared)
  - Cấu hình Firebase cho Android và iOS platforms
  - _Yêu cầu: 1.2, 1.4, 2.3, 4.2, 6.1_

- [x] 2. Triển khai Core Infrastructure






  - [x] 2.1 Tạo base classes và interfaces


    - Implement Failure class và error handling mechanism
    - Tạo UseCase abstract class với Either return type
    - Định nghĩa Repository interfaces cho tất cả modules
    - _Yêu cầu: 7.1, 7.2, 7.3_
  
  - [x] 2.2 Thiết lập Dependency Injection


    - Cấu hình GetIt service locator
    - Đăng ký tất cả dependencies (repositories, use cases, data sources)
    - Tạo injection container initialization
    - _Yêu cầu: 7.4_
  


  - [x] 2.3 Tạo shared utilities và constants


    - Định nghĩa app constants (colors, text styles, dimensions)
    - Implement network utilities và error mappers
    - Tạo validation utilities cho forms
    - _Yêu cầu: 7.1, 7.5_

- [x] 3. Triển khai Authentication Module



  - [x] 3.1 Tạo Authentication entities và models


    - Implement User entity với validation
    - Tạo UserModel cho data layer với fromJson/toJson
    - Định nghĩa authentication-related failures
    - _Yêu cầu: 1.2, 1.4_
  
  - [x] 3.2 Implement Authentication Repository


    - Tạo AuthRemoteDataSource với Firebase Authentication
    - Implement AuthRepositoryImpl với error handling
    - Xử lý authentication state changes stream
    - _Yêu cầu: 1.2, 1.3, 1.5_
  
  - [x] 3.3 Tạo Authentication Use Cases


    - Implement SignUpUseCase với email/password validation
    - Tạo SignInUseCase với proper error handling
    - Implement SignOutUseCase và GetCurrentUserUseCase
    - _Yêu cầu: 1.2, 1.3, 1.5_
  

  - [x] 3.4 Xây dựng Authentication UI

    - Tạo AuthBloc với các states (initial, loading, authenticated, error)
    - Implement SignUpPage với form validation
    - Tạo SignInPage với remember me functionality
    - Implement SplashPage để check authentication state
    - _Yêu cầu: 1.1, 1.3, 1.5_
  
  - [x] 3.5 Viết unit tests cho Authentication module

    - Test AuthRepositoryImpl với mock Firebase Auth
    - Test tất cả Authentication Use Cases
    - Test AuthBloc với các scenarios khác nhau
    - _Yêu cầu: 1.2, 1.3, 1.5_

- [x] 4. Triển khai Restaurant Module



  - [x] 4.1 Tạo Restaurant entities và models


    - Implement Restaurant entity với business logic
    - Tạo RestaurantModel với Firestore serialization
    - Định nghĩa restaurant-related failures
    - _Yêu cầu: 2.1, 2.2_
  


  - [x] 4.2 Implement Restaurant Repository


    - Tạo RestaurantRemoteDataSource với Firestore queries
    - Implement RestaurantRepositoryImpl với real-time streams
    - Xử lý caching và offline support


    - _Yêu cầu: 2.1, 2.3, 2.4_
  
  - [x] 4.3 Tạo Restaurant Use Cases


    - Implement GetRestaurantsUseCase với stream support


    - Tạo GetRestaurantDetailsUseCase
    - Implement AddRestaurantUseCase (admin functionality)
    - _Yêu cầu: 2.1, 2.2, 2.5_
  
  - [x] 4.4 Xây dựng Restaurant UI

    - Tạo RestaurantBloc với real-time state management
    - Implement RestaurantListPage với StreamBuilder
    - Tạo RestaurantDetailPage với comprehensive information display
    - Implement search và filter functionality
    - _Yêu cầu: 2.1, 2.2, 2.5_
  
  - [ ] 4.5 Viết unit tests cho Restaurant module
    - Test RestaurantRepositoryImpl với mock Firestore
    - Test tất cả Restaurant Use Cases
    - Test RestaurantBloc với real-time data scenarios
    - _Yêu cầu: 2.1, 2.2, 2.5_





- [x] 5. Triển khai Review Module

  - [x] 5.1 Tạo Review entities và models


    - Implement Review entity với rating validation
    - Tạo ReviewModel với Firestore serialization


    - Định nghĩa review-related failures
    - _Yêu cầu: 3.2, 3.3, 4.1, 4.4_
  
  - [x] 5.2 Implement Review Repository


    - Tạo ReviewRemoteDataSource với Firestore operations
    - Implement image upload functionality với Firebase Storage
    - Tạo ReviewRepositoryImpl với comprehensive error handling
    - _Yêu cầu: 3.2, 3.4, 4.2, 4.3, 4.4_

  
  - [x] 5.3 Tạo Review Use Cases


    - Implement GetReviewsUseCase với real-time updates
    - Tạo AddReviewUseCase với image upload support
    - Implement UploadImageUseCase với compression
    - _Yêu cầu: 3.2, 3.4, 4.1, 4.2, 4.4_

  
  - [x] 5.4 Xây dựng Review UI


    - Tạo ReviewBloc với image handling states
    - Implement ReviewListWidget với real-time updates
    - Tạo AddReviewPage với image picker integration
    - Implement rating input và text validation
    - _Yêu cầu: 3.3, 4.1, 4.2, 4.5_
  
  - [ ] 5.5 Viết unit tests cho Review module
    - Test ReviewRepositoryImpl với mock services
    - Test tất cả Review Use Cases including image upload
    - Test ReviewBloc với complex state scenarios
    - _Yêu cầu: 4.1, 4.2, 4.4_

- [-] 6. Triển khai Cloud Functions

  - [x] 6.1 Thiết lập Cloud Functions project


    - Initialize Firebase Functions project
    - Cấu hình TypeScript và dependencies
    - Setup deployment scripts
    - _Yêu cầu: 5.1, 5.2_
  
  - [x] 6.2 Implement Calculate Average Rating Function


    - Tạo Firestore trigger cho reviews collection
    - Implement logic tính toán average rating
    - Update restaurant document với new rating
    - Xử lý error cases và edge scenarios
    - _Yêu cầu: 5.1, 5.2, 5.3, 5.4, 5.5_
  
  - [x] 6.3 Implement Push Notification Function


    - Tạo function gửi notification khi có review mới
    - Implement topic-based messaging cho restaurants
    - Xử lý notification payload và deep linking
    - _Yêu cầu: 6.2, 6.3_
  
  - [ ] 6.4 Viết tests cho Cloud Functions
    - Test calculate average rating function với mock data
    - Test notification function với different scenarios
    - Integration tests với Firebase emulator
    - _Yêu cầu: 5.1, 5.2, 6.2_

- [ ] 7. Triển khai Push Notifications
  - [x] 7.1 Thiết lập FCM trong app



    - Cấu hình Firebase Messaging service
    - Implement token registration và management
    - Setup notification permissions handling
    - _Yêu cầu: 6.1, 6.3_
  
  - [x] 7.2 Implement Notification Repository


    - Tạo NotificationRemoteDataSource với FCM
    - Implement NotificationRepositoryImpl
    - Xử lý foreground và background notifications
    - _Yêu cầu: 6.3, 6.4, 6.5_
  
  - [x] 7.3 Tạo Notification Use Cases


    - Implement InitializeNotificationsUseCase
    - Tạo HandleNotificationUseCase cho navigation
    - Implement subscription management use cases
    - _Yêu cầu: 6.1, 6.4, 6.5_
  
  - [ ] 7.4 Integrate notifications với UI
    - Implement notification handling trong main app
    - Tạo notification display widgets
    - Setup deep linking cho notification taps
    - _Yêu cầu: 6.4, 6.5_
  
  - [ ] 7.5 Viết tests cho Notification module
    - Test NotificationRepositoryImpl với mock FCM
    - Test notification use cases
    - Integration tests cho notification flow
    - _Yêu cầu: 6.1, 6.3, 6.4_

- [ ] 8. Triển khai Security và Performance
  - [x] 8.1 Cấu hình Firestore Security Rules


    - Implement rules cho users collection
    - Tạo rules cho restaurants và reviews collections
    - Test security rules với Firebase emulator
    - _Yêu cầu: 1.4, 2.1, 4.4_
  
  - [x] 8.2 Cấu hình Firebase Storage Security Rules


    - Implement rules cho image uploads
    - Setup file size và type restrictions
    - Test storage security với different scenarios
    - _Yêu cầu: 4.2, 4.3_
  
  - [x] 8.3 Implement Performance Optimizations



    - Setup Firestore offline persistence
    - Implement image caching và compression
    - Optimize queries với proper indexing
    - Setup pagination cho large datasets
    - _Yêu cầu: 2.3, 2.4, 3.4_
  
  - [ ] 8.4 Viết performance tests
    - Test app performance với large datasets
    - Test offline functionality
    - Measure và optimize app startup time
    - _Yêu cầu: 2.3, 2.4_

- [x] 9. Integration và Testing



  - [ ] 9.1 Tích hợp tất cả modules
    - Connect authentication flow với main app navigation
    - Integrate restaurant listing với review system
    - Setup proper error handling across all modules
    - Implement loading states và user feedback
    - _Yêu cầu: 1.5, 2.5, 3.5, 4.5, 6.5_
  
  - [ ] 9.2 Implement App Navigation
    - Setup proper routing với authentication guards
    - Implement deep linking cho notifications
    - Create consistent navigation patterns
    - _Yêu cầu: 1.5, 6.5_
  
  - [ ] 9.3 Viết integration tests
    - Test complete user registration và login flow
    - Test end-to-end review creation process
    - Test notification delivery và handling
    - Test offline functionality scenarios
    - _Yêu cầu: 1.2, 1.3, 4.1, 4.4, 6.4_
  
  - [ ] 9.4 Viết widget tests
    - Test tất cả major UI components
    - Test form validation và user interactions
    - Test error states và loading indicators
    - _Yêu cầu: 1.1, 2.1, 4.1_

- [ ] 10. Deployment và Monitoring
  - [ ] 10.1 Chuẩn bị production deployment
    - Cấu hình production Firebase project
    - Setup environment-specific configurations
    - Prepare app icons và splash screens
    - _Yêu cầu: 7.5_
  
  - [ ] 10.2 Deploy Cloud Functions
    - Deploy functions lên production environment
    - Test functions với production data
    - Setup monitoring và logging
    - _Yêu cầu: 5.5, 6.2_
  
  - [ ] 10.3 Setup Monitoring và Analytics
    - Cấu hình Firebase Crashlytics
    - Setup Firebase Performance Monitoring
    - Implement Firebase Analytics tracking
    - _Yêu cầu: 7.5_
  
  - [ ] 10.4 Tạo documentation
    - Viết API documentation cho Cloud Functions
    - Tạo user guide cho app features
    - Document deployment procedures
    - _Yêu cầu: 7.5_