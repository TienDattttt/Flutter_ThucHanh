import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'core/network/network_info.dart';

// Authentication
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/domain/usecases/sign_up_usecase.dart';
import 'features/authentication/domain/usecases/sign_in_usecase.dart';
import 'features/authentication/domain/usecases/sign_out_usecase.dart';
import 'features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'features/authentication/domain/usecases/send_password_reset_email_usecase.dart';
import 'features/authentication/domain/usecases/update_user_profile_usecase.dart';
import 'features/authentication/domain/usecases/delete_account_usecase.dart';
import 'features/authentication/domain/repositories/auth_repository.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/data/datasources/auth_remote_data_source.dart';

// Restaurants
import 'features/restaurants/presentation/bloc/restaurant_bloc.dart';
import 'features/restaurants/domain/usecases/get_restaurants_usecase.dart';
import 'features/restaurants/domain/usecases/get_restaurant_by_id_usecase.dart';
import 'features/restaurants/domain/usecases/get_restaurants_near_location_usecase.dart';
import 'features/restaurants/domain/usecases/add_restaurant_usecase.dart';
import 'features/restaurants/domain/usecases/get_restaurant_categories_usecase.dart';
import 'features/restaurants/domain/repositories/restaurant_repository.dart';
import 'features/restaurants/data/repositories/restaurant_repository_impl.dart';
import 'features/restaurants/data/datasources/restaurant_remote_data_source.dart';
import 'features/restaurants/data/datasources/restaurant_local_data_source.dart';

// Reviews
import 'features/reviews/presentation/bloc/review_bloc.dart';
import 'features/reviews/domain/usecases/get_reviews_usecase.dart';
import 'features/reviews/domain/usecases/add_review_usecase.dart';
import 'features/reviews/domain/usecases/update_review_usecase.dart';
import 'features/reviews/domain/usecases/delete_review_usecase.dart';
import 'features/reviews/domain/usecases/mark_review_as_helpful_usecase.dart';
import 'features/reviews/domain/usecases/unmark_review_as_helpful_usecase.dart';
import 'features/reviews/domain/usecases/get_user_review_for_restaurant_usecase.dart';
import 'features/reviews/domain/repositories/review_repository.dart';
import 'features/reviews/data/repositories/review_repository_impl.dart';
import 'features/reviews/data/datasources/review_remote_data_source.dart';

// Notifications
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/notifications/domain/usecases/get_user_notifications_usecase.dart';
import 'features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'features/notifications/domain/usecases/initialize_notifications_usecase.dart';
import 'features/notifications/domain/usecases/handle_notification_usecase.dart';
import 'features/notifications/domain/usecases/subscribe_to_restaurant_notifications_usecase.dart';
import 'features/notifications/domain/usecases/unsubscribe_from_restaurant_notifications_usecase.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/data/datasources/notification_remote_data_source.dart';

// Services
import 'core/services/fcm_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/image_cache_service.dart';
import 'core/services/cloudinary_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Authentication
  await _initAuth();

  //! Features - Restaurants
  await _initRestaurants();

  //! Features - Reviews
  await _initReviews();

  //! Features - Notifications
  await _initNotifications();

  //! Core
  await _initCore();

  //! External
  await _initExternal();
}

/// Initialize Authentication dependencies
Future<void> _initAuth() async {
  // BLoC
  sl.registerFactory(() => AuthBloc(
    signUpUseCase: sl(),
    signInUseCase: sl(),
    signOutUseCase: sl(),
    getCurrentUserUseCase: sl(),
    sendPasswordResetEmailUseCase: sl(),
    updateUserProfileUseCase: sl(),
    deleteAccountUseCase: sl(),
    authRepository: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SendPasswordResetEmailUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );
}

/// Initialize Restaurant dependencies
Future<void> _initRestaurants() async {
  // BLoC
  sl.registerFactory(() => RestaurantBloc(
    getRestaurantsUseCase: sl(),
    getRestaurantByIdUseCase: sl(),
    getRestaurantsNearLocationUseCase: sl(),
    addRestaurantUseCase: sl(),
    getRestaurantCategoriesUseCase: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => GetRestaurantsUseCase(sl()));
  sl.registerLazySingleton(() => GetRestaurantByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetRestaurantsNearLocationUseCase(sl()));
  sl.registerLazySingleton(() => AddRestaurantUseCase(sl()));
  sl.registerLazySingleton(() => GetRestaurantCategoriesUseCase(sl()));

  // Repository
  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(firestore: sl()),
  );
  
  sl.registerLazySingleton<RestaurantLocalDataSource>(
    () => RestaurantLocalDataSourceImpl(sharedPreferences: sl()),
  );
}

/// Initialize Review dependencies
Future<void> _initReviews() async {
  // BLoC
  sl.registerFactory(() => ReviewBloc(
    getReviewsUseCase: sl(),
    addReviewUseCase: sl(),
    updateReviewUseCase: sl(),
    deleteReviewUseCase: sl(),
    markReviewAsHelpfulUseCase: sl(),
    unmarkReviewAsHelpfulUseCase: sl(),
    getUserReviewForRestaurantUseCase: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => GetReviewsUseCase(sl()));
  sl.registerLazySingleton(() => AddReviewUseCase(sl()));
  sl.registerLazySingleton(() => UpdateReviewUseCase(sl()));
  sl.registerLazySingleton(() => DeleteReviewUseCase(sl()));
  sl.registerLazySingleton(() => MarkReviewAsHelpfulUseCase(sl()));
  sl.registerLazySingleton(() => UnmarkReviewAsHelpfulUseCase(sl()));
  sl.registerLazySingleton(() => GetUserReviewForRestaurantUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(
      firestore: sl(),
      storage: sl(),
      cloudinaryService: sl(),
    ),
  );
}

/// Initialize Notification dependencies
Future<void> _initNotifications() async {
  // BLoC
  sl.registerFactory(() => NotificationBloc(
    getUserNotificationsUseCase: sl(),
    markNotificationAsReadUseCase: sl(),
    initializeNotificationsUseCase: sl(),
    handleNotificationUseCase: sl(),
    subscribeToRestaurantNotificationsUseCase: sl(),
    unsubscribeFromRestaurantNotificationsUseCase: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => GetUserNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsReadUseCase(sl()));
  sl.registerLazySingleton(() => InitializeNotificationsUseCase(
    repository: sl(),
    fcmService: sl(),
  ));
  sl.registerLazySingleton(() => HandleNotificationUseCase(sl()));
  sl.registerLazySingleton(() => SubscribeToRestaurantNotificationsUseCase(
    repository: sl(),
    fcmService: sl(),
  ));
  sl.registerLazySingleton(() => UnsubscribeFromRestaurantNotificationsUseCase(
    repository: sl(),
    fcmService: sl(),
  ));

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(
      firestore: sl(),
      firebaseMessaging: sl(),
    ),
  );
}

/// Initialize Core dependencies
Future<void> _initCore() async {
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(connectivity: sl()));
  
  // Services
  sl.registerLazySingleton(() => FCMService());
  sl.registerLazySingleton(() => FirestoreService());
  sl.registerLazySingleton(() => ImageCacheService());
  sl.registerLazySingleton(() => CloudinaryService.instance);
}

/// Initialize External dependencies
Future<void> _initExternal() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => FirebaseMessaging.instance);
  sl.registerLazySingleton(() => ImagePicker());
}