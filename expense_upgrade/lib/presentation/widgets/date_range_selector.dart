import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DateRangeSelector extends StatelessWidget {
  final String selectedPeriod;
  final DateTime startDate;
  final DateTime endDate;
  final Function(String) onPeriodChanged;
  final Function(DateTime, DateTime) onDateRangeChanged;

  const DateRangeSelector({
    Key? key,
    required this.selectedPeriod,
    required this.startDate,
    required this.endDate,
    required this.onPeriodChanged,
    required this.onDateRangeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
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
              const Text(
                'Khoảng thời gian',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Builder(
                builder: (context) => InkWell(
                  onTap: () => _showCustomDatePicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.date_range,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tùy chỉnh',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Period chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Tuần này',
              'Tháng này',
              '3 tháng',
              '6 tháng',
              'Năm này',
            ].map((period) => _buildPeriodChip(period)).toList(),
          ),
          
          // Selected date range display
          if (selectedPeriod == 'Tùy chỉnh')
            Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatDate(startDate)} - ${_formatDate(endDate)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String period) {
    final isSelected = selectedPeriod == period;
    
    return InkWell(
      onTap: () => onPeriodChanged(period),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          period,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  void _showCustomDatePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeChanged(picked.start, picked.end);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}