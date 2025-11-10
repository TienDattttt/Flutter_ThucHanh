import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryId;

  const CategoryDetailScreen({super.key, required this.categoryId});

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final category = provider.getCategoryById(categoryId);

    // Danh sách giao dịch của Category
    final List<TransactionModel> transactions = provider.transactions
        .where((t) => t.categoryId == categoryId)
        .toList();

    final currentSpend = provider.getTotalSpendByCategory(categoryId);

    // Tiến độ chi tiêu (tính theo limit, nếu có)
    final progress = category.limit > 0
        ? (currentSpend / category.limit).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: category.color,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Header đơn giản chỉ hiển thị "Đã chi" + tiến độ
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: category.color,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dòng "Đã chi"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Đã chi:",
                      style: TextStyle(fontSize: 15, color: Colors.white70),
                    ),
                    Text(
                      "${_formatCurrency(currentSpend)}₫",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellowAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Thanh tiến độ
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white38,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0 ? Colors.red.shade900 : Colors.white,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(top: 15, left: 15, bottom: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Lịch sử giao dịch:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Danh sách giao dịch
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text('Chưa có giao dịch nào.'))
                : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return TransactionCard(transaction: transaction);
              },
            ),
          ),
        ],
      ),

      // Nút thêm giao dịch
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => AddTransactionScreen(categoryId: categoryId),
            ),
          );
        },
        backgroundColor: category.color,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
