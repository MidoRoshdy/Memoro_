import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'local_notification_service.dart';
import 'notification_inbox_service.dart';
import 'notification_route_resolver.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background push: ${message.messageId}');
}

abstract final class PushNotificationService {
  PushNotificationService._();

  static Future<void> printFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM TOKEN => $token');
    } catch (e) {
      debugPrint('FCM TOKEN ERROR => $e');
    }
  }

  static Future<void> initialize() async {
    await printFcmToken();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await NotificationInboxService.requestPermissions();
    NotificationInboxService.startAuthRegistrationLifecycle();
    await NotificationInboxService.registerCurrentDeviceWithRetry();
    await NotificationInboxService.refreshTokenListener();

    await LocalNotificationService.initialize(
      onTapPayload: NotificationRouteResolver.openFromPayload,
    );

    FirebaseMessaging.onMessage.listen((message) async {
      final data = message.data;
      final title =
          message.notification?.title ??
          (data['title'] as String?)?.trim() ??
          'Memoro';
      final body = message.notification?.body ?? (data['body'] as String?)?.trim() ?? '';
      final type = (data['type'] as String?)?.trim() ?? 'general';
      final isEmergency = type == 'help_request';
      final id = message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch;

      await LocalNotificationService.showNow(
        id: id,
        title: title,
        body: body,
        channelId: isEmergency
            ? LocalNotificationService.emergencyChannelId
            : LocalNotificationService.activityChannelId,
        payload: data,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      await NotificationRouteResolver.openFromPayload(message.data);
    });

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      await NotificationRouteResolver.openFromPayload(initial.data);
    }
  }
}
