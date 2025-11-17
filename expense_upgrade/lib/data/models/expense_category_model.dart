import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/expense_category.dart';
import '../../domain/validators/category_validator.dart';

class ExpenseCategoryModel extends ExpenseCategory {
  const ExpenseCategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
    super.isDefault = false,
  });
  
  factory ExpenseCategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseCategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      color: Color(data['color'] ?? 0xFF2196F3),
      isDefault: data['isDefault'] ?? false,
    );
  }
  
  factory ExpenseCategoryModel.fromEntity(ExpenseCategory category) {
    CategoryValidator.validateCategory(category);
    return ExpenseCategoryModel(
      id: category.id,
      name: category.name,
      icon: category.icon,
      color: category.color,
      isDefault: category.isDefault,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'color': color.value,
      'isDefault': isDefault,
    };
  }
  
  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      color: Color(json['color'] ?? 0xFF2196F3),
      isDefault: json['isDefault'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color.value,
      'isDefault': isDefault,
    };
  }
}