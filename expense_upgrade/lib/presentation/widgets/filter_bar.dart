import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final String selectedCategory;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(String) onCategoryChanged;
  final Function(DateTime?, DateTime?) onDateRangeChanged;

  FilterBarDelegate({
    required this.selectedCategory,
    required this.startDate,
    required this.endDate,
    required this.onCategoryChanged,
    required this.onDateRangeChanged,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Category Filter
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        items: [
                          'Tất cả',
                          'Ăn uống',
                          'Di chuyển',
                          'Mua sắm',
                          'Giải trí',
                          'Sức khỏe',
                          'Giáo dục',
                          'Hóa đơn',
                          'Khác'
                        ].map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(
                                category,
                                style: const TextStyle(fontSize: 14),
                              ),
                            )).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            onCategoryChanged(value);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Date Range Filter
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: () => _showDateRangePicker(context),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.date_range,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getDateRangeText(),
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Clear Filters Button
                if (selectedCategory != 'Tất cả' || startDate != null || endDate != null)
                  InkWell(
                    onTap: _clearFilters,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.clear,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }

  String _getDateRangeText() {
    if (startDate == null && endDate == null) {
      return 'Chọn khoảng thời gian';
    }
    
    if (startDate != null && endDate != null) {
      return '${_formatDate(startDate!)} - ${_formatDate(endDate!)}';
    }
    
    if (startDate != null) {
      return 'Từ ${_formatDate(startDate!)}';
    }
    
    if (endDate != null) {
      return 'Đến ${_formatDate(endDate!)}';
    }
    
    return 'Chọn khoảng thời gian';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _clearFilters() {
    onCategoryChanged('Tất cả');
    onDateRangeChanged(null, null);
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
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

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate != this;
  }
}