import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';
import '../../core/theme/app_theme.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final List<Transaction> transactions;

  const ExpenseSummaryCard({
    Key? key,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final thisWeek = now.subtract(Duration(days: now.weekday - 1));
    final today = DateTime(now.year, now.month, now.day);

    final monthlyExpenses = _calculateExpenses(thisMonth, null);
    final weeklyExpenses = _calculateExpenses(thisWeek, null);
    final dailyExpenses = _calculateExpenses(today, today.add(const Duration(days: 1)));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng quan chi tiêu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white.withOpacity(0.8),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Monthly Expenses
            _buildExpenseRow(
              'Tháng này',
              monthlyExpenses,
              Icons.calendar_month,
              isMain: true,
            ),
            const SizedBox(height: 16),
            
            // Weekly and Daily Expenses
            Row(
              children: [
                Expanded(
                  child: _buildExpenseRow(
                    'Tuần này',
                    weeklyExpenses,
                    Icons.calendar_view_week,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildExpenseRow(
                    'Hôm nay',
                    dailyExpenses,
                    Icons.today,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress indicator for monthly budget (example)
            _buildBudgetProgress(monthlyExpenses),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseRow(
    String label,
    double amount,
    IconData icon, {
    bool isMain = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: isMain ? 20 : 16,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isMain ? 16 : 14,
                color: Colors.white.withOpacity(0.9),
                fontWeight: isMain ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(0)} VNĐ',
          style: TextStyle(
            fontSize: isMain ? 24 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetProgress(double monthlyExpenses) {
    const double monthlyBudget = 10000000; // 10 triệu VNĐ example budget
    final double progress = (monthlyExpenses / monthlyBudget).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ngân sách tháng',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(
            progress > 0.8 ? Colors.red : Colors.white,
          ),
          minHeight: 6,
        ),
        const SizedBox(height: 4),
        Text(
          '${monthlyBudget.toStringAsFixed(0)} VNĐ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  double _calculateExpenses(DateTime start, DateTime? end) {
    return transactions
        .where((transaction) {
          final transactionDate = transaction.date;
          final isAfterStart = transactionDate.isAfter(start) || 
                             transactionDate.isAtSameMomentAs(start);
          
          if (end != null) {
            final isBeforeEnd = transactionDate.isBefore(end);
            return isAfterStart && isBeforeEnd;
          }
          
          return isAfterStart;
        })
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }
}