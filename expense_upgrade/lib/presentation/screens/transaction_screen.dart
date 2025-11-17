import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/filter_bar.dart';
import '../../domain/entities/transaction.dart';
import '../../core/theme/app_theme.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'Tất cả';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoadingMore = false;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTransactions();
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        await transactionProvider.loadMoreTransactions(
          authProvider.currentUser!.id,
          pageSize: _pageSize,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải thêm dữ liệu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<TransactionProvider, AuthProvider>(
        builder: (context, transactionProvider, authProvider, child) {
          if (authProvider.currentUser == null) {
            return const Center(
              child: Text('Vui lòng đăng nhập để xem giao dịch'),
            );
          }

          if (transactionProvider.isLoading && transactionProvider.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (transactionProvider.errorMessage != null) {
            return _buildErrorView(transactionProvider, authProvider);
          }

          final filteredTransactions = _filterTransactions(transactionProvider.transactions);

          if (filteredTransactions.isEmpty) {
            return _buildEmptyView();
          }

          return _buildTransactionList(filteredTransactions, transactionProvider, authProvider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "transaction_fab",
        onPressed: () {
          Navigator.pushNamed(context, '/add-transaction');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTransactionList(
    List<Transaction> transactions,
    TransactionProvider transactionProvider,
    AuthProvider authProvider,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await transactionProvider.loadTransactions(
          authProvider.currentUser!.id,
        );
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            title: const Text('Lịch sử Giao dịch'),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            floating: true,
            snap: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _showSearchDialog,
              ),
            ],
          ),

          // Filter Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: FilterBarDelegate(
              selectedCategory: _selectedCategory,
              startDate: _startDate,
              endDate: _endDate,
              onCategoryChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              onDateRangeChanged: (start, end) {
                setState(() {
                  _startDate = start;
                  _endDate = end;
                });
              },
            ),
          ),

          // Transaction List
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < transactions.length) {
                    final transaction = transactions[index];
                    return TransactionTile(
                      transaction: transaction,
                      onTap: () => _showTransactionDetails(transaction),
                      onEdit: () => _editTransaction(transaction),
                      onDelete: () => _deleteTransaction(transaction),
                    );
                  } else if (_isLoadingMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return null;
                },
                childCount: transactions.length + (_isLoadingMore ? 1 : 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(
    TransactionProvider transactionProvider,
    AuthProvider authProvider,
  ) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Lịch sử Giao dịch'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Có lỗi xảy ra khi tải dữ liệu',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    transactionProvider.loadTransactions(
                      authProvider.currentUser!.id,
                    );
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyView() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Lịch sử Giao dịch'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chưa có giao dịch nào',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Thêm giao dịch đầu tiên của bạn',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add-transaction');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm giao dịch'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    List<Transaction> filtered = transactions;

    // Filter by category
    if (_selectedCategory != 'Tất cả') {
      filtered = filtered.where((t) => t.category == _selectedCategory).toList();
    }

    // Filter by date range
    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((t) {
        return t.date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
               t.date.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Sort by date (most recent first)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lọc giao dịch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Danh mục',
                border: OutlineInputBorder(),
              ),
              items: ['Tất cả', 'Ăn uống', 'Di chuyển', 'Mua sắm', 'Giải trí', 'Khác']
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Từ ngày',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: _startDate?.toString().split(' ')[0] ?? '',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Đến ngày',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: _endDate?.toString().split(' ')[0] ?? '',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: _startDate ?? DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = 'Tất cả';
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Xóa bộ lọc'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Áp dụng'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    String searchQuery = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tìm kiếm giao dịch'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Nhập mô tả giao dịch...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            searchQuery = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement search functionality
              Navigator.pop(context);
            },
            child: const Text('Tìm kiếm'),
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
            Text('Ngày: ${transaction.date.toString().split(' ')[0]}'),
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

  void _editTransaction(Transaction transaction) {
    Navigator.pushNamed(
      context,
      '/add-transaction',
      arguments: transaction,
    );
  }

  void _deleteTransaction(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa giao dịch'),
        content: const Text('Bạn có chắc chắn muốn xóa giao dịch này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await Provider.of<TransactionProvider>(context, listen: false)
                    .deleteTransaction(transaction.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa giao dịch')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: $e')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}