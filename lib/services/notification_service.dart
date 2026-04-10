import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Background handler — top level function হতে হবে
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.messageId}');
}

class NotificationService {
  final _messaging = FirebaseMessaging.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> initialize(String userId) async {
    // Permission request
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Save FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveToken(userId, token);
      }

      // Token refresh listener
      _messaging.onTokenRefresh.listen((token) {
        _saveToken(userId, token);
      });
    }

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((message) {
      print('Foreground message: ${message.notification?.title}');
    });

    // Background handler register
    FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler);
  }

  Future<void> _saveToken(String userId, String token) async {
    await _db.collection('users').doc(userId).update({
      'fcmToken': token,
      'tokenUpdatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Send notification when tenant submits payment
  static Future<void> notifyLandlord({
    required String landlordId,
    required String title,
    required String body,
  }) async {
    // Save notification to Firestore
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': landlordId,
      'title': title,
      'body': body,
      'isRead': false,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'type': 'payment',
    });
  }

  static Future<void> notifyTenant({
    required String tenantId,
    required String title,
    required String body,
    required String type,
  }) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': tenantId,
      'title': title,
      'body': body,
      'isRead': false,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'type': type,
    });
  }
}