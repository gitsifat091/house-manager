import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';

/// Handles messages that arrive while the app is in the background or closed.
///
/// This runs in its own isolate, so nothing from the app is initialised here —
/// Firebase has to be started again before touching any of it. The previous
/// version skipped that and would have thrown the moment it did more than
/// print.
///
/// The system draws the notification itself for messages carrying a
/// notification payload, so there is nothing to do here beyond being a valid
/// entry point.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

/// Registers device tokens and surfaces messages that arrive in the foreground.
///
/// Sending is not done here and cannot be: the app has no credentials to talk
/// to FCM. Cloud Functions watch the collections that matter and push from
/// there. See functions/src/index.ts.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Shows foreground messages. Set from main().
  static GlobalKey<ScaffoldMessengerState>? messengerKey;

  String? _initialisedFor;
  String? _currentToken;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;

  /// Registers the background handler.
  ///
  /// Must run before runApp and exactly once. The old code called this from
  /// inside a widget build, which re-registered it on every rebuild and leaked
  /// a fresh listener each time.
  static void registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// Prepares notifications for [userId]. Safe to call repeatedly; it does
  /// real work only when the signed-in account changes.
  Future<void> initialize(String userId) async {
    if (userId.isEmpty || _initialisedFor == userId) return;
    await _teardown();
    _initialisedFor = userId;

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Provisional counts: iOS can grant quiet delivery without a prompt.
      final granted = settings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      if (granted) {
        final token = await _messaging.getToken();
        if (token != null) await _saveToken(userId, token);

        _tokenRefreshSub = _messaging.onTokenRefresh.listen((token) {
          _saveToken(userId, token);
        });
      }

      _foregroundSub = FirebaseMessaging.onMessage.listen(_showForeground);
    } catch (_) {
      // Notifications are an extra; never let them break sign-in.
      _initialisedFor = null;
    }
  }

  /// Drops this device's token so the next person to sign in on it does not
  /// receive the previous account's notifications.
  Future<void> releaseFor(String userId) async {
    final token = _currentToken;
    await _teardown();
    if (userId.isEmpty || token == null) return;
    try {
      await _db.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    } catch (_) {
      // Best effort: a stale token is pruned by the sender when it fails.
    }
  }

  Future<void> _teardown() async {
    await _tokenRefreshSub?.cancel();
    await _foregroundSub?.cancel();
    _tokenRefreshSub = null;
    _foregroundSub = null;
    _initialisedFor = null;
    _currentToken = null;
  }

  /// Stores the token as one of possibly several devices for this account.
  ///
  /// `set` with merge rather than `update`, which throws when the document is
  /// missing, and an array rather than a single field, so signing in on a
  /// second device does not silently unsubscribe the first.
  Future<void> _saveToken(String userId, String token) async {
    _currentToken = token;
    try {
      await _db.collection('users').doc(userId).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'tokenUpdatedAt': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));
    } catch (_) {
      // Retried on the next sign-in or token refresh.
    }
  }

  /// A message arriving while the app is open is not drawn by the system, so
  /// show it in-app instead.
  void _showForeground(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final messenger = messengerKey?.currentState;
    if (messenger == null) return;

    final title = notification.title ?? '';
    final body = notification.body ?? '';
    if (title.isEmpty && body.isEmpty) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            if (body.isNotEmpty) Text(body),
          ],
        ),
      ),
    );
  }
}
