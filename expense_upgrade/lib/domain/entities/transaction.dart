class Transaction {
  final String id;
  final double amount;
  final String description;
  final String category;
  final DateTime date;
  final String userId;
  final DateTime createdAt;
  
  const Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    required this.userId,
    required this.createdAt,
  });
  
  Transaction copyWith({
    String? id,
    double? amount,
    String? description,
    String? category,
    DateTime? date,
    String? userId,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Transaction &&
        other.id == id &&
        other.amount == amount &&
        other.description == description &&
        other.category == category &&
        other.date == date &&
        other.userId == userId &&
        other.createdAt == createdAt;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        description.hashCode ^
        category.hashCode ^
        date.hashCode ^
        userId.hashCode ^
        createdAt.hashCode;
  }
  
  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, description: $description, category: $category, date: $date, userId: $userId, createdAt: $createdAt)';
  }
}