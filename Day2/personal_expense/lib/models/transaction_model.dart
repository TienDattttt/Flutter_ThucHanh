import 'package:hive/hive.dart';
part 'transaction_model.g.dart'; // Đảm bảo đã chạy build_runner

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String description;

  @HiveField(4)
  DateTime date;

  TransactionModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    this.description = '',
    required this.date,
  });
}
