import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/restaurants/presentation/providers/auth_provider.dart';
import 'features/restaurants/presentation/providers/restaurant_provider.dart';
import 'features/restaurants/presentation/providers/review_provider.dart';
import 'features/restaurants/domain/usecases/get_restaurants.dart';
import 'features/restaurants/domain/usecases/get_reviews_for_restaurant.dart';
import 'features/restaurants/domain/usecases/add_review.dart';
import 'features/restaurants/data/datasources/restaurant_remote_ds.dart';
import 'features/restaurants/data/datasources/review_remote_ds.dart';
import 'features/restaurants/data/repositories/restaurant_repository_impl.dart';
import 'features/restaurants/data/repositories/review_repository_impl.dart';
import 'features/restaurants/presentation/screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurantRepo = RestaurantRepositoryImpl(RestaurantRemoteDataSource());
    final reviewRepo = ReviewRepositoryImpl();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), // ✅ Bổ sung
        ChangeNotifierProvider(create: (_) => RestaurantProvider(GetRestaurants(restaurantRepo))),
        ChangeNotifierProvider(
          create: (_) => ReviewProvider(
            getReviews: GetReviewsForRestaurant(reviewRepo),
            addReviewUseCase: AddReview(reviewRepo),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.orange),
        home: const SplashScreen(), // ✅ Chạy từ Splash
      ),
    );
  }
}
