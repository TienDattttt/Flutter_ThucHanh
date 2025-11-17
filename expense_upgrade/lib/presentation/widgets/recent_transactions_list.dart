import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/theme/app_theme.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(Transaction)? onTransactionTap;

  const RecentTransactionsList({
    Key? key,
    required this.transactions,
    this.onTransactionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có giao dịch nào',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Thêm giao dịch đầu tiên của bạn',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: transactions.map((transaction) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: _buildTransactionItem(transaction),
        );
      }).toList(),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return InkWell(
      onTap: () => onTransactionTap?.call(transaction),
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
            // Category Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getCategoryColor(transaction.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                _getCategoryIcon(transaction.category),
                color: _getCategoryColor(transaction.category),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            
            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description.isNotEmpty 
                        ? transaction.description 
                        : transaction.category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        transaction.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormatter.formatDate(transaction.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-${transaction.amount.toStringAsFixed(0)} VNĐ',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(transaction.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRelativeTime(transaction.date),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getCategoryColor(transaction.category),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'ăn uống':
        return Colors.orange;
      case 'di chuyển':
        return Colors.blue;
      case 'mua sắm':
        return Colors.purple;
      case 'giải trí':
        return Colors.pink;
      case 'sức khỏe':
        return Colors.red;
      case 'giáo dục':
        return Colors.green;
      case 'hóa đơn':
        return Colors.brown;
      case 'tiết kiệm':
        return Colors.teal;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}p';
      }
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày';
    } else {
      return DateFormatter.formatDate(date);
    }
  }
}