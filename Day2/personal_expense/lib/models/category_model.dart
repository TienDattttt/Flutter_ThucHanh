import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double limit; // Hạn mức chi tiêu cho mục này

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.limit = 0.0,
  });
}