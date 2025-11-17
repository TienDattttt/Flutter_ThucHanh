import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/pie_chart_painter.dart';
import '../widgets/line_chart_painter.dart';
import '../widgets/statistics_cards.dart';
import '../widgets/date_range_selector.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/chart_data.dart';
import '../../domain/usecases/analytics_usecase.dart';
import '../../core/theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AnalyticsUseCase _analyticsUseCase = AnalyticsUseCase();
  
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedPeriod = 'Tháng này';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _updateDateRange();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateDateRange() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Tuần này':
        _startDate = now.subtract(Duration(days: now.weekday - 1));
        _endDate = now;
        break;
      case 'Tháng này':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
        break;
      case '3 tháng':
        _startDate = DateTime(now.year, now.month - 2, 1);
        _endDate = now;
        break;
      case '6 tháng':
        _startDate = DateTime(now.year, now.month - 5, 1);
        _endDate = now;
        break;
      case 'Năm này':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = now;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân tích Chi tiêu'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Tổng quan'),
            Tab(text: 'Danh mục'),
            Tab(text: 'Xu hướng'),
          ],
        ),
      ),
      body: Consumer2<TransactionProvider, AuthProvider>(
        builder: (context, transactionProvider, authProvider, child) {
          if (authProvider.currentUser == null) {
            return const Center(
              child: Text('Vui lòng đăng nhập để xem phân tích'),
            );
          }

          if (transactionProvider.isLoading && transactionProvider.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (transactionProvider.errorMessage != null) {
            return _buildErrorView(transactionProvider.errorMessage!);
          }

          final allTransactions = transactionProvider.transactions;
          final filteredTransactions = _analyticsUseCase
              .filterTransactionsByDateRange(allTransactions, _startDate, _endDate);

          if (filteredTransactions.isEmpty) {
            return _buildEmptyView();
          }

          return Column(
            children: [
              // Date Range Selector
              DateRangeSelector(
                selectedPeriod: _selectedPeriod,
                startDate: _startDate,
                endDate: _endDate,
                onPeriodChanged: (period) {
                  setState(() {
                    _selectedPeriod = period;
                    _updateDateRange();
                  });
                },
                onDateRangeChanged: (start, end) {
                  setState(() {
                    _startDate = start;
                    _endDate = end;
                    _selectedPeriod = 'Tùy chỉnh';
                  });
                },
              ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(filteredTransactions),
                    _buildCategoryTab(filteredTransactions),
                    _buildTrendTab(filteredTransactions),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(List<Transaction> transactions) {
    final summary = _analyticsUseCase.calculateExpenseSummary(transactions);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards
          StatisticsCards(summary: summary),
          const SizedBox(height: 24),
          
          // Category Distribution (Mini Pie Chart)
          const Text(
            'Phân bố theo danh mục',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _tabController.animateTo(1), // Navigate to category tab
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: PieChart(
                      data: _analyticsUseCase.calculateCategoryDistribution(transactions),
                      showLabels: false,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.open_in_full,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Recent Trend (Mini Line Chart)
          const Text(
            'Xu hướng gần đây',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _tabController.animateTo(2), // Navigate to trend tab
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineChart(
                      data: _analyticsUseCase.calculateDailyExpenses(
                        transactions,
                        _startDate,
                        _endDate,
                      ),
                      showGrid: false,
                      showDots: false,
                      lineColor: AppTheme.primaryColor,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.open_in_full,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(List<Transaction> transactions) {
    final categoryData = _analyticsUseCase.calculateCategoryDistribution(transactions);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pie Chart
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: PieChart(
                data: categoryData,
                showLabels: true,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Category List
          const Text(
            'Chi tiết theo danh mục',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...categoryData.map((data) => _buildCategoryItem(data, transactions)),
        ],
      ),
    );
  }

  Widget _buildTrendTab(List<Transaction> transactions) {
    List<ChartData> trendData;
    String chartTitle;
    
    switch (_selectedPeriod) {
      case 'Tuần này':
        trendData = _analyticsUseCase.calculateDailyExpenses(transactions, _startDate, _endDate);
        chartTitle = 'Chi tiêu theo ngày';
        break;
      case 'Tháng này':
      case '3 tháng':
        trendData = _analyticsUseCase.calculateDailyExpenses(transactions, _startDate, _endDate);
        chartTitle = 'Chi tiêu theo ngày';
        break;
      case '6 tháng':
      case 'Năm này':
        trendData = _analyticsUseCase.calculateMonthlyExpenses(transactions, _startDate, _endDate);
        chartTitle = 'Chi tiêu theo tháng';
        break;
      default:
        trendData = _analyticsUseCase.calculateDailyExpenses(transactions, _startDate, _endDate);
        chartTitle = 'Chi tiêu theo ngày';
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chartTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Line Chart
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: LineChart(
              data: trendData,
              lineColor: AppTheme.primaryColor,
              showGrid: true,
              showDots: true,
            ),
          ),
          const SizedBox(height: 24),
          
          // Trend Analysis
          _buildTrendAnalysis(trendData),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(ChartData data, List<Transaction> allTransactions) {
    final categoryTransactions = allTransactions
        .where((t) => t.category == data.label)
        .length;
    
    final totalAmount = allTransactions
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final percentage = totalAmount > 0 ? (data.value / totalAmount * 100) : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: data.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$categoryTransactions giao dịch',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${data.value.toStringAsFixed(0)} VNĐ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis(List<ChartData> trendData) {
    if (trendData.length < 2) {
      return const SizedBox.shrink();
    }
    
    final firstValue = trendData.first.value;
    final lastValue = trendData.last.value;
    final change = lastValue - firstValue;
    final changePercent = firstValue > 0 ? (change / firstValue * 100) : 0.0;
    
    final isIncrease = change > 0;
    final changeColor = isIncrease ? Colors.red : Colors.green;
    final changeIcon = isIncrease ? Icons.trending_up : Icons.trending_down;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phân tích xu hướng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                changeIcon,
                color: changeColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${isIncrease ? 'Tăng' : 'Giảm'} ${changePercent.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: changeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'So với ${_selectedPeriod.toLowerCase()}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Lỗi: $error',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              if (authProvider.currentUser != null) {
                Provider.of<TransactionProvider>(context, listen: false)
                    .loadTransactions(authProvider.currentUser!.id);
              }
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có dữ liệu để phân tích',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm giao dịch để xem phân tích chi tiêu',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
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
    );
  }
}