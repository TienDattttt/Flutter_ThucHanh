import '../entities/transaction.dart';
import '../entities/chart_data.dart';
import '../entities/expense_summary.dart';
import '../../core/errors/exceptions.dart';
import 'package:flutter/material.dart';

class AnalyticsUseCase {
  
  /// Calculate expense distribution by category for pie chart
  List<ChartData> calculateCategoryDistribution(List<Transaction> transactions) {
    if (transactions.isEmpty) return [];

    final Map<String, double> categoryTotals = {};
    final Map<String, Color> categoryColors = {
      'Ăn uống': Colors.orange,
      'Di chuyển': Colors.blue,
      'Mua sắm': Colors.purple,
      'Giải trí': Colors.pink,
      'Sức khỏe': Colors.red,
      'Giáo dục': Colors.green,
      'Hóa đơn': Colors.brown,
      'Tiết kiệm': Colors.teal,
      'Khác': Colors.grey,
    };

    // Group transactions by category
    for (final transaction in transactions) {
      final category = transaction.category;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + transaction.amount;
    }

    // Convert to ChartData list
    final chartData = categoryTotals.entries.map((entry) {
      return ChartData(
        label: entry.key,
        value: entry.value,
        color: categoryColors[entry.key] ?? Colors.grey,
      );
    }).toList();

    // Sort by value (descending)
    chartData.sort((a, b) => b.value.compareTo(a.value));

    return chartData;
  }

  /// Calculate daily expenses for line chart
  List<ChartData> calculateDailyExpenses(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    if (transactions.isEmpty) return [];

    final Map<String, double> dailyTotals = {};
    
    // Initialize all days in range with 0
    DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    
    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      final dateKey = _formatDateKey(currentDate);
      dailyTotals[dateKey] = 0.0;
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Add transaction amounts to corresponding days
    for (final transaction in transactions) {
      final transactionDate = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      
      if (transactionDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          transactionDate.isBefore(endDate.add(const Duration(days: 1)))) {
        final dateKey = _formatDateKey(transactionDate);
        dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + transaction.amount;
      }
    }

    // Convert to ChartData list
    final sortedEntries = dailyTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sortedEntries.map((entry) {
      return ChartData(
        label: _formatDisplayDate(entry.key),
        value: entry.value,
        color: Colors.blue,
      );
    }).toList();
  }

  /// Calculate weekly expenses for line chart
  List<ChartData> calculateWeeklyExpenses(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    if (transactions.isEmpty) return [];

    final Map<String, double> weeklyTotals = {};
    
    // Group transactions by week
    for (final transaction in transactions) {
      if (transaction.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(endDate.add(const Duration(days: 1)))) {
        final weekKey = _getWeekKey(transaction.date);
        weeklyTotals[weekKey] = (weeklyTotals[weekKey] ?? 0) + transaction.amount;
      }
    }

    // Convert to ChartData list
    final sortedEntries = weeklyTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sortedEntries.map((entry) {
      return ChartData(
        label: entry.key,
        value: entry.value,
        color: Colors.green,
      );
    }).toList();
  }

  /// Calculate monthly expenses for line chart
  List<ChartData> calculateMonthlyExpenses(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    if (transactions.isEmpty) return [];

    final Map<String, double> monthlyTotals = {};
    
    // Group transactions by month
    for (final transaction in transactions) {
      if (transaction.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(endDate.add(const Duration(days: 1)))) {
        final monthKey = _getMonthKey(transaction.date);
        monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + transaction.amount;
      }
    }

    // Convert to ChartData list
    final sortedEntries = monthlyTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sortedEntries.map((entry) {
      return ChartData(
        label: entry.key,
        value: entry.value,
        color: Colors.purple,
      );
    }).toList();
  }

  /// Calculate expense summary statistics
  ExpenseSummary calculateExpenseSummary(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return ExpenseSummary(
        totalExpenses: 0,
        averageDaily: 0,
        averageMonthly: 0,
        highestCategory: '',
        highestCategoryAmount: 0,
        transactionCount: 0,
      );
    }

    final totalExpenses = transactions.fold(0.0, (sum, t) => sum + t.amount);
    final transactionCount = transactions.length;

