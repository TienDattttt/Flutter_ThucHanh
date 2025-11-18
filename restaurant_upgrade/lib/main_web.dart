import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/navigation/app_router.dart';
import 'shared/theme/app_theme.dart';

void main() {
  runApp(const RestaurantReviewApp());
}

class RestaurantReviewApp extends StatelessWidget {
  const RestaurantReviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}