import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/restaurants/presentation/bloc/restaurant_bloc.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/pages/sign_in_page.dart';
import '../../features/authentication/presentation/pages/sign_up_page.dart';
import '../../features/restaurants/presentation/pages/restaurant_list_page.dart';
import '../../features/restaurants/presentation/pages/simple_restaurant_list_page.dart';
import '../../features/restaurants/presentation/pages/restaurant_detail_page.dart';
import '../../features/reviews/presentation/pages/add_review_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/admin/presentation/pages/admin_page.dart';
import '../../injection_container.dart' as di;

class AppRouter {
  static const String splash = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String home = '/home';
  static const String restaurantDetail = '/restaurant-detail';
  static const String addReview = '/add-review';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String admin = '/admin';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
        );

      case signIn:
        return MaterialPageRoute(
          builder: (_) => const SignInPage(),
        );

      case signUp:
        return MaterialPageRoute(
          builder: (_) => const SignUpPage(),
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const MainPage(),
        );

      case restaurantDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final restaurantId = args?['restaurantId'] as String?;
        if (restaurantId == null) {
          return _errorRoute('Restaurant ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => RestaurantDetailPage(restaurantId: restaurantId),
        );

      case addReview:
        final args = settings.arguments as Map<String, dynamic>?;
        final restaurantId = args?['restaurantId'] as String?;
        if (restaurantId == null) {
          return _errorRoute('Restaurant ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => AddReviewPage(restaurantId: restaurantId),
        );

      case notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsPage(),
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
        );

      case admin:
        return MaterialPageRoute(
          builder: (_) => const AdminPage(),
        );

      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(message),
        ),
      ),
    );
  }
}



class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<RestaurantBloc>()),
        BlocProvider(create: (_) => di.sl<NotificationBloc>()),
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            SimpleRestaurantListPage(),
            NotificationsPage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant),
              label: 'Nhà hàng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Thông báo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Hồ sơ',
            ),
          ],
        ),
      ),
    );
  }
}