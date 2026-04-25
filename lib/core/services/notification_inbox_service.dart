import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_notification.dart';
import 'auth_service.dart';
import 'notification_repository.dart';

class NotificationInboxService implements NotificationRepository {
  NotificationInboxService();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String notificationsSubcollection = 'notifications';
  static const String devicesSubcollection = 'devices';
  static const String _prefsDeviceIdKey = 'push_device_id_v1';
  static bool _authLifecycleStarted = false;

  static CollectionReference<Map<String, dynamic>> _usersCollection() {
    return _db.collection(AuthService.usersCollection);
  }

  static CollectionReference<Map<String, dynamic>> notificationsRef(String uid) {
    return _usersCollection().doc(uid).collection(notificationsSubcollection);
  }

  static CollectionReference<Map<String, dynamic>> devicesRef(String uid) {
    return _usersCollection().doc(uid).collection(devicesSubcollection);
  }

  static CollectionReference<Map<String, dynamic>> _patientDevicesRef(String uid) {
    return _db
        .collection(AuthService.usersCollection)
        .doc(AuthService.patientsHubDocId)
        .collection(AuthService.patientUsersSubcollection)
        .doc(uid)
        .collection(devicesSubcollection);
  }

  static CollectionReference<Map<String, dynamic>> _caregiverDevicesRef(String uid) {
    return _db
        .collection(AuthService.caregiverCollection)
        .doc(uid)
        .collection(devicesSubcollection);
  }

  @override
  Stream<List<AppNotification>> watchInbox(String uid) {
    return notificationsRef(uid)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => AppNotification.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Stream<int> watchUnreadCount(String uid) {
    return notificationsRef(uid)
        .where('readAt', isNull: true)
        .snapshots()
        .map((snap) => snap.size);
  }

  @override
  Future<void> markAsRead({
    required String uid,
    required String notificationId,
  }) async {
    await notificationsRef(uid).doc(notificationId).set(<String, dynamic>{
      'readAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> markAsOpened({
    required String uid,
    required String notificationId,
  }) async {
    await notificationsRef(uid).doc(notificationId).set(<String, dynamic>{
      'openedAt': FieldValue.serverTimestamp(),
      'readAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> clearInbox(String uid) async {
    final snap = await notificationsRef(uid).get();
    if (snap.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  static Future<bool> requestPermissions() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  static Future<bool> registerCurrentDevice({
    String? token,
    String? uid,
  }) async {
    final userId = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || userId.trim().isEmpty) return false;

    try {
      String? resolvedToken = token;
      resolvedToken ??= await FirebaseMessaging.instance.getToken();
      if (resolvedToken == null || resolvedToken.trim().isEmpty) return false;

      final deviceId = await _getOrCreateDeviceId();
      final payload = <String, dynamic>{
        'deviceId': deviceId,
        'fcmToken': resolvedToken.trim(),
        'platform': defaultTargetPlatform.name,
        'locale': WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag(),
        'timezone': DateTime.now().timeZoneName,
        'lastSeenAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      final refs = await _deviceRefsForUser(userId);
      for (final ref in refs) {
        await ref.doc(deviceId).set(payload, SetOptions(merge: true));
      }
      return true;
    } on Object catch (e) {
      if (_isTransientFcmAvailabilityError(e)) {
        debugPrint('FCM not available yet. Retrying later. $e');
        return false;
      }
      debugPrint('Failed to register FCM token (non-fatal): $e');
      return false;
    }
  }

  static Future<void> registerCurrentDeviceWithRetry({
    String? uid,
    int maxAttempts = 5,
  }) async {
    for (var i = 0; i < maxAttempts; i++) {
      try {
        final ok = await registerCurrentDevice(uid: uid);
        if (ok) return;
      } catch (e) {
        if (!_isTransientFcmAvailabilityError(e)) {
          debugPrint('Unexpected token registration error: $e');
        }
      }
      await Future<void>.delayed(Duration(seconds: i + 1));
    }
    debugPrint('FCM token registration exhausted retries.');
  }

  static void startAuthRegistrationLifecycle() {
    if (_authLifecycleStarted) return;
    _authLifecycleStarted = true;
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      final uid = user?.uid.trim() ?? '';
      if (uid.isEmpty) return;
      try {
        final token = await FirebaseMessaging.instance.getToken();
        debugPrint('USER TOKEN => $token');
      } on Object catch (e) {
        debugPrint('USER TOKEN ERROR => $e');
      }
      await registerCurrentDeviceWithRetry(uid: uid);
    });
  }

  static Future<void> refreshTokenListener() async {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      debugPrint('FCM TOKEN REFRESHED => $token');
      try {
        await registerCurrentDevice(token: token);
      } catch (e) {
        debugPrint('Failed to register refreshed token: $e');
      }
    });
  }

  static bool _isTransientFcmAvailabilityError(Object error) {
    if (error is FirebaseException) {
      if (error.code == 'apns-token-not-set') return true;
      if (error.code == 'unknown') {
        final message = (error.message ?? '').toLowerCase();
        if (message.contains('service_not_available') ||
            message.contains('service not available')) {
          return true;
        }
      }
    }
    final message = error.toString().toLowerCase();
    return message.contains('service_not_available') ||
        message.contains('service not available') ||
        message.contains('java.io.ioexception');
  }

  static Future<void> sendTestNotificationToCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return;
    final ref = notificationsRef(uid).doc();
    await ref.set(<String, dynamic>{
      'notificationId': ref.id,
      'type': 'general',
      'title': 'Test notification',
      'body': 'This is a test notification from Memoro.',
      'priority': 'normal',
      'recipientUid': uid,
      'actorUid': uid,
      'pairId': '',
      'entityId': '',
      'deepLink': '',
      'payloadVersion': 1,
      'data': <String, dynamic>{},
      'status': 'sent',
      'retryCount': 0,
      'readAt': null,
      'openedAt': null,
      'sentAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_prefsDeviceIdKey) ?? '';
    if (existing.trim().isNotEmpty) {
      return existing.trim();
    }
    final generated = '${DateTime.now().millisecondsSinceEpoch}-${UniqueKey()}';
    await prefs.setString(_prefsDeviceIdKey, generated);
    return generated;
  }

  static Future<List<CollectionReference<Map<String, dynamic>>>> _deviceRefsForUser(
    String uid,
  ) async {
    final refs = <CollectionReference<Map<String, dynamic>>>[
      // Keep legacy path for backward compatibility and existing functions.
      devicesRef(uid),
    ];

    try {
      final patient = await AuthService.patientProfileRef(uid).get();
      if (patient.exists) {
        refs.add(_patientDevicesRef(uid));
      }
    } catch (_) {}

    try {
      final caregiver = await AuthService.caregiverProfileRef(uid).get();
      if (caregiver.exists) {
        refs.add(_caregiverDevicesRef(uid));
      }
    } catch (_) {}

    return refs;
  }
}
