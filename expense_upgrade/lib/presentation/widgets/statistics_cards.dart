import 'package:flutter/material.dart';
import '../../domain/entities/expense_summary.dart';
import '../../core/theme/app_theme.dart';

class StatisticsCards extends StatelessWidget {
  final ExpenseSummary summary;

  const StatisticsCards({
    Key? key,
    required this.summary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main total card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng chi tiêu',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white.withOpacity(0.8),
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${summary.totalExpenses.toStringAsFixed(0)} VNĐ',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${summary.transactionCount} giao dịch',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Statistics grid
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Trung bình/ngày',
                '${summary.averageDaily.toStringAsFixed(0)} VNĐ',
                Icons.today,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Trung bình/tháng',
                '${summary.averageMonthly.toStringAsFixed(0)} VNĐ',
                Icons.calendar_month,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Highest category card
        if (summary.highestCategory.isNotEmpty)
          _buildHighestCategoryCard(),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: color,
                  size: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighestCategoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(summary.highestCategory),
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Danh mục chi tiêu nhiều nhất',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.highestCategory,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${summary.highestCategoryAmount.toStringAsFixed(0)} VNĐ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Text(
                '${(summary.highestCategoryAmount / summary.totalExpenses * 100).toStringAsFixed(1)}%',
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'ăn uống':
        return Icons.restaurant;
      case 'di chuyển':
        return Icons.directions_car;
      case 'mua sắm':
        return Icons.shopping_bag;
      case 'giải trí':
        return Icons.movie;
      case 'sức khỏe':
        return Icons.local_hospital;
      case 'giáo dục':
        return Icons.school;
      case 'hóa đơn':
        return Icons.receipt;
      case 'tiết kiệm':
        return Icons.savings;
      default:
        return Icons.category;
    }
  }
}