import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final transactions = provider.transactions;

    // Nếu chưa có dữ liệu
    if (transactions.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Chưa có dữ liệu chi tiêu tuần này')),
      );
    }

    // Lấy ngày hiện tại
    final now = DateTime.now();

    // Gom nhóm chi tiêu trong 7 ngày gần nhất
    Map<String, double> weeklySpend = {};
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayKey = DateFormat('yyyy-MM-dd').format(day);
      weeklySpend[dayKey] = 0.0;
    }

    // Cộng dồn chi tiêu theo từng ngày
    for (TransactionModel tx in transactions) {
      final txKey = DateFormat('yyyy-MM-dd').format(tx.date);
      if (weeklySpend.containsKey(txKey)) {
        weeklySpend[txKey] = (weeklySpend[txKey] ?? 0) + tx.amount;
      }
    }

    final days = weeklySpend.keys.toList();
    final values = weeklySpend.values.toList();
    final maxSpend = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0.0;
    final primaryColor = Theme.of(context).primaryColor;

    List<BarChartGroupData> barGroups = List.generate(values.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: values[index] / 100000.0, // chia để biểu đồ cân đối
            color: primaryColor,
            width: 15,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    return SizedBox(
      height: 250,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxSpend / 100000.0 * 1.2,
              barGroups: barGroups,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      // Chuyển ngày về thứ (T2..CN)
                      final index = value.toInt();
                      if (index < 0 || index >= days.length) return const SizedBox();
                      final date = DateTime.parse(days[index]);
                      final weekday = DateFormat.E('vi_VN').format(date); // vd: Th 2, Th 3
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(weekday, style: const TextStyle(fontSize: 12)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${(value * 100000 / 1000000).toStringAsFixed(1)}M',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barTouchData: BarTouchData(enabled: true),
            ),
          ),
        ),
      ),
    );
  }
}
