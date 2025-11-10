import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../services/hive_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];

  static const String categoryBoxName = 'categories';
  static const String transactionBoxName = 'transactions';

  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;

  static Future<void> initDefaultCategories() async {
    final categoryBox = await HiveService.openBox(categoryBoxName);
    if (categoryBox.isEmpty) {
      final defaultData = [
        {'id': 'c1', 'name': 'Ăn uống', 'icon': Icons.restaurant.codePoint, 'color': 0xFFFF6F61, 'limit': 2400000.0},
        {'id': 'c2', 'name': 'Tiêu dùng chung', 'icon': Icons.shopping_bag.codePoint, 'color': 0xFFFF9800, 'limit': 1500000.0},
        {'id': 'c3', 'name': 'Điện thoại', 'icon': Icons.phone_android.codePoint, 'color': 0xFF81C784, 'limit': 150000.0},
        {'id': 'c4', 'name': 'Điện nước', 'icon': Icons.water_drop.codePoint, 'color': 0xFF4FC3F7, 'limit': 800000.0},
      ];
      for (var data in defaultData) {
        await categoryBox.put(data['id'], data);
      }
    }
  }

  Future<void> loadCategories() async {
    final categoryBox = await HiveService.openBox(categoryBoxName);
    _categories = categoryBox.values.map((data) => CategoryModel(
      id: data['id'] as String,
      name: data['name'] as String,
      icon: IconData(data['icon'] as int, fontFamily: 'MaterialIcons'),
      color: Color(data['color'] as int),
      limit: data['limit'] as double,
    )).toList();
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    await loadCategories();
    final box = await HiveService.openBox<TransactionModel>(transactionBoxName);
    _transactions = box.values.toList();
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addCategory(CategoryModel category) async {
    final categoryBox = await HiveService.openBox(categoryBoxName);
    final data = {
      'id': category.id,
      'name': category.name,
      'icon': category.icon.codePoint,
      'color': category.color.value,
      'limit': category.limit,
    };
    await categoryBox.put(category.id, data);
    await loadCategories();
  }

  Future<void> addTransaction(TransactionModel tx) async {
    final box = await HiveService.openBox<TransactionModel>(transactionBoxName);
    await box.add(tx);
    await loadTransactions();
  }

  CategoryModel getCategoryById(String id) {
    return _categories.firstWhere((cat) => cat.id == id,
        orElse: () => CategoryModel(
            id: id, name: 'Không rõ', icon: Icons.error, color: Colors.grey));
  }

  double getTotalSpendByCategory(String categoryId) {
    return _transactions
        .where((tx) => tx.categoryId == categoryId)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalSpend =>
      _transactions.fold(0.0, (sum, item) => sum + item.amount);

  double getTotalIncome() {
    return 7316218.0;
  }

  String getHighestSpendDay(String categoryId) {
    final txs = _transactions.where((tx) => tx.categoryId == categoryId).toList();
    if (txs.isEmpty) return 'Chưa có';
    final dailySpend = groupBy(txs, (tx) => tx.date.day).map((day, list) => MapEntry(
      day,
      list.fold(0.0, (sum, tx) => sum + tx.amount),
    ));
    if (dailySpend.isEmpty) return 'Chưa có';
    final highestDay = dailySpend.entries.reduce((a, b) => a.value > b.value ? a : b);
    return '${highestDay.key}/${txs.first.date.month} (${_formatCurrency(highestDay.value)})';
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return formatter.format(amount);
  }
}
