import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';


class FCMService {
  final _messaging = FirebaseMessaging.instance;


  Future<void> init() async {
// iOS: xin quyền
    if (Platform.isIOS) {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
    }


// Token (gửi về admin server hoặc lưu Firestore nếu cần)
    final token = await _messaging.getToken();
// print('FCM token: $token');


// Xử lý khi app foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
// TODO: hiển thị local notification (có thể dùng flutter_local_notifications)
    });
  }
}