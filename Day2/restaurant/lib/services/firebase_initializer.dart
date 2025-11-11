import 'package:firebase_core/firebase_core.dart';


class FirebaseInitializer {
  static bool _initialized = false;
  static Future<void> init() async {
    if (_initialized) return;
    await Firebase.initializeApp();
    _initialized = true;
  }
}