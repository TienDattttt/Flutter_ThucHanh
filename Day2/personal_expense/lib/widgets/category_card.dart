import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/transaction_provider.dart';
import '../screens/category_detail_screen.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final double currentSpend;
  final bool showDetails;

  const CategoryCard({
    super.key,
    required this.category,
    required this.currentSpend,
    required this.showDetails,
  });

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final progress = category.limit > 0
        ? (currentSpend / category.limit).clamp(0.0, 1.0)
        : 0.0;
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final isOverLimit = currentSpend > category.limit;

    return InkWell(
      onTap: () {
        // Khi bấm vào, chuyển sang chi tiết Category
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryDetailScreen(categoryId: category.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: category.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: category.color.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // --- Hàng đầu: icon + tên + tổng chi ---
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(category.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    category.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text(
                  _formatCurrency(currentSpend),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // --- Thanh tiến độ ---
            LinearProgressIndicator(
              value: progress,
              backgroundColor: category.color.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverLimit ? Colors.red : category.color,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),

            // --- Chi tiết (tuỳ chọn khi bật "Hiện tiến độ") ---
            if (showDetails) ...[
              const SizedBox(height: 15),
              const Divider(height: 1, color: Colors.grey),
              const SizedBox(height: 15),
              _detailRow('Tổng tiền đã chi',
                  '${_formatCurrency(currentSpend)}₫', Colors.black87),
              _detailRow('Chi tiêu nhiều nhất',
                  provider.getHighestSpendDay(category.id), Colors.red.shade700),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }
}
