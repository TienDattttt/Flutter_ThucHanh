import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dayMonthYear = DateFormat('dd/MM/yyyy');
  static final DateFormat _dayMonthYearTime = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYear = DateFormat('MM/yyyy');
  static final DateFormat _dayMonth = DateFormat('dd/MM');
  
  static String formatDate(DateTime date) {
    return _dayMonthYear.format(date);
  }
  
  static String formatDateTime(DateTime date) {
    return _dayMonthYearTime.format(date);
  }
  
  static String formatMonthYear(DateTime date) {
    return _monthYear.format(date);
  }
  
  static String formatDayMonth(DateTime date) {
    return _dayMonth.format(date);
  }
  
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
  
  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hôm nay';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return formatDate(date);
    }
  }
}