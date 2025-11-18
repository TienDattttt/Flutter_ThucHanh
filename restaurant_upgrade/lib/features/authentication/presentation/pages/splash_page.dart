import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for 2 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // Check current auth state
      context.read<AuthBloc>().add(AuthCheckRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // User is logged in, navigate to home
            Navigator.of(context).pushReplacementNamed(AppRouter.home);
          } else if (state is AuthUnauthenticated || state is AuthInitial) {
            // User is not logged in, navigate to sign in
            Navigator.of(context).pushReplacementNamed(AppRouter.signIn);
          }
        },
        child: _buildSplashUI(context),
      ),
    );
  }

  Widget _buildSplashUI(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Icon(
              Icons.restaurant,
              size: 120,
              color: Colors.white,
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // App name
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: AppConstants.smallPadding),
            
            // App tagline
            Text(
              'Khám phá và đánh giá nhà hàng',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            
            const SizedBox(height: AppConstants.largePadding * 2),
            
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}