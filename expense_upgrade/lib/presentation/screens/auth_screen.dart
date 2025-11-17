import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';
import '../../core/constants/app_constants.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Quản lý tài chính cá nhân thông minh',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelColor: Theme.of(context).colorScheme.onPrimary,
                    unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    tabs: const [
                      Tab(text: 'Đăng nhập'),
                      Tab(text: 'Đăng ký'),
                    ],
                  ),
                ),
                
                // Error Message
                if (authProvider.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authProvider.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: authProvider.clearError,
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      LoginForm(),
                      RegisterForm(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}