import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../widgets/pie_chart.dart';
import '../widgets/bar_chart.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return formatter.format(amount);
  }

  Widget _buildLegend(List<Map<String, dynamic>> chartData, double totalSpend) {
    if (totalSpend == 0) {
      return const Text("Chưa có giao dịch để phân tích.");
    }

    final validData = chartData.where((e) => (e['value'] as double) > 0).toList()
      ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: validData.length,
      itemBuilder: (context, index) {
        final item = validData[index];
        final value = item['value'] as double;
        final color = item['color'] as Color;
        final percentage = (value / totalSpend) * 100;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "${item['name']}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                "${_formatCurrency(value)}₫ (${percentage.toStringAsFixed(1)}%)",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final categories = provider.categories;
    final totalSpend = provider.totalSpend;

    final chartData = categories.map((cat) {
      final spend = provider.getTotalSpendByCategory(cat.id);
      return {'id': cat.id, 'name': cat.name, 'value': spend, 'color': cat.color};
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 💰 Tổng quan chi tiêu
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tổng chi tiêu tháng này",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${_formatCurrency(totalSpend)}₫",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          // 📈 Phần Biểu đồ tròn và Chi tiết phân bổ
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Phân bổ chi tiêu theo mục",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),

                  PieChartWidget(data: chartData),

                  const SizedBox(height: 30),

                  const Text(
                    "Chi tiết phân bổ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const Divider(height: 20),
                  _buildLegend(chartData, totalSpend),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          // 📊 Biểu đồ cột
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Biểu đồ chi tiêu theo thời gian",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),
                  const BarChartWidget(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}