    // Calculate date range
    final dates = transactions.map((t) => t.date).toList()..sort();
    final daysDifference = dates.last.difference(dates.first).inDays + 1;
    final averageDaily = totalExpenses / daysDifference;
    final averageMonthly = averageDaily * 30;

    // Find highest spending category
    final categoryTotals = <String, double>{};
    for (final transaction in transactions) {
      categoryTotals[transaction.category] = 
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    String highestCategory = '';
    double highestCategoryAmount = 0;
    
    categoryTotals.forEach((category, amount) {
      if (amount > highestCategoryAmount) {
        highestCategory = category;
        highestCategoryAmount = amount;
      }
    });

    return ExpenseSummary(
      totalExpenses: totalExpenses,
      averageDaily: averageDaily,
      averageMonthly: averageMonthly,
      highestCategory: highestCategory,
      highestCategoryAmount: highestCategoryAmount,
      transactionCount: transactionCount,
    );
  }

  /// Filter transactions by date range
  List<Transaction> filterTransactionsByDateRange(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    return transactions.where((transaction) {
      return transaction.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             transaction.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Filter transactions by category
  List<Transaction> filterTransactionsByCategory(
    List<Transaction> transactions,
    String category,
  ) {
    if (category.isEmpty || category == 'Tất cả') {
      return transactions;
    }
    
    return transactions.where((transaction) {
      return transaction.category == category;
    }).toList();
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(String dateKey) {
    final parts = dateKey.split('-');
    if (parts.length != 3) return dateKey;
    
    final day = parts[2];
    final month = parts[1];
    return '$day/$month';
  }

  String _getWeekKey(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return '${startOfWeek.day}/${startOfWeek.month} - ${endOfWeek.day}/${endOfWeek.month}';
  }

  String _getMonthKey(DateTime date) {
    const monthNames = [
      '', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6',
      'T7', 'T8', 'T9', 'T10', 'T11', 'T12'
    ];
    
    return '${monthNames[date.month]}/${date.year}';
  }

  /// Calculate spending comparison between two periods
  Map<String, dynamic> calculatePeriodComparison(
    List<Transaction> currentPeriodTransactions,
    List<Transaction> previousPeriodTransactions,
  ) {
    final currentTotal = currentPeriodTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final previousTotal = previousPeriodTransactions.fold(0.0, (sum, t) => sum + t.amount);
    
    final difference = currentTotal - previousTotal;
    final percentageChange = previousTotal > 0 ? (difference / previousTotal * 100) : 0.0;
    
    return {
      'currentTotal': currentTotal,
      'previousTotal': previousTotal,
      'difference': difference,
      'percentageChange': percentageChange,
      'isIncrease': difference > 0,
    };
  }

  /// Get top spending categories with their percentages
  List<Map<String, dynamic>> getTopSpendingCategories(
    List<Transaction> transactions, {
    int limit = 5,
  }) {
    if (transactions.isEmpty) return [];

    final categoryTotals = <String, double>{};
    final totalAmount = transactions.fold(0.0, (sum, t) => sum + t.amount);

    // Group by category
    for (final transaction in transactions) {
      categoryTotals[transaction.category] = 
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    // Convert to list and sort
    final sortedCategories = categoryTotals.entries
        .map((entry) => {
              'category': entry.key,
              'amount': entry.value,
              'percentage': totalAmount > 0 ? (entry.value / totalAmount * 100) : 0.0,
              'transactionCount': transactions
                  .where((t) => t.category == entry.key)
                  .length,
            })
        .toList()
      ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    return sortedCategories.take(limit).toList();
  }

  /// Calculate average transaction amount by category
  Map<String, double> calculateAverageTransactionByCategory(
    List<Transaction> transactions,
  ) {
    if (transactions.isEmpty) return {};

    final categoryTotals = <String, double>{};
    final categoryCounts = <String, int>{};

    for (final transaction in transactions) {
      final category = transaction.category;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + transaction.amount;
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    final averages = <String, double>{};
    categoryTotals.forEach((category, total) {
      final count = categoryCounts[category] ?? 1;
      averages[category] = total / count;
    });

    return averages;
  }
}