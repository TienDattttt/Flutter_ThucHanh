import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  // Định nghĩa tham số 'data' và yêu cầu nó (required)
  final List<Map<String, dynamic>> data;

  const PieChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Tính tổng để xác định tỷ lệ phần trăm
    final total = data.fold(0.0, (sum, item) => sum + (item['value'] as double));

    if (total == 0.0) {
      return const AspectRatio(
        aspectRatio: 1.3,
        child: Center(
          child: Text('Chưa có giao dịch chi tiêu nào.'),
        ),
      );
    }

    // Tạo các Section cho biểu đồ từ dữ liệu động
    List<PieChartSectionData> sections = data.where((item) => (item['value'] as double) > 0).map((item) {
      final value = item['value'] as double;
      final color = item['color'] as Color;
      final percentage = (value / total) * 100;

      return PieChartSectionData(
        value: value,
        color: color,
        // Hiển thị phần trăm (ví dụ: 25.5%)
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: sections,
        ),
      ),
    );
  }
}