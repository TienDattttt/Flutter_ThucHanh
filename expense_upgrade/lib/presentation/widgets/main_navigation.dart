import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/home_screen.dart';
import '../screens/transaction_screen.dart';
import '../screens/analytics_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../../core/theme/app_theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionScreen(),
    const AnalyticsScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Trang chủ',
    ),
    NavigationItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'Giao dịch',
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Phân tích',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _fabAnimationController.forward();
    
    // Update activity when user interacts and load transactions once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUserActivity();
      _loadTransactionsOnce();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _updateUserActivity() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.updateActivity();
  }

  void _loadTransactionsOnce() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    
    if (authProvider.currentUser != null && !transactionProvider.hasData) {
      transactionProvider.loadTransactions(authProvider.currentUser!.id);
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
    _updateUserActivity();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    _updateUserActivity();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Handle session expiration
        if (authProvider.state == AuthState.sessionExpired) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSessionExpiredDialog();
          });
        }

        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _screens,
          ),
          
          // Bottom Navigation Bar
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: Colors.grey.shade600,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              items: _navigationItems.map((item) {
                final index = _navigationItems.indexOf(item);
                final isSelected = index == _currentIndex;
                
                return BottomNavigationBarItem(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      key: ValueKey(isSelected),
                      size: 24,
                    ),
                  ),
                  label: item.label,
                );
              }).toList(),
            ),
          ),
          

        );
      },
    );
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Phiên đã hết hạn'),
          ],
        ),
        content: const Text(
          'Phiên làm việc của bạn đã hết hạn vì lý do bảo mật. Vui lòng đăng nhập lại.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/auth');
            },
            child: const Text('Đăng nhập lại'),
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}