import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Đăng ký adapter cho model
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }
  }

  static Future<Box<T>> openBox<T>(String name) async {
    if (Hive.isBoxOpen(name)) return Hive.box<T>(name);
    return await Hive.openBox<T>(name);
  }

  static Future<void> closeBox(String name) async {
    if (Hive.isBoxOpen(name)) {
      await Hive.box(name).close();
    }
  }
}
