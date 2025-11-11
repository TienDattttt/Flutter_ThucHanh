import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'restaurant_list_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // ✅ Hiển thị loading khi kiểm tra trạng thái
    return FutureBuilder(
      future: Future.delayed(const Duration(seconds: 1)),
      builder: (_, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ Nếu đã login → vào list, ngược lại → login
        if (auth.isLoggedIn) {
          return const RestaurantListScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
