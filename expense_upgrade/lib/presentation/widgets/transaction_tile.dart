import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/theme/app_theme.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionTile({
    Key? key,
    required this.transaction,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  color: _getCategoryColor(),
                  size: 24,
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
                        Icon(
                          Icons.category_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          transaction.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatDate(transaction.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Amount and Actions
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        InkWell(
                          onTap: onEdit,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (onDelete != null)
                        InkWell(
                          onTap: onDelete,
                          borderRadius: BorderRadius.circular(16),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (transaction.category.toLowerCase()) {
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

  Color _getCategoryColor() {
    switch (transaction.category.toLowerCase()) {
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
}