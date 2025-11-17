import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/quick_add_button.dart';
import '../../domain/entities/transaction.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _loadData() async {
    // Refresh data if needed
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    
    if (authProvider.currentUser != null && !transactionProvider.hasData) {
      await transactionProvider.loadTransactions(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Chi tiêu'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    authProvider.currentUser?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      _showProfileDialog();
                      break;
                    case 'logout':
                      _logout();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('Thông tin cá nhân'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Đăng xuất'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer2<TransactionProvider, AuthProvider>(
        builder: (context, transactionProvider, authProvider, child) {
          if (authProvider.currentUser == null) {
            return const Center(
              child: Text('Vui lòng đăng nhập để sử dụng ứng dụng'),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Message
                  _buildWelcomeMessage(authProvider.currentUser!.displayName ?? 'Người dùng'),
                  const SizedBox(height: 20),

                  // Expense Summary Card
                  ExpenseSummaryCard(transactions: transactionProvider.transactions),
                  const SizedBox(height: 20),

                  // Quick Actions
                  _buildQuickActions(),
                  const SizedBox(height: 20),

                  // Recent Transactions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Giao dịch gần đây',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/transactions');
                        },
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  transactionProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : transactionProvider.errorMessage != null
                          ? Center(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Lỗi: ${transactionProvider.errorMessage}',
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: _loadData,
                                    child: const Text('Thử lại'),
                                  ),
                                ],
                              ),
                            )
                          : RecentTransactionsList(
                              transactions: transactionProvider.transactions.take(5).toList(),
                              onTransactionTap: (transaction) {
                                _showTransactionDetails(transaction);
                              },
                            ),
                ],
              ),
            ),
          );
        },
      ),

    );
  }

  Widget _buildWelcomeMessage(String userName) {
    final now = DateTime.now();
    String greeting;
    
    if (now.hour < 12) {
      greeting = 'Chào buổi sáng';
    } else if (now.hour < 18) {
      greeting = 'Chào buổi chiều';
    } else {
      greeting = 'Chào buổi tối';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $userName!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatDate(now),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.waving_hand,
            size: 32,
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thao tác nhanh',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.add,
                title: 'Thêm giao dịch',
                subtitle: 'Ghi lại chi tiêu mới',
                color: Colors.green,
                onTap: () {
                  Navigator.pushNamed(context, '/add-transaction');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.analytics,
                title: 'Phân tích',
                subtitle: 'Xem báo cáo chi tiêu',
                color: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(context, '/analytics');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin cá nhân'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tên: ${user?.displayName ?? 'Chưa cập nhật'}'),
            const SizedBox(height: 8),
            Text('Email: ${user?.email ?? 'Chưa cập nhật'}'),
            const SizedBox(height: 8),
            Text('Ngày tạo: ${user?.createdAt != null ? DateFormatter.formatDate(user!.createdAt) : 'Chưa cập nhật'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết giao dịch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Số tiền: ${transaction.amount.toStringAsFixed(0)} VNĐ'),
            const SizedBox(height: 8),
            Text('Danh mục: ${transaction.category}'),
            const SizedBox(height: 8),
            Text('Mô tả: ${transaction.description}'),
            const SizedBox(height: 8),
            Text('Ngày: ${DateFormatter.formatDate(transaction.date)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/add-transaction',
                arguments: transaction,
              );
            },
            child: const Text('Chỉnh sửa'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<AuthProvider>(context, listen: false).signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/auth');
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi đăng xuất: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}