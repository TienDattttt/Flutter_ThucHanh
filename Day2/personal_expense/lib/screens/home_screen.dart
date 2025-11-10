import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../widgets/category_card.dart';
import '../screens/add_transaction_screen.dart';
import '../screens/chart_screen.dart';
import '../screens/add_category_screen.dart';
import '../services/firebase_auth_service.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu khi mở ứng dụng
    Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
  }

  void _logout() async {
    await FirebaseAuthService().signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    final pages = [
      CustomScrollView(
        slivers: [
          // --- AppBar gọn nhẹ, không còn phần tổng hợp ---
          SliverAppBar(
            title: const Text(
              'Quản Lý Chi Tiêu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            pinned: true,
            floating: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.black54),
                onPressed: _logout,
                tooltip: 'Đăng xuất',
              ),
            ],
          ),

          // --- Thanh điều khiển hiển thị / thêm danh mục ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => setState(() => _showDetails = !_showDetails),
                    icon: Icon(_showDetails ? Icons.visibility_off : Icons.visibility),
                    label: Text(_showDetails ? 'ẨN TIẾN ĐỘ' : 'HIỆN TIẾN ĐỘ'),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddCategoryScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '+ Thêm Mục',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Danh sách các Category ---
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, i) {
                final category = provider.categories[i];
                final currentSpend =
                provider.getTotalSpendByCategory(category.id);
                return CategoryCard(
                  category: category,
                  currentSpend: currentSpend,
                  showDetails: _showDetails,
                );
              },
              childCount: provider.categories.length,
            ),
          ),

          // --- Khoảng trống tránh che bởi FAB ---
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),

      // --- Trang biểu đồ ---
      const ChartScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Chi tiêu'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Biểu đồ'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddTransactionScreen(),
          ),
        ),
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
