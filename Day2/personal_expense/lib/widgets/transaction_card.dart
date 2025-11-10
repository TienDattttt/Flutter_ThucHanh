import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Cần import Provider
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart'; // Cần import Provider

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  // Xóa 'showProgress' vì đây là Card giao dịch đơn, không phải tổng quan tiến độ

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin Category từ Provider dựa trên categoryId
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final category = provider.getCategoryById(transaction.categoryId);

    return Card(
      // Dùng màu của Category
      color: category.color.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        // Dùng icon của Category
        leading: Icon(category.icon, color: category.color),

        // Dùng tên của Category
        title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),

        // Hiển thị mô tả và ngày giờ
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mô tả: ${transaction.description.isEmpty ? '(Không có mô tả)' : transaction.description}",
                style: TextStyle(color: Colors.grey.shade600)),
            Text("Ngày: ${DateFormat('dd/MM/yyyy HH:mm').format(transaction.date)}"),
          ],
        ),

        // Hiển thị số tiền
        trailing: Text(
          "-${NumberFormat('#,##0', 'vi_VN').format(transaction.amount)}₫",
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}