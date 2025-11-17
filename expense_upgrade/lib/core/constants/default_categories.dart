import 'package:flutter/material.dart';
import '../../domain/entities/expense_category.dart';

class DefaultCategories {
  static List<ExpenseCategory> get categories => [
    const ExpenseCategory(
      id: 'food',
      name: 'Ăn uống',
      icon: '🍽️',
      color: Colors.orange,
      isDefault: true,
    ),
    const ExpenseCategory(
      id: 'transport',
      name: 'Di chuyển',
      icon: '🚗',
      color: Colors.blue,
      isDefault: true,
    ),
    const ExpenseCategory(
      id: 'shopping',
      name: 'Mua sắm',
      icon: '🛍️',
      color: Colors.pink,
      isDefault: true,
    ),
    const ExpenseCategory(
      id: 'entertainment',
      name: 'Giải trí',
      icon: '🎬',
      color: Colors.purple,
      isDefault: true,
    ),
    const ExpenseCategory(
      id: 'health',
      name: 'Sức khỏe',
      icon: '🏥',
      color: Colors.red,
      isDefault: true,
    ),
    const ExpenseCategory(
      id: 'education',
      name: 'Giáo dục',
      icon: '📚',
      color: Colors.green,
      isDefault: true,
    ),
    const ExpenseCategory(
      id: 'utilities',
      name: 'Tiện ích',
      icon: '💡',
      color: Colors.amber,
      isDefault: true,
    ),
    const ExpenseCategory(
      id: 'other',
      name: 'Khác',
      icon: '📦',
      color: Colors.grey,
      isDefault: true,
    ),
  ];
}