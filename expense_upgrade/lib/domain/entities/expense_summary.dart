class ExpenseSummary {
  final double totalExpenses;
  final double averageDaily;
  final double averageMonthly;
  final String highestCategory;
  final double highestCategoryAmount;
  final int transactionCount;
  
  const ExpenseSummary({
    required this.totalExpenses,
    required this.averageDaily,
    required this.averageMonthly,
    required this.highestCategory,
    required this.highestCategoryAmount,
    required this.transactionCount,
  });
  
  // Backward compatibility getters
  double get totalAmount => totalExpenses;
  double get averagePerDay => averageDaily;
  double get averagePerTransaction => transactionCount > 0 ? totalExpenses / transactionCount : 0;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ExpenseSummary &&
        other.totalExpenses == totalExpenses &&
        other.averageDaily == averageDaily &&
        other.averageMonthly == averageMonthly &&
        other.highestCategory == highestCategory &&
        other.highestCategoryAmount == highestCategoryAmount &&
        other.transactionCount == transactionCount;
  }
  
  @override
  int get hashCode {
    return totalExpenses.hashCode ^
        averageDaily.hashCode ^
        averageMonthly.hashCode ^
        highestCategory.hashCode ^
        highestCategoryAmount.hashCode ^
        transactionCount.hashCode;
  }
  
  @override
  String toString() {
    return 'ExpenseSummary(totalExpenses: $totalExpenses, averageDaily: $averageDaily, averageMonthly: $averageMonthly, highestCategory: $highestCategory, highestCategoryAmount: $highestCategoryAmount, transactionCount: $transactionCount)';
  }
}