import 'package:flutter/material.dart';

class ChartData {
  final String label;
  final double value;
  final Color color;
  
  const ChartData({
    required this.label,
    required this.value,
    required this.color,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ChartData &&
        other.label == label &&
        other.value == value &&
        other.color == color;
  }
  
  @override
  int get hashCode {
    return label.hashCode ^ value.hashCode ^ color.hashCode;
  }
  
  @override
  String toString() {
    return 'ChartData(label: $label, value: $value, color: $color)';
  }
}