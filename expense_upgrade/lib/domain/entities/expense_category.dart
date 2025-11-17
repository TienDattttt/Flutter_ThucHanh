import 'package:flutter/material.dart';

class ExpenseCategory {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final bool isDefault;
  
  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isDefault = false,
  });
  
  ExpenseCategory copyWith({
    String? id,
    String? name,
    String? icon,
    Color? color,
    bool? isDefault,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ExpenseCategory &&
        other.id == id &&
        other.name == name &&
        other.icon == icon &&
        other.color == color &&
        other.isDefault == isDefault;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        icon.hashCode ^
        color.hashCode ^
        isDefault.hashCode;
  }
  
  @override
  String toString() {
    return 'ExpenseCategory(id: $id, name: $name, icon: $icon, color: $color, isDefault: $isDefault)';
  }
